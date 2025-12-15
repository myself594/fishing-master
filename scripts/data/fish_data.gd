extends Node
## 鱼类数据库 - 包含所有鱼的数据

# 品质枚举
enum Quality { NORMAL = 0, EXCELLENT = 1, RARE = 2 }

# 鱼类数据结构
# {
#   id: String,
#   name: String,
#   quality: int,
#   min_weight: float,
#   max_weight: float,
#   base_price: int,
#   stamina: int,        # 体力值（遛鱼难度）
#   pond: String,        # 所属钓场
#   probability: float,  # 出现概率权重
#   preferred_bait: String,  # 偏好饵料
#   color: Color,        # 显示颜色
# }

var fish_list: Array = [
	# ===== 荷花池 =====
	{
		"id": "small_crucian",
		"name": "小鲫鱼",
		"quality": Quality.NORMAL,
		"min_weight": 0.1,
		"max_weight": 0.3,
		"base_price": 10,
		"stamina": 20,
		"pond": "lotus_pond",
		"probability": 30.0,
		"preferred_bait": "worm",
		"color": Color(0.8, 0.8, 0.8),
	},
	{
		"id": "crucian",
		"name": "鲫鱼",
		"quality": Quality.NORMAL,
		"min_weight": 0.3,
		"max_weight": 0.8,
		"base_price": 25,
		"stamina": 35,
		"pond": "lotus_pond",
		"probability": 25.0,
		"preferred_bait": "worm",
		"color": Color(0.9, 0.85, 0.7),
	},
	{
		"id": "small_grass_carp",
		"name": "小草鱼",
		"quality": Quality.NORMAL,
		"min_weight": 0.5,
		"max_weight": 1.0,
		"base_price": 30,
		"stamina": 40,
		"pond": "lotus_pond",
		"probability": 20.0,
		"preferred_bait": "corn",
		"color": Color(0.5, 0.7, 0.5),
	},
	{
		"id": "loach",
		"name": "泥鳅",
		"quality": Quality.NORMAL,
		"min_weight": 0.05,
		"max_weight": 0.2,
		"base_price": 15,
		"stamina": 25,
		"pond": "lotus_pond",
		"probability": 20.0,
		"preferred_bait": "worm",
		"color": Color(0.4, 0.35, 0.3),
	},
	{
		"id": "shrimp",
		"name": "小虾",
		"quality": Quality.NORMAL,
		"min_weight": 0.02,
		"max_weight": 0.05,
		"base_price": 5,
		"stamina": 10,
		"pond": "lotus_pond",
		"probability": 25.0,
		"preferred_bait": "worm",
		"color": Color(1.0, 0.6, 0.5),
	},
	{
		"id": "golden_crucian",
		"name": "黄金鲫",
		"quality": Quality.EXCELLENT,
		"min_weight": 0.5,
		"max_weight": 1.0,
		"base_price": 80,
		"stamina": 50,
		"pond": "lotus_pond",
		"probability": 8.0,
		"preferred_bait": "corn",
		"color": Color(1.0, 0.85, 0.0),
	},
	{
		"id": "red_carp",
		"name": "红鲤鱼",
		"quality": Quality.EXCELLENT,
		"min_weight": 1.0,
		"max_weight": 2.0,
		"base_price": 100,
		"stamina": 60,
		"pond": "lotus_pond",
		"probability": 6.0,
		"preferred_bait": "corn",
		"color": Color(1.0, 0.3, 0.2),
	},
	{
		"id": "koi",
		"name": "锦鲤",
		"quality": Quality.RARE,
		"min_weight": 1.0,
		"max_weight": 3.0,
		"base_price": 300,
		"stamina": 80,
		"pond": "lotus_pond",
		"probability": 2.0,
		"preferred_bait": "red_worm",
		"color": Color(1.0, 0.5, 0.0),
	},
	# ===== 太湖 =====
	{
		"id": "grass_carp",
		"name": "草鱼",
		"quality": Quality.NORMAL,
		"min_weight": 1.0,
		"max_weight": 3.0,
		"base_price": 50,
		"stamina": 55,
		"pond": "taihu",
		"probability": 25.0,
		"preferred_bait": "corn",
		"color": Color(0.4, 0.6, 0.4),
	},
	{
		"id": "common_carp",
		"name": "鲤鱼",
		"quality": Quality.NORMAL,
		"min_weight": 1.0,
		"max_weight": 4.0,
		"base_price": 60,
		"stamina": 60,
		"pond": "taihu",
		"probability": 22.0,
		"preferred_bait": "corn",
		"color": Color(0.7, 0.5, 0.3),
	},
	{
		"id": "bream",
		"name": "鳊鱼",
		"quality": Quality.NORMAL,
		"min_weight": 0.5,
		"max_weight": 1.5,
		"base_price": 40,
		"stamina": 45,
		"pond": "taihu",
		"probability": 20.0,
		"preferred_bait": "worm",
		"color": Color(0.6, 0.65, 0.7),
	},
	{
		"id": "white_fish",
		"name": "白鱼",
		"quality": Quality.EXCELLENT,
		"min_weight": 0.3,
		"max_weight": 1.0,
		"base_price": 120,
		"stamina": 50,
		"pond": "taihu",
		"probability": 10.0,
		"preferred_bait": "red_worm",
		"color": Color(0.95, 0.95, 1.0),
	},
	{
		"id": "silver_fish",
		"name": "银鱼",
		"quality": Quality.EXCELLENT,
		"min_weight": 0.1,
		"max_weight": 0.3,
		"base_price": 150,
		"stamina": 30,
		"pond": "taihu",
		"probability": 8.0,
		"preferred_bait": "red_worm",
		"color": Color(0.9, 0.92, 0.95),
	},
	{
		"id": "black_carp",
		"name": "大青鱼",
		"quality": Quality.RARE,
		"min_weight": 3.0,
		"max_weight": 8.0,
		"base_price": 500,
		"stamina": 100,
		"pond": "taihu",
		"probability": 3.0,
		"preferred_bait": "red_worm",
		"color": Color(0.2, 0.25, 0.3),
	},
	{
		"id": "taihu_crab",
		"name": "太湖蟹",
		"quality": Quality.RARE,
		"min_weight": 0.2,
		"max_weight": 0.5,
		"base_price": 400,
		"stamina": 40,
		"pond": "taihu",
		"probability": 2.0,
		"preferred_bait": "red_worm",
		"color": Color(0.8, 0.4, 0.2),
	},
]

