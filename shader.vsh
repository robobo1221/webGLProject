#version 300 es

out vec2 texcoord;

in vec4 vertPos;

void main() {
    gl_Position = vertPos;
    texcoord = vertPos.xy * 0.5 + 0.5;
}