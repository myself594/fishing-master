shader_type canvas_item;

// 自然水面效果参数
uniform float wave_speed : hint_range(0.1, 2.0) = 0.5;
uniform float wave_strength : hint_range(0.0005, 0.005) = 0.002;
uniform float water_start : hint_range(0.2, 0.5) = 0.33;

// 生成伪随机噪声
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// 平滑噪声
float smooth_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // smoothstep

    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// 多层噪声叠加 (FBM)
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * smooth_noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
    vec2 uv = UV;

    // 只在水面区域应用效果
    if (uv.y > water_start) {
        // 计算水面深度因子（越往下效果越强）
        float depth = (uv.y - water_start) / (1.0 - water_start);
        float strength = wave_strength * depth;

        // 多层波浪叠加，模拟自然水面
        float time = TIME * wave_speed;

        // 第一层：大波浪（慢速）
        float wave1 = sin(uv.x * 8.0 + time * 0.7) * cos(uv.y * 6.0 + time * 0.5);

        // 第二层：中波浪（中速）
        float wave2 = sin(uv.x * 15.0 - time * 1.1) * cos(uv.y * 12.0 + time * 0.8);

        // 第三层：小波纹（快速）
        float wave3 = sin(uv.x * 25.0 + time * 1.5) * cos(uv.y * 20.0 - time * 1.2);

        // 噪声扰动，增加随机性
        float noise_val = fbm(uv * 10.0 + time * 0.3) - 0.5;

        // 组合所有波浪
        float combined = wave1 * 0.5 + wave2 * 0.3 + wave3 * 0.2 + noise_val * 0.3;

        // 应用位移
        uv.x += combined * strength;
        uv.y += combined * strength * 0.5;
    }

    COLOR = texture(TEXTURE, uv);
}
