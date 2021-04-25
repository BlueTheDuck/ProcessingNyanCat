#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main(void) {
  // Grouping texcoord variables in order to make it work in the GMA 950. See post #13
  // in this thread:
  // http://www.idevgames.com/forums/thread-3467.html
  
  vec4 col0 = texture2D(texture, vec2(vertTexCoord.x-1.0,vertTexCoord.y-1.0));
  vec4 col1 = texture2D(texture, vec2(vertTexCoord.x+0.0,vertTexCoord.y-1.0));
  vec4 col2 = texture2D(texture, vec2(vertTexCoord.x+1.0,vertTexCoord.y-1.0));
  vec4 col3 = texture2D(texture, vec2(vertTexCoord.x-1.0,vertTexCoord.y-0.0));
  vec4 col4 = texture2D(texture, vec2(vertTexCoord.x+0.0,vertTexCoord.y-0.0));
  vec4 col5 = texture2D(texture, vec2(vertTexCoord.x+1.0,vertTexCoord.y-0.0));
  vec4 col6 = texture2D(texture, vec2(vertTexCoord.x-1.0,vertTexCoord.y+1.0));
  vec4 col7 = texture2D(texture, vec2(vertTexCoord.x+0.0,vertTexCoord.y+1.0));
  vec4 col8 = texture2D(texture, vec2(vertTexCoord.x+1.0,vertTexCoord.y+1.0));
  
  vec4 col = (col0*2.0+col1*0.1+col2*0.2+col3*0.1+col4*0.2+col5*0.1+col6*0.2+col7*0.1+col8*0.2)*vertColor*0.8;
  
  gl_FragColor = col;
}