precision mediump float;

varying vec2 texcoord;

uniform vec2 viewResolution;    //x = viewWidth, y = viewHeight
uniform float time;             //in Seconds

void main() {
    gl_FragColor = vec4(vec3(texcoord.x, 0.0, 0.0), 1.0);
}