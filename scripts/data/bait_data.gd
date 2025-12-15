extends Node
## 饵料数据库

var bait_list: Array = [
	{
		"id": "worm",
		"name": "蚯蚓",
		"price": 5,
		"description": "基础饵料，万能通用",
		"effect": "通用饵料",
		"bonus": {},
		"color": Color(0.6, 0.3, 0.3),
	},
	{
		"id": "corn",
		"name": "玉米粒",
		"price": 8,
		"description": "草食鱼的最爱",
		"effect": "草食鱼咬钩率+20%",
		"bonus": {"grass_fish": 0.2},
		"color": Color(1.0, 0.9, 0.3),
	},
	{
		"id": "red_worm",
		"name": "红虫",
		"price": 15,
		"description": "高级饵料，吸引稀有鱼",
		"effect": "稀有鱼概率+10%",
		"bonus": {"rare_bonus": 0.1},
		"color": Color(0.9, 0.2, 0.2),
	},
]

func get_bait(bait_id: String) -> Dictionary:
	for bait in bait_list:
		if bait.id == bait_id:
			return bait.duplicate()
	return {}

func get_all_baits() -> Array:
	var result = []
	for bait in bait_list:
		result.append(bait.duplicate())
	return result