func _ready() -> void:
	pass

func get_fish(fish_id: String) -> Dictionary:
	for fish in fish_list:
		if fish.id == fish_id:
			return fish.duplicate()
	return {}

func get_fish_by_pond(pond_id: String) -> Array:
	var result = []
	for fish in fish_list:
		if fish.pond == pond_id:
			result.append(fish.duplicate())
	return result

func get_random_fish(pond_id: String, bait_id: String, distance_ratio: float) -> Dictionary:
	var pond_fish = get_fish_by_pond(pond_id)
	if pond_fish.is_empty():
		return {}
	
	# 计算概率权重
	var total_weight = 0.0
	var weighted_fish = []
	
	for fish in pond_fish:
		var weight = fish.probability
		
		# 偏好饵料加成
		if fish.preferred_bait == bait_id:
			weight *= 1.3
		
		# 距离影响：远距离增加大鱼概率
		if fish.quality == Quality.RARE:
			weight *= (0.5 + distance_ratio)
		elif fish.quality == Quality.EXCELLENT:
			weight *= (0.7 + distance_ratio * 0.5)
		
		total_weight += weight
		weighted_fish.append({"fish": fish, "weight": weight})
	
	# 随机选择
	var random_value = randf() * total_weight
	var cumulative = 0.0
	
	for item in weighted_fish:
		cumulative += item.weight
		if random_value <= cumulative:
			var selected_fish = item.fish.duplicate()
			# 随机重量
			selected_fish["weight"] = randf_range(selected_fish.min_weight, selected_fish.max_weight)
			selected_fish["weight"] = snapped(selected_fish["weight"], 0.01)
			return selected_fish
	
	# 兜底返回第一条
	var fallback = pond_fish[0].duplicate()
	fallback["weight"] = randf_range(fallback.min_weight, fallback.max_weight)
	return fallback

func get_all_fish() -> Array:
	var result = []
	for fish in fish_list:
		result.append(fish.duplicate())
	return result

func get_fish_count() -> int:
	return fish_list.size()

func get_fish_count_by_pond(pond_id: String) -> int:
	var count = 0
	for fish in fish_list:
		if fish.pond == pond_id:
			count += 1
	return count
