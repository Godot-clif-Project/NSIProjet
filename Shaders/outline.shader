shader_type canvas_item;

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
	sample = ceil(sample);
	vec4 texture_color = texture(TEXTURE, UV);
	COLOR = bool(texture_color.a) ? texture_color.rgba : vec4(outline_color.rgb, sample);
}
