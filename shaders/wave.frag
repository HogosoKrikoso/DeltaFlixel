#pragma header

uniform float uTime;
uniform vec2 uTexel;

//Modify the following three consts to change the wave effect to your liking
const float xSpeed = 0.005;
const float xFreq = 175.0;
const float xSize = 1.0;
const float mult = 1.0;

void main()
{
	vec2 uv = openfl_TextureCoordv;
    float xWave = sin(uTime*xSpeed + uv.y*xFreq) * (xSize*uTexel.x*mult);
    vec4 color = gl_FragColor * flixel_texture2D(bitmap, uv + vec2(xWave, 0.0));
    gl_FragColor = color;
}