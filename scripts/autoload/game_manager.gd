extends Node
## 游戏管理器 - 控制游戏状态和场景切换

signal scene_changed(scene_name: String)
signal gold_changed(amount: int)
signal exp_changed(amount: int)
signal level_up(new_level: int)

enum GameState { MENU, FISHING, SHOP, FISH_BOOK, RANKING, SETTLEMENT }

var current_state: GameState = GameState.MENU
var current_pond: String = ""
var current_fish: Dictionary = {}  # 当前钓到的鱼
var is_tutorial_completed: bool = false

# 场景路径
const SCENES = {
	"main_menu": "res://scenes/ui/main_menu.tscn",
	"fishing": "res://scenes/ui/fishing_scene.tscn",
	"shop": "res://scenes/ui/shop.tscn",
	"fish_book": "res://scenes/ui/fish_book.tscn",
	"ranking": "res://scenes/ui/ranking.tscn",
	"settlement": "res://scenes/ui/settlement.tscn",
}

func _ready() -> void:
	# 加载存档
	PlayerData.load_game()
	is_tutorial_completed = PlayerData.get_data("tutorial_completed", false)

func change_scene(scene_name: String) -> void:
	if SCENES.has(scene_name):
		get_tree().change_scene_to_file(SCENES[scene_name])
		scene_changed.emit(scene_name)

func start_fishing(pond_id: String) -> bool:
	var pond = PondDatabase.get_pond(pond_id)
	if pond.is_empty():
		return false
	
	# 检查等级
	if PlayerData.level < pond.unlock_level:
		return false
	
	# 检查金币（扣除入场费）
	if not PlayerData.spend_gold(pond.entry_fee):
		return false
	
	current_pond = pond_id
	current_state = GameState.FISHING
	change_scene("fishing")
	return true

func finish_fishing(fish: Dictionary, is_success: bool) -> void:
	current_fish = fish
	current_fish["success"] = is_success
	
	if is_success and not fish.is_empty():
		# 计算奖励
		var gold_reward = calculate_gold_reward(fish)
		var exp_reward = calculate_exp_reward(fish)
		
		current_fish["gold_reward"] = gold_reward
		current_fish["exp_reward"] = exp_reward
		
		# 发放奖励
		PlayerData.add_gold(gold_reward)
		PlayerData.add_exp(exp_reward)
		
		# 解锁图鉴
		PlayerData.unlock_fish(fish.id)
	
	current_state = GameState.SETTLEMENT
	change_scene("settlement")

func calculate_gold_reward(fish: Dictionary) -> int:
	var base_price = fish.get("base_price", 10)
	var weight = fish.get("weight", 0.1)
	var quality_multiplier = get_quality_multiplier(fish.get("quality", 0))
	
	return int(base_price * weight * quality_multiplier)

func calculate_exp_reward(fish: Dictionary) -> int:
	var quality = fish.get("quality", 0)
	match quality:
		0: return 5   # 普通
		1: return 15  # 优秀
		2: return 50  # 稀有
		_: return 5

func get_quality_multiplier(quality: int) -> float:
	match quality:
		0: return 1.0   # 普通
		1: return 2.0   # 优秀
		2: return 5.0   # 稀有
		_: return 1.0

func get_quality_name(quality: int) -> String:
	match quality:
		0: return "普通"
		1: return "优秀"
		2: return "稀有"
		_: return "普通"

func get_quality_color(quality: int) -> Color:
	match quality:
		0: return Color.WHITE
		1: return Color.GREEN
		2: return Color.DODGER_BLUE
		_: return Color.WHITE

func complete_tutorial() -> void:
	is_tutorial_completed = true
	PlayerData.set_data("tutorial_completed", true)
	PlayerData.save_game()

func return_to_menu() -> void:
	current_state = GameState.MENU
	current_pond = ""
	current_fish = {}
	change_scene("main_menu")
