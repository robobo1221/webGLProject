precision mediump float;

varying vec2 texcoord;

uniform vec2 viewResolution;    //x = viewWidth, y = viewHeight
uniform float time;             //in Seconds

void main() {

    vec2 sqpos = vec2(texcoord.x * (viewResolution.x / viewResolution.y), texcoord.y);
    vec2 cqpos = vec2(0.5 * (viewResolution.x / viewResolution.y), 0.5);

    vec3 color = vec3(0.0);
    
    for (int i = 0; i < 32; ++i){
        float en = pow(0.5, float(i) + 1.0);
        vec2 offset = vec2(1.0 / en, 0.0) * 0.005;
        color += step(distance(sqpos + offset, cqpos), 0.1) * en;
    }

    gl_FragColor = vec4(color, 1.0);
}