shader_type canvas_item;

// 水面涟漪效果参数
uniform float wave_speed : hint_range(0.1, 3.0) = 1.0;
uniform float wave_strength : hint_range(0.005, 0.05) = 0.015;
uniform float water_start : hint_range(0.0, 0.5) = 0.33;

void fragment() {
    vec2 uv = UV;

    // 只在水面区域应用效果
    if (uv.y > water_start) {
        // 深度因子：越往下效果越强
        float depth = (uv.y - water_start) / (1.0 - water_start);
        float strength = wave_strength * (0.5 + depth * 0.5);

        float time = TIME * wave_speed;

        // 多层波浪叠加
        float wave1 = sin(uv.x * 10.0 + time) * cos(uv.y * 8.0 + time * 0.8);
        float wave2 = sin(uv.x * 20.0 - time * 1.3) * 0.5;
        float wave3 = cos(uv.y * 15.0 + time * 0.7) * 0.3;

        float combined = wave1 + wave2 + wave3;

        // 应用位移
        uv.x += combined * strength;
        uv.y += combined * strength * 0.3;
    }

    COLOR = texture(TEXTURE, uv);
}
