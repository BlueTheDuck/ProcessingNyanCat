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
  
  vec2 position = vertTexCoord.st;
  vec2 pos2 = vec2(vertTexCoord.st.s,1-vertTexCoord.st.t);
  vec4 col = texture2D(texture,pos2);
  
  gl_FragColor = col;
}
