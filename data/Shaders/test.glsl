#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform sampler2D camera;
//uniform vec2 texOffset;

uniform vec2 resolution;
uniform vec2 mouse;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main( void ) 
{
  vec2 p = -1.0 + (-2.0) * gl_FragCoord.xy / resolution.xy;
  vec2 m = -1.0 + (-2.0) * mouse.xy / resolution.xy;

  vec4 col = texture2D(texture,vertTexCoord.xy);
  vec4 newCol = texture2D(camera,vertTexCoord.xy);
  vec4 back = vec4(15.0/255.0,77.0/255.0,143/255,1.0);
  
  if (col.r+0.1>back.r&&col.r-0.1<back.r && col.g+0.1>back.g&&col.g-0.1<back.g) {
	//col = vec4(0.0,1.0,0.0,1.0);
	col = vec4(newCol.r,newCol.g,newCol.b,1);
  }
  
  gl_FragColor = col;//vec4(col / (0.1 + w), 1.0);
}
