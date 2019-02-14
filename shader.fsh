precision mediump float;

varying vec2 texcoord;

uniform vec2 viewResolution;
uniform float frameTimeCounter;

void main() {

    vec3 color = vec3(1.0);
    color *= step(distance(texcoord + cos(frameTimeCounter + texcoord * 4.0) * 0.5, vec2(0.5)), 0.2);

    gl_FragColor = vec4(color, 1.0);
}