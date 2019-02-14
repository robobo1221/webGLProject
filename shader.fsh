precision mediump float;

varying vec2 texcoord;

uniform vec2 viewResolution;    //x = viewWidth, y = viewHeight
uniform float time;             //in Seconds

void main() {

    vec3 color = vec3(1.0);
    color = vec3(1.0, 0.5, 0.2) * (fract(time));

    gl_FragColor = vec4(color, 1.0);
}