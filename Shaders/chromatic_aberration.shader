shader_type canvas_item;

uniform vec2 offset = vec2(1.0);


void fragment()
{
	vec4 scrTex = texture(SCREEN_TEXTURE, SCREEN_UV);
	float red = texture(SCREEN_TEXTURE, SCREEN_UV + offset * SCREEN_PIXEL_SIZE).r;
	COLOR = vec4(red, scrTex.gba);
}
