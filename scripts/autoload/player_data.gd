extends Node
## 玩家数据管理器 - 负责玩家存档和数据

signal gold_changed(new_amount: int)
signal exp_changed(new_exp: int, new_level: int)
signal level_up(new_level: int)
signal fish_unlocked(fish_id: String)

const SAVE_PATH = "user://save_data.json"

# 等级经验表
const LEVEL_EXP = [0, 100, 250, 450, 750, 1150, 1650, 2250, 3050, 4050, 999999]

# 玩家数据
var gold: int = 500  # 初始金币
var exp: int = 0
var level: int = 1
var nickname: String = "钓鱼新手"

# 装备
var current_rod: String = "bamboo"  # 当前鱼竿
var current_bait: String = "worm"   # 当前饵料
var bait_count: int = 20            # 饵料数量

# 拥有的装备
var owned_rods: Array = ["bamboo"]
var owned_baits: Dictionary = {"worm": 20}

# 图鉴
var unlocked_fish: Array = []

# 统计
var total_fish_caught: int = 0
var total_gold_earned: int = 0
var weekly_gold_earned: int = 0
var biggest_fish_weight: float = 0.0

# 任务进度
var tasks_completed: Array = []
var tasks_progress: Dictionary = {}

# 其他数据
var extra_data: Dictionary = {}

func _ready() -> void:
	load_game()

func add_gold(amount: int) -> void:
	gold += amount
	total_gold_earned += amount
	weekly_gold_earned += amount
	gold_changed.emit(gold)
	save_game()

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		save_game()
		return true
	return false

func add_exp(amount: int) -> void:
	exp += amount
	check_level_up()
	exp_changed.emit(exp, level)
	save_game()

func check_level_up() -> void:
	while level < LEVEL_EXP.size() - 1 and exp >= LEVEL_EXP[level]:
		level += 1
		level_up.emit(level)
		# 升级奖励
		add_gold(level * 50)

func get_exp_progress() -> float:
	if level >= LEVEL_EXP.size() - 1:
		return 1.0
	var current_level_exp = LEVEL_EXP[level - 1] if level > 1 else 0
	var next_level_exp = LEVEL_EXP[level]
	var progress_exp = exp - current_level_exp
	var needed_exp = next_level_exp - current_level_exp
	return float(progress_exp) / float(needed_exp)

func get_exp_to_next_level() -> int:
	if level >= LEVEL_EXP.size() - 1:
		return 0
	return LEVEL_EXP[level] - exp

func unlock_fish(fish_id: String) -> void:
	if fish_id not in unlocked_fish:
		unlocked_fish.append(fish_id)
		fish_unlocked.emit(fish_id)
		save_game()

func is_fish_unlocked(fish_id: String) -> bool:
	return fish_id in unlocked_fish

func buy_rod(rod_id: String) -> bool:
	var rod = RodDatabase.get_rod(rod_id)
	if rod.is_empty():
		return false
	if rod_id in owned_rods:
		return false
	if not spend_gold(rod.price):
		return false
	owned_rods.append(rod_id)
	save_game()
	return true

func equip_rod(rod_id: String) -> bool:
	if rod_id in owned_rods:
		current_rod = rod_id
		save_game()
		return true
	return false

func buy_bait(bait_id: String, amount: int) -> bool:
	var bait = BaitDatabase.get_bait(bait_id)
	if bait.is_empty():
		return false
	var total_cost = bait.price * amount
	if not spend_gold(total_cost):
		return false
	if owned_baits.has(bait_id):
		owned_baits[bait_id] += amount
	else:
		owned_baits[bait_id] = amount
	save_game()
	return true

func use_bait() -> bool:
	if owned_baits.has(current_bait) and owned_baits[current_bait] > 0:
		owned_baits[current_bait] -= 1
		bait_count = owned_baits[current_bait]
		save_game()
		return true
	return false

func get_current_bait_count() -> int:
	return owned_baits.get(current_bait, 0)

func equip_bait(bait_id: String) -> bool:
	if owned_baits.has(bait_id) and owned_baits[bait_id] > 0:
		current_bait = bait_id
		bait_count = owned_baits[bait_id]
		save_game()
		return true
	return false

func complete_task(task_id: String, reward_gold: int) -> void:
	if task_id not in tasks_completed:
		tasks_completed.append(task_id)
		add_gold(reward_gold)
		save_game()

func is_task_completed(task_id: String) -> bool:
	return task_id in tasks_completed

func update_task_progress(task_id: String, progress: int) -> void:
	tasks_progress[task_id] = progress
	save_game()

func get_task_progress(task_id: String) -> int:
	return tasks_progress.get(task_id, 0)

func increment_fish_caught() -> void:
	total_fish_caught += 1
	save_game()

func update_biggest_fish(weight: float) -> void:
	if weight > biggest_fish_weight:
		biggest_fish_weight = weight
		save_game()

func set_data(key: String, value: Variant) -> void:
	extra_data[key] = value
	save_game()

func get_data(key: String, default: Variant = null) -> Variant:
	return extra_data.get(key, default)

func save_game() -> void:
	var save_data = {
		"gold": gold,
		"exp": exp,
		"level": level,
		"nickname": nickname,
		"current_rod": current_rod,
		"current_bait": current_bait,
		"bait_count": bait_count,
		"owned_rods": owned_rods,
		"owned_baits": owned_baits,
		"unlocked_fish": unlocked_fish,
		"total_fish_caught": total_fish_caught,
		"total_gold_earned": total_gold_earned,
		"weekly_gold_earned": weekly_gold_earned,
		"biggest_fish_weight": biggest_fish_weight,
		"tasks_completed": tasks_completed,
		"tasks_progress": tasks_progress,
		"extra_data": extra_data,
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			gold = data.get("gold", 500)
			exp = data.get("exp", 0)
			level = data.get("level", 1)
			nickname = data.get("nickname", "钓鱼新手")
			current_rod = data.get("current_rod", "bamboo")
			current_bait = data.get("current_bait", "worm")
			bait_count = data.get("bait_count", 20)
			owned_rods = data.get("owned_rods", ["bamboo"])
			owned_baits = data.get("owned_baits", {"worm": 20})
			unlocked_fish = data.get("unlocked_fish", [])
			total_fish_caught = data.get("total_fish_caught", 0)
			total_gold_earned = data.get("total_gold_earned", 0)
			weekly_gold_earned = data.get("weekly_gold_earned", 0)
			biggest_fish_weight = data.get("biggest_fish_weight", 0.0)
			tasks_completed = data.get("tasks_completed", [])
			tasks_progress = data.get("tasks_progress", {})
			extra_data = data.get("extra_data", {})

func reset_weekly() -> void:
	weekly_gold_earned = 0
	save_game()

func reset_all() -> void:
	gold = 500
	exp = 0
	level = 1
	nickname = "钓鱼新手"
	current_rod = "bamboo"
	current_bait = "worm"
	bait_count = 20
	owned_rods = ["bamboo"]
	owned_baits = {"worm": 20}
	unlocked_fish = []
	total_fish_caught = 0
	total_gold_earned = 0
	weekly_gold_earned = 0
	biggest_fish_weight = 0.0
	tasks_completed = []
	tasks_progress = {}
	extra_data = {}
	save_game()
