//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D texField;
uniform float uniTime;

const float TAU = 3.14592 * 2.0;

void main()
{
	// Get signed distance from field.
	vec4 field = texture2D(texField, v_vTexcoord);
	float dist = (field.z - 0.5) * 2.0;
	
	// Get original the surface, draw black line moving. Ugly example though.
	vec4 color = texture2D(gm_BaseTexture, v_vTexcoord);
	color.rgb -= max(0.0, sin(TAU * dist - uniTime) * 4.0  - 3.0);
	
	// Show the result.
    gl_FragColor = v_vColour * color;
}
