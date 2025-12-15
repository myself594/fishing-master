extends Node
## 工具函数

class_name Helpers

# 格式化数字（加千分位）
static func format_number(num: int) -> String:
	var str_num = str(abs(num))
	var result = ""
	var count = 0
	
	for i in range(str_num.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = str_num[i] + result
		count += 1
	
	if num < 0:
		result = "-" + result
	
	return result

# 格式化时间
static func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [minutes, secs]

# 随机范围内的浮点数（保留小数位）
static func randf_range_decimal(min_val: float, max_val: float, decimals: int = 2) -> float:
	var value = randf_range(min_val, max_val)
	var multiplier = pow(10, decimals)
	return round(value * multiplier) / multiplier

# 概率判定
static func chance(probability: float) -> bool:
	return randf() < probability

# 从数组随机选择
static func random_choice(array: Array) -> Variant:
	if array.is_empty():
		return null
	return array[randi() % array.size()]

# 加权随机选择
static func weighted_random(weights: Array) -> int:
	var total = 0.0
	for w in weights:
		total += w
	
	var random_value = randf() * total
	var cumulative = 0.0
	
	for i in range(weights.size()):
		cumulative += weights[i]
		if random_value <= cumulative:
			return i
	
	return weights.size() - 1

# 线性插值
static func lerp_value(from: float, to: float, weight: float) -> float:
	return from + (to - from) * clamp(weight, 0.0, 1.0)

# 缓动函数 - ease out
static func ease_out(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3)

# 缓动函数 - ease in out
static func ease_in_out(t: float) -> float:
	if t < 0.5:
		return 4 * t * t * t
	else:
		return 1 - pow(-2 * t + 2, 3) / 2
