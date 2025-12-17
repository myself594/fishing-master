shader_type canvas_item;

// 水面涟漪效果参数
uniform float wave_speed : hint_range(0.5, 5.0) = 2.0;
uniform float wave_strength : hint_range(0.001, 0.02) = 0.005;
uniform float wave_frequency : hint_range(5.0, 50.0) = 20.0;

void fragment() {
    vec2 uv = UV;

    // 水面涟漪效果
    float offset_y = sin(uv.x * wave_frequency + TIME * wave_speed) * wave_strength;
    float offset_x = cos(uv.y * wave_frequency + TIME * wave_speed) * wave_strength * 0.5;

    // 只在水面区域（下方2/3）应用效果
    if (uv.y > 0.33) {
        uv.y += offset_y;
        uv.x += offset_x;
    }

    COLOR = texture(TEXTURE, uv);
}
