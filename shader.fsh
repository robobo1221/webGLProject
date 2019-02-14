precision mediump float;

varying vec2 texcoord;

void main() {

    vec3 color = vec3(1.0);
    color *= step(distance(texcoord, vec2(0.5)), 0.2);

    gl_FragColor = vec4(color, 1.0);
}