varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float exposure;
uniform float contrast;
uniform float saturation;

uniform vec3 color_filter;
uniform vec3 shadows;
uniform vec3 midtones;
uniform vec3 highlights;
uniform vec4 SMHranges;


#define ACEScc_MIDGRAY	0.4135884

void main() 
{
	vec4 base = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec3 colour = base.rgb;
	
	
	
	//exposure
	colour *= pow(2.0, exposure);
	
	//contrast
	colour = ((colour - ACEScc_MIDGRAY) * contrast) + ACEScc_MIDGRAY;
	
	//colour filter
	colour *= color_filter;
	

	float luminance = (colour.r * 0.3) + (colour.g * 0.59) + (colour.b * 0.11);
	
	//saturation
	colour = (colour - luminance) * saturation + luminance;
	
	//shadows midtones highlights.
	float shadowsWeight = 1.0 - smoothstep(SMHranges.x, SMHranges.y, luminance);
	float highlightsWeight = smoothstep(SMHranges.z, SMHranges.w, luminance);
	float midtonesWeight = 1.0 - shadowsWeight - highlightsWeight;
	
	vec3 _SMHShadows =    shadows;
	vec3 _SMHMidtones =   midtones;
	vec3 _SMHHighlights = highlights;
	
	colour = colour * _SMHShadows * shadowsWeight +
		colour * _SMHMidtones * midtonesWeight +
		colour * _SMHHighlights * highlightsWeight;
	
	gl_FragColor = vec4(colour, 1.0);
}