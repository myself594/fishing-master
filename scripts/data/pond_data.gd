extends Node
## 钓场数据库

var pond_list: Array = [
	{
		"id": "lotus_pond",
		"name": "新手村·荷花池",
		"description": "宁静的乡村小池塘，荷花点缀，柳树依依",
		"unlock_level": 1,
		"entry_fee": 0,
		"difficulty": 1,
		"fish_count": 8,
		"background_color": Color(0.2, 0.5, 0.3),  # 绿色调
		"water_color": Color(0.3, 0.6, 0.5, 0.8),
		"special": "失败不扣饵料（前3次），咬钩率+50%",
		"bite_rate_bonus": 0.5,
		"newbie_protection": true,
	},
	{
		"id": "taihu",
		"name": "江南·太湖",
		"description": "烟波浩渺太湖水，吴中第一鱼米乡",
		"unlock_level": 5,
		"entry_fee": 50,
		"difficulty": 2,
		"fish_count": 10,
		"background_color": Color(0.3, 0.4, 0.5),  # 蓝灰色调
		"water_color": Color(0.2, 0.4, 0.6, 0.8),
		"special": "可钓到太湖三白（银鱼、白鱼、白虾）",
		"bite_rate_bonus": 0.0,
		"newbie_protection": false,
	},
]

func get_pond(pond_id: String) -> Dictionary:
	for pond in pond_list:
		if pond.id == pond_id:
			return pond.duplicate()
	return {}

func get_all_ponds() -> Array:
	var result = []
	for pond in pond_list:
		result.append(pond.duplicate())
	return result

func is_pond_unlocked(pond_id: String, player_level: int) -> bool:
	var pond = get_pond(pond_id)
	if pond.is_empty():
		return false
	return player_level >= pond.unlock_level

func get_unlocked_ponds(player_level: int) -> Array:
	var result = []
	for pond in pond_list:
		if player_level >= pond.unlock_level:
			result.append(pond.duplicate())
	return result
