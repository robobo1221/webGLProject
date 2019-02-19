precision mediump float;

varying vec2 texcoord;

uniform vec3 sunVector;
uniform vec2 viewResolution;    //x = viewWidth, y = viewHeight
uniform float time;             //in Seconds

const float PI = acos(-1.0);
const float rPI = 1.0 / PI;
const float TAU = PI * 2.0;

//const vec3 sundir = vec3(1.0, 0.0, 0.0);
const float sunBrightness = 40.0;
const vec3 scatterCoeff = vec3(0.15, 0.45, 1.0) * 50.0;

const float sunAngularSize = 0.5;

const float planetRadius = 6.0;
const float atmosphereHeight = 0.075;
const float atmosphereRadius = planetRadius + atmosphereHeight;
const float atmosphereRadiusSquared = atmosphereRadius * atmosphereRadius;

const float distribution = 0.003;
const float rDistriburion = 1.0 / distribution;
const float scaledPlanetRadius = rDistriburion * planetRadius;

vec3 spherePosition = vec3(0.0, 6.001, 0.0);

float bayer2(vec2 a){
    a = floor(a);
    return fract( dot(a, vec2(.5, a.y * .75)) );
}

float phaseRayleigh(float cosTheta) {
	const vec2 mul_add = vec2(0.1, 0.28) * rPI;
	return cosTheta * mul_add.x + mul_add.y;
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

float calculateScatterOD(float rayDist){

    float dist = rayDist * -rDistriburion + scaledPlanetRadius;

    return exp2(dist);
}

vec3 calculateScatterIntegral(vec3 stepTransmittance, const vec3 coeff){
    vec3 a = -1.0 / coeff;

    return stepTransmittance * a - a;
}

vec3 calcTransmittanceAirmass(vec3 position, vec3 direction, float rayLength) {
    const int steps = 3;
    const float rSteps = 1.0 / float(steps);

	float stepSize  = rayLength * rSteps;
	vec3  increment = direction * stepSize;
	position += increment * 0.5;

	vec3 airmass = vec3(0.0);
	for (int i = 0; i < steps; ++i) {
		airmass += calculateScatterOD(length(position));
        position += increment;
	}

	return airmass * stepSize;
}
vec3 calcTransmittanceAirmass(vec3 position, vec3 direction) {
	float rayLength = dot(position, direction);
	      rayLength = rayLength * rayLength + atmosphereRadiusSquared - dot(position, position);
		  if (rayLength < 0.0) return vec3(0.0);
	      rayLength = sqrt(rayLength) - dot(position, direction);

	return calcTransmittanceAirmass(position, direction, rayLength);
}

vec3 calcTransmittanceOD(vec3 position, vec3 direction, float rayLength) {
	return scatterCoeff * calcTransmittanceAirmass(position, direction, rayLength);
}
vec3 calcTransmittanceOD(vec3 position, vec3 direction) {
	return scatterCoeff * calcTransmittanceAirmass(position, direction);
}

vec3 absorbSunlightSky(vec3 position, vec3 direction) {
	return exp(-calcTransmittanceOD(position, direction));
}

void doScattering(vec3 rayPosition, vec3 worldVector, vec3 spherePosition, vec3 stepTransmittance, vec3 transmittance, float od, inout vec3 directScatter){
    vec3 scatterIntegral = calculateScatterIntegral(stepTransmittance, scatterCoeff);
    vec3 directShadow = absorbSunlightSky(rayPosition, sunVector);

    directScatter += scatterIntegral * directShadow * transmittance * scatterCoeff;
}

vec2 rsi(vec3 position, vec3 direction, float radius) {
	float PoD = dot(position, direction);
	float radiusSquared = radius * radius;

	float delta = PoD * PoD + radiusSquared - dot(position, position);
	if (delta < 0.0) return vec2(-1.0);
	      delta = sqrt(delta);

	return -PoD + vec2(-delta, delta);
}

vec3 calculateSky(vec3 worldVector, float LoV, float dither){
    const int steps = 32;
    const float rSteps = 1.0 / float(steps);

    vec2 aS = rsi(spherePosition, worldVector, atmosphereRadius);
    if (aS.y < 0.0) return vec3(0.0);

    vec2 pS = rsi(spherePosition, worldVector, planetRadius);
    bool pI = pS.y >= 0.0;
    vec2 sd = vec2((pI && pS.x < 0.0) ? pS.y : max(aS.x, 0.0), (pI && pS.x > 0.0) ? pS.x : aS.y);

    float rayLength = (sd.y - sd.x) * rSteps;

    vec3 increment = worldVector * rayLength;
    vec3 rayPosition = worldVector * sd.x + (increment * 0.3 + spherePosition);

    vec3 directScatter = vec3(0.0);
    vec3 transmittance = vec3(1.0);

    float rayleighPhase = phaseRayleigh(LoV);

    for (int i = 0; i < steps; ++i){
        rayPosition += increment;

        float od = calculateScatterOD(length(rayPosition)) * rayLength;
        if (od > 1e35) break;

        vec3 stepTransmittance = exp(-od * scatterCoeff);
        doScattering(rayPosition, worldVector, spherePosition, stepTransmittance, transmittance, od, directScatter);

        transmittance *= stepTransmittance;
    }

    vec3 scattering = directScatter * rayleighPhase * sunBrightness;

    float sun = calculateSunSpot(LoV);
    vec3 background = vec3(sun);

    transmittance = pI ? vec3(0.0) : transmittance;

    return background * transmittance + scattering;
}

void main() {

    vec2 wUV = (texcoord * 2.0 - 1.0) * vec2(1.0, viewResolution.y / viewResolution.x);
    vec3 worldVector = normalize(vec3(wUV, 1.0));

    float LoV = dot(sunVector, worldVector);

    float dither = bayer64(texcoord * viewResolution);
    vec3 volumetricLight = calculateSky(worldVector, LoV, dither);

    vec3 color = volumetricLight;
         //color = pow(color, vec3(2.2));
         color /= color + 1.0;
         //color = pow(color, vec3(1.0 / 2.2));

    gl_FragColor = vec4(color, 1.0);
}