#version 300 es
precision mediump float;

in vec2 texcoord;
out vec4 fragColor;

uniform vec3 sunVector;
uniform vec2 viewResolution;    //x = viewWidth, y = viewHeight
uniform float time;             //in Seconds

/*****************************************************************/

#define clamp01(x) clamp(x, 0.0, 1.0)
#define max0(x) max(0.0, x)

/*****************************************************************/

const float PI = acos(-1.0);
const float rPI = 1.0 / PI;
const float TAU = PI * 2.0;

//const vec3 sundir = vec3(1.0, 0.0, 0.0);
const float sunBrightness = 40.0;

const float f0 = 0.021;
const float roughness = 0.3;

const vec3 rayleighCoeff = vec3(5.8000e-6, 1.3500e-5, 3.3100e-5);
const vec3 mieCoeff = vec3(8.0e-6);
const vec3 waterCoeff = vec3(0.25422, 0.03751, 0.01150);

const mat2x3 scatterCoeff = mat2x3(rayleighCoeff, mieCoeff);
const mat2x3 extinctionCoeff = mat2x3(rayleighCoeff, mieCoeff * 1.11);

const float sunAngularSize = 0.5;

const float mieG = 0.8;

const float planetRadius = 6371.0e3;
const float atmosphereHeight = 110.0e3;
const float atmosphereRadius = planetRadius + atmosphereHeight;
const float atmosphereRadiusSquared = atmosphereRadius * atmosphereRadius;

const vec2 distribution = vec2(8.0e3, 1.2e3);
const vec2 rDistriburion = 1.0 / distribution;
const vec2 scaledPlanetRadius = rDistriburion * planetRadius;

vec3 spherePosition = vec3(0.0, planetRadius + 1000.0, 0.0);

float bayer2(vec2 a){
    a = floor(a);
    return fract( dot(a, vec2(.5, a.y * .75)) );
}

float phaseRayleigh(float cosTheta) {
	const vec2 mul_add = vec2(0.1, 0.28) * rPI;
	return cosTheta * mul_add.x + mul_add.y;
}

float hgPhase(float cosTheta, const float g){
    float g2 = g * g;

    return 0.25 * rPI * (1.0 - g2) * pow(1.0 + g2 - 2.0 * g * cosTheta, -1.5);
}

float GSpecular(const float alpha2, const float NoV, const float NoL) {
    float x = 2.0 * NoL * NoV;
    float y = (1.0 - alpha2);

    return x / (NoV * sqrt(alpha2 + y * (NoL * NoL)) + NoL * sqrt(alpha2 + y * (NoV * NoV)));
}

float ggxDistribution(const float alpha2, const float NoH){
    float d = (NoH * alpha2 - NoH) * NoH + 1.0;

    return alpha2 / (PI * d * d);
}

float fresnel(const float f0, const float LoH) {
    return (1.0 - f0) * pow(1. - LoH, 5.0) + f0;
}

float calculateSpecularBRDF(const vec3 normal, const vec3 lightVector, const vec3 worldVector, const float f0, const float alpha2){
	vec3 H = normalize(lightVector - worldVector);
	
	float VoH = clamp01(dot(H, lightVector));
	float NoL = clamp01(dot(normal, lightVector));
	float NoV = clamp01(dot(normal, -worldVector));
	float VoL = (dot(lightVector, -worldVector));
	float NoH = clamp01(dot(normal, H));

	float D = ggxDistribution(alpha2, NoH);
	float G = GSpecular(alpha2, NoV, NoL);
	float F = fresnel(f0, VoH);

	return max0(F * D * G / (4.0 * NoL * NoV)) * NoL;
}

