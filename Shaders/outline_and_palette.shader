shader_type canvas_item;

// this shader is a dirty mix of the outline and the palette shaders because
// i couldn't be bothered doing it properly with actual code


uniform sampler2D palette_a;
uniform sampler2D palette_b;
uniform float blend = 0.0;
uniform vec2 texture_size;
uniform vec4 outline_color = vec4(1.0);

void fragment()
{
	vec2 offset = 1.0 / texture_size;
	float sample;
	sample += texture(TEXTURE, vec2(UV.x + offset.x, UV.y)).a;
	sample += texture(TEXTURE, vec2(UV.x - offset.x, UV.y)).a;
	sample += texture(TEXTURE, vec2(UV.x, UV.y + offset.y)).a;
	sample += texture(TEXTURE, vec2(UV.x, UV.y - offset.y)).a;
	sample = min(sample, 1.0);
	
	vec4 spr_color = texture(TEXTURE, UV);
	vec4 final_color = texture(palette_a, spr_color.rg);
	if (blend > 0.0)
	{
		vec4 blend_color = texture(palette_b, spr_color.rg);
		final_color = mix(final_color, blend_color, blend);
	}
	final_color.a = spr_color.a;
	
	COLOR = bool(final_color.a) ? final_color.rgba : vec4(outline_color.rgb, sample);
}
