shader_type canvas_item;

uniform float density = 10;

void fragment() {
    if (mod(UV.x * density, 1.0) > 0.5) {
        discard;
    }
}