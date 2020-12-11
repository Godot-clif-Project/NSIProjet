shader_type canvas_item;

uniform sampler2D palette_a;
uniform sampler2D palette_b;
uniform float blend = 0.0;

void fragment()
{
	vec4 spr_color = texture(TEXTURE, UV);
	vec4 final_color = texture(palette_a, spr_color.rg);
	if (blend > 0.0)
	{
		vec4 blend_color = texture(palette_b, spr_color.rg);
		final_color = mix(final_color, blend_color, blend);
	}
	final_color.a = spr_color.a;
	COLOR = final_color;
}
