varying vec2 texcoord;

attribute vec4 vertPos;

void main() {
    gl_Position = vertPos;
    texcoord = vertPos.xy * 0.5 + 0.5;
}