extends Control
## 排行榜界面（MVP版本使用模拟数据）

# 模拟好友数据
var mock_friends: Array = [
	{"name": "钓鱼达人", "gold": 8520, "avatar_color": Color(0.8, 0.3, 0.3)},
	{"name": "太公后人", "gold": 6340, "avatar_color": Color(0.3, 0.8, 0.3)},
	{"name": "渔夫小王", "gold": 5210, "avatar_color": Color(0.3, 0.3, 0.8)},
	{"name": "钓神附体", "gold": 4880, "avatar_color": Color(0.8, 0.8, 0.3)},
	{"name": "悠闲垂钓", "gold": 3650, "avatar_color": Color(0.8, 0.3, 0.8)},
	{"name": "野钓爱好者", "gold": 2990, "avatar_color": Color(0.3, 0.8, 0.8)},
	{"name": "周末钓手", "gold": 1820, "avatar_color": Color(0.6, 0.4, 0.2)},
]

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# 背景
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.12, 0.15)
	add_child(bg)
	
	# 主布局
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)
	
	# 顶部栏
	var top_bar = _create_top_bar()
	main_vbox.add_child(top_bar)
	
	# 我的排名
	var my_rank = _create_my_rank()
	main_vbox.add_child(my_rank)
	
	# 分割线
	var sep = HSeparator.new()
	main_vbox.add_child(sep)
	
	# 排行列表
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	
	var list = VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(list)
	
	# 生成排行榜数据
	var ranking_data = _generate_ranking_data()
	
	for i in range(ranking_data.size()):
		var item = _create_rank_item(i + 1, ranking_data[i])
		list.add_child(item)

func _create_top_bar() -> Control:
	var bar = PanelContainer.new()
	bar.custom_minimum_size.y = 70
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.12)
	bar.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	bar.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(hbox)
	
	# 返回按钮
	var back_btn = Button.new()
	back_btn.text = "← 返回"
	back_btn.pressed.connect(_on_back_pressed)
	hbox.add_child(back_btn)
	
	# 标题
	var title = Label.new()
	title.text = "🏆 好友排行榜"
	title.add_theme_font_size_override("font_size", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(title)
	
	# 周期说明
	var period = Label.new()
	period.text = "本周"
	period.add_theme_font_size_override("font_size", 16)
	period.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	hbox.add_child(period)
	
	return bar

func _create_my_rank() -> Control:
	var container = PanelContainer.new()
	container.custom_minimum_size.y = 80
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.2, 0.25)
	container.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	container.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	margin.add_child(hbox)
	
	# 我的排名
	var my_rank = _get_my_rank()
	var rank_label = Label.new()
	rank_label.text = "第 %d 名" % my_rank
	rank_label.add_theme_font_size_override("font_size", 24)
	rank_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	rank_label.custom_minimum_size.x = 100
	hbox.add_child(rank_label)
	
	# 头像
	var avatar = ColorRect.new()
	avatar.custom_minimum_size = Vector2(50, 50)
	avatar.color = Color(0.3, 0.5, 0.7)
	hbox.add_child(avatar)
	
	# 名字和收益
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	var name_label = Label.new()
	name_label.text = "我 (Lv.%d)" % PlayerData.level
	name_label.add_theme_font_size_override("font_size", 20)
	info_vbox.add_child(name_label)
	
	var gold_label = Label.new()
	gold_label.text = "本周收益: 💰 %d" % PlayerData.weekly_gold_earned
	gold_label.add_theme_font_size_override("font_size", 16)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	info_vbox.add_child(gold_label)
	
	return container

func _create_rank_item(rank: int, data: Dictionary) -> Control:
	var item = PanelContainer.new()
	item.custom_minimum_size = Vector2(0, 70)
	
	var style = StyleBoxFlat.new()
	if data.get("is_me", false):
		style.bg_color = Color(0.2, 0.25, 0.3)
	else:
		style.bg_color = Color(0.15, 0.17, 0.2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	item.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	item.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	margin.add_child(hbox)
	
	# 排名
	var rank_label = Label.new()
	match rank:
		1: rank_label.text = "🥇"
		2: rank_label.text = "🥈"
		3: rank_label.text = "🥉"
		_: rank_label.text = str(rank)
	rank_label.add_theme_font_size_override("font_size", 24)
	rank_label.custom_minimum_size.x = 50
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(rank_label)
	
	# 头像
	var avatar = ColorRect.new()
	avatar.custom_minimum_size = Vector2(45, 45)
	avatar.color = data.get("avatar_color", Color.GRAY)
	hbox.add_child(avatar)
	
	# 名字
	var name_label = Label.new()
	name_label.text = data.name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if data.get("is_me", false):
		name_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	hbox.add_child(name_label)
	
	# 收益
	var gold_label = Label.new()
	gold_label.text = "💰 %d" % data.gold
	gold_label.add_theme_font_size_override("font_size", 18)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	hbox.add_child(gold_label)
	
	return item

func _generate_ranking_data() -> Array:
	var data = mock_friends.duplicate(true)
	
	# 加入玩家数据
	data.append({
		"name": "我",
		"gold": PlayerData.weekly_gold_earned,
		"avatar_color": Color(0.3, 0.5, 0.7),
		"is_me": true
	})
	
	# 按金币排序
	data.sort_custom(func(a, b): return a.gold > b.gold)
	
	return data

func _get_my_rank() -> int:
	var data = _generate_ranking_data()
	for i in range(data.size()):
		if data[i].get("is_me", false):
			return i + 1
	return data.size()

func _on_back_pressed() -> void:
	GameManager.return_to_menu()