float hash13(vec3 p3){
	p3  = fract(p3 * vec3(443.897, 441.423, 437.195));
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float calculateStars(vec3 worldVector){
    const float res = 256.0;

    vec3 starCoord = worldVector * res;
    vec3 fl = floor(starCoord);
    vec3 fr = fract(starCoord) - 0.5;

    float randVal = hash13(fl);
    float starMask = step(randVal, 0.01);
    float stars = smoothstep(0.5, 0.0, length(fr)) * starMask;

    return stars * 0.5;
}

#define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
#define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
#define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))
#define bayer32(a)  (bayer16(.5*(a))*.25+bayer2(a))
#define bayer64(a)  (bayer32(.5*(a))*.25+bayer2(a))
#define bayer128(a) (bayer64(.5*(a))*.25+bayer2(a))

float calculateSunSpot(float VdotL) {
    const float sunRadius = radians(sunAngularSize);
    const float cosSunRadius = cos(sunRadius);
    const float sunLuminance = 1.0 / ((1.0 - cosSunRadius) * TAU);

    return step(cosSunRadius, VdotL) * sunLuminance;
}

vec2 calculateScatterOD(float rayDist){

    vec2 dist = rayDist * -rDistriburion + scaledPlanetRadius;

    return exp2(dist);
}

vec3 calculateScatterIntegral(vec3 stepTransmittance, const vec3 coeff){
    vec3 a = -1.0 / coeff;

    return stepTransmittance * a - a;
}

vec2 calcTransmittanceAirmass(vec3 position, vec3 direction, float rayLength) {
    const int steps = 3;
    const float rSteps = 1.0 / float(steps);

	float stepSize  = rayLength * rSteps;
	vec3  increment = direction * stepSize;
	position += increment * 0.5;

	vec2 airmass = vec2(0.0);
	for (int i = 0; i < steps; ++i) {
		airmass += calculateScatterOD(length(position));
        position += increment;
	}

	return airmass * stepSize;
}
vec2 calcTransmittanceAirmass(vec3 position, vec3 direction) {
	float rayLength = dot(position, direction);
	      rayLength = rayLength * rayLength + atmosphereRadiusSquared - dot(position, position);
		  if (rayLength < 0.0) return vec2(0.0);
	      rayLength = sqrt(rayLength) - dot(position, direction);

	return calcTransmittanceAirmass(position, direction, rayLength);
}

vec3 calcTransmittanceOD(vec3 position, vec3 direction, float rayLength) {
	return extinctionCoeff * calcTransmittanceAirmass(position, direction, rayLength);
}
vec3 calcTransmittanceOD(vec3 position, vec3 direction) {
	return extinctionCoeff * calcTransmittanceAirmass(position, direction);
}

vec3 absorbSunlightSky(vec3 position, vec3 direction) {
	return exp(-calcTransmittanceOD(position, direction));
}

void doScattering(vec3 rayPosition, vec3 worldVector, vec3 spherePosition, vec3 stepTransmittance, vec3 transmittance, vec3 stepOD, vec2 od, vec2 phases, inout vec3 directScatter){
    vec3 scatterIntegral = clamp01((stepTransmittance - 1.0) / -stepOD);
    vec3 directShadow = absorbSunlightSky(rayPosition, sunVector);

    directScatter += scatterIntegral * directShadow * transmittance * (mat2x3(scatterCoeff) * (phases * od));
}

vec2 rsi(vec3 position, vec3 direction, float radius) {
	float PoD = dot(position, direction);
	float radiusSquared = radius * radius;

	float delta = PoD * PoD + radiusSquared - dot(position, position);
	if (delta < 0.0) return vec2(-1.0);
	      delta = sqrt(delta);

	return -PoD + vec2(-delta, delta);
}

vec3 calculatePlanet(vec3 backGround, vec3 worldVector, float LoV, float dither){
    const int steps = 32;
    const float rSteps = 1.0 / float(steps);

    vec2 aS = rsi(spherePosition, worldVector, atmosphereRadius);
    if (aS.y < 0.0) return backGround;

    vec2 pS = rsi(spherePosition, worldVector, planetRadius);
    bool pI = pS.y >= 0.0;
    vec2 sd = vec2((pI && pS.x < 0.0) ? pS.y : max(aS.x, 0.0), (pI && pS.x > 0.0) ? pS.x : aS.y);

    float rayLength = (sd.y - sd.x) * rSteps;

    vec3 increment = worldVector * rayLength;
    vec3 rayPosition = worldVector * sd.x + (increment * 0.3 + spherePosition);

    vec3 directScatter = vec3(0.0);
    vec3 transmittance = vec3(1.0);

    vec2 phases = vec2(phaseRayleigh(LoV), hgPhase(LoV, mieG));

    for (int i = 0; i < steps; ++i){
        rayPosition += increment;

        vec2 density = calculateScatterOD(length(rayPosition));
        if (density.x > 1e35) break;
        vec2 od = rayLength * density;
        vec3 stepOD = mat2x3(extinctionCoeff) * od;

        vec3 stepTransmittance = exp(-stepOD);
        doScattering(rayPosition, worldVector, spherePosition, stepTransmittance, transmittance, stepOD, od, phases, directScatter);

        transmittance *= stepTransmittance;
    }

    vec3 scattering = directScatter * sunBrightness;
    float visibility = 1.0 - float(pI);

    vec3 planetPosition = worldVector * pS.x + spherePosition;
    vec3 normal = normalize(planetPosition);
    vec3 sunTransmittance = absorbSunlightSky(planetPosition, sunVector);
    vec3 sunColor = sunTransmittance * sunBrightness;

    const float alpha2 = roughness * roughness * roughness * roughness;

    vec3 sunSpecular = calculateSpecularBRDF(normal, sunVector, worldVector, f0, alpha2) * sunColor;
    vec3 waterColor = exp2(-waterCoeff * 10.0) * sunTransmittance;

    vec3 planet = waterColor + sunSpecular;

    return (backGround * visibility + planet * (1.0 - visibility)) * transmittance + scattering;
}

void main() {

    vec2 wUV = (texcoord * 2.0 - 1.0) * vec2(1.0, viewResolution.y / viewResolution.x);
    vec3 worldVector = normalize(vec3(wUV, 0.5));

    float LoV = dot(sunVector, worldVector);

    float dither = bayer64(texcoord * viewResolution);

    float sun = calculateSunSpot(LoV);
    float stars = calculateStars(worldVector);

    vec3 color = vec3(sun) + stars;
    color = calculatePlanet(color, worldVector, LoV, dither);
    

    //color = pow(color, vec3(2.2));
    color /= color + 1.0;
    //color = pow(color, vec3(1.0 / 2.2));

    fragColor = vec4(color, 1.0);
}