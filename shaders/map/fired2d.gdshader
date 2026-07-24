/*
	炎シェーダー by あるる（きのもと 結衣）
	Fire Shader by Yui Kinomoto @arlez80

	MIT License
*/
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D noise_tex : hint_default_white;
uniform vec4 root_color : source_color = vec4( 1.0, 0.75, 0.3, 1.0 );
uniform vec4 tip_color : source_color = vec4( 1.0, 0.03, 0.001, 1.0 );

uniform float fire_alpha : hint_range( 0.0, 1.0 ) = 1.0;
uniform vec2 fire_speed = vec2( 1.0, 0.0 );
uniform float fire_aperture : hint_range( 0.0, 3.0 ) = 0.22;

void fragment( )
{
	vec2 shifted_uv = UV + TIME * fire_speed;
	float fire_noise = texture( noise_tex, shifted_uv ).r;
    float x = 1.0 - UV.x;
	float noise = x * ( ( ( x + fire_aperture ) * fire_noise - fire_aperture ) * 75.0 );
	vec4 fire_color = mix( tip_color, root_color, noise * 0.05 );

	COLOR = vec4( fire_color.rgb, clamp( noise, 0.0, 1.0 ) * fire_alpha );
}
