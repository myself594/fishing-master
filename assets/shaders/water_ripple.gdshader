shader_type canvas_item;

// 噪声纹理
uniform sampler2D noise_texture : repeat_enable, filter_linear;

// 水面效果参数
uniform float wave_speed : hint_range(0.01, 0.5) = 0.08;
uniform float wave_strength : hint_range(0.001, 0.03) = 0.008;
uniform float water_start : hint_range(0.0, 0.5) = 0.3;
uniform float refraction_strength : hint_range(0.0, 0.02) = 0.005;

// 双层水波，不同速度和方向
uniform vec2 wave_direction_1 = vec2(1.0, 0.3);
uniform vec2 wave_direction_2 = vec2(-0.5, 1.0);
uniform float wave_scale_1 : hint_range(0.5, 3.0) = 1.0;
uniform float wave_scale_2 : hint_range(0.5, 3.0) = 1.5;

void fragment() {
    vec2 uv = UV;

    // 只在水面区域应用效果
    if (uv.y > water_start) {
        // 深度因子：越往下效果越强
        float depth = (uv.y - water_start) / (1.0 - water_start);
        float strength = wave_strength * (0.3 + depth * 0.7);

        // 计算两层噪声采样的 UV 偏移（不同方向和速度）
        vec2 noise_uv_1 = uv * wave_scale_1 + wave_direction_1 * TIME * wave_speed;
        vec2 noise_uv_2 = uv * wave_scale_2 + wave_direction_2 * TIME * wave_speed * 0.7;

        // 采样噪声纹理（两层叠加更自然）
        float noise_1 = texture(noise_texture, noise_uv_1).r;
        float noise_2 = texture(noise_texture, noise_uv_2).r;

        // 混合两层噪声，转换到 -1 到 1 范围
        float combined_noise = (noise_1 * 0.6 + noise_2 * 0.4) * 2.0 - 1.0;

        // 计算折射偏移
        vec2 distortion = vec2(
            combined_noise * strength,
            combined_noise * strength * 0.5
        );

        // 添加轻微的水平波动
        distortion.x += sin(uv.y * 20.0 + TIME * 2.0) * refraction_strength * depth;

        // 应用扭曲
        uv += distortion;

        // 确保 UV 不越界
        uv = clamp(uv, vec2(0.001), vec2(0.999));
    }

    COLOR = texture(TEXTURE, uv);
}
