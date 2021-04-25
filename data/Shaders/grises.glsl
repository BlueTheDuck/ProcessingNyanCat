#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main(void) {
  // Grouping texcoord variables in order to make it work in the GMA 950. See post #13
  // in this thread:
  // http://www.idevgames.com/forums/thread-3467.html
  
  vec2 position = vertTexCoord.st;
  vec4 col = texture2D(texture,position);
  
  float colUn = (col.r+col.g+col.b)/3;
  
  gl_FragColor = vec4(colUn,colUn,colUn,col.a);
}
