shader_type canvas_item;

uniform sampler2D noise_tex;
uniform float strength = 2.0;

void fragment()
{
	vec2 offset = round((texture(noise_tex, SCREEN_UV).rg - .5) * strength);
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV + offset * SCREEN_PIXEL_SIZE);
	
	COLOR = color;
}
