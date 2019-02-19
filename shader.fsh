precision mediump float;

varying vec2 texcoord;

uniform vec2 viewResolution;    //x = viewWidth, y = viewHeight
uniform float time;             //in Seconds

float bayer2(vec2 a){
    a = floor(a);
    return fract( dot(a, vec2(.5, a.y * .75)) );
}

#define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
#define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
#define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))
#define bayer32(a)  (bayer16(.5*(a))*.25+bayer2(a))
#define bayer64(a)  (bayer32(.5*(a))*.25+bayer2(a))
#define bayer128(a) (bayer64(.5*(a))*.25+bayer2(a))

void main() {

    vec3 worldVector = normalize(vec3(texcoord * 2.0 - 1.0, 1.0));

    float dither = bayer128(texcoord * viewResolution);

    const float colCount = 1.0;
    vec3 dL = floor(exp2(-texcoord.x * 10.0) * vec3(1.0, 0.5, 0.2) * colCount + dither) / colCount;

    gl_FragColor = vec4(dL, 1.0);
}