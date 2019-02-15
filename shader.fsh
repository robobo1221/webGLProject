precision mediump float;

varying vec2 texcoord;

uniform vec2 viewResolution;    //x = viewWidth, y = viewHeight
uniform float time;             //in Seconds

void main() {

    vec2 sqpos = vec2(texcoord.x * (viewResolution.x / viewResolution.y), texcoord.y);
    vec2 cqpos = vec2(0.5 * (viewResolution.x / viewResolution.y), 0.5);

    vec3 color = vec3(0.0);
         color += step(distance(sqpos, cqpos + vec2(cos(time), sin(time)) * 0.1), 0.1);
    gl_FragColor = vec4(color, 1.0);
}