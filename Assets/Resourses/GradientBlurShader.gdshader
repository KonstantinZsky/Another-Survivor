shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec3 color_light : source_color;
uniform vec3 color_dark : source_color;
uniform float mixing: hint_range(0.0, 1) = 0.0;
uniform float lod: hint_range(0.0, 5) = 0.8;

void fragment() {
	vec3 clr_gardient = color_light*(1.0-UV.y) + color_dark*UV.y;
	COLOR = mix(texture(SCREEN_TEXTURE, SCREEN_UV, lod),vec4(clr_gardient,1.0),mixing);
}
