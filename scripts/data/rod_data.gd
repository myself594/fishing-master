extends Node
## 鱼竿数据库

# 品质枚举
enum Quality { NORMAL = 0, EXCELLENT = 1, RARE = 2 }

# 鱼竿数据
var rod_list: Array = [
	{
		"id": "bamboo",
		"name": "新手竹竿",
		"quality": Quality.NORMAL,
		"price": 0,  # 初始赠送
		"cast_distance": 1.0,  # 抛竿距离倍率
		"tension_bonus": 0,    # 张力上限加成
		"luck_bonus": 0,       # 幸运加成
		"description": "每个钓鱼大师的起点",
		"color": Color(0.6, 0.5, 0.3),
	},
	{
		"id": "carbon_rod",
		"name": "碳素鱼竿",
		"quality": Quality.EXCELLENT,
		"price": 500,
		"cast_distance": 1.2,
		"tension_bonus": 10,
		"luck_bonus": 0,
		"description": "轻便耐用，适合进阶钓手",
		"color": Color(0.3, 0.3, 0.35),
	},
	{
		"id": "battle_rod",
		"name": "战斗竿",
		"quality": Quality.RARE,
		"price": 2000,
		"cast_distance": 1.5,
		"tension_bonus": 20,
		"luck_bonus": 5,
		"description": "专为大鱼设计的硬竿",
		"color": Color(0.2, 0.4, 0.8),
	},
]

func get_rod(rod_id: String) -> Dictionary:
	for rod in rod_list:
		if rod.id == rod_id:
			return rod.duplicate()
	return {}

func get_all_rods() -> Array:
	var result = []
	for rod in rod_list:
		result.append(rod.duplicate())
	return result

func get_rod_quality_color(quality: int) -> Color:
	match quality:
		Quality.NORMAL: return Color.WHITE
		Quality.EXCELLENT: return Color.GREEN
		Quality.RARE: return Color.DODGER_BLUE
		_: return Color.WHITE
