extends Control
## 图鉴界面

var progress_label: Label

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
	
	# 进度显示
	var progress_bar = _create_progress_bar()
	main_vbox.add_child(progress_bar)
	
	# 鱼类列表
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(grid)
	
	# 添加鱼类卡片
	var all_fish = FishDatabase.get_all_fish()
	for fish in all_fish:
		var card = _create_fish_card(fish)
		grid.add_child(card)

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
	title.text = "📚 鱼类图鉴"
	title.add_theme_font_size_override("font_size", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(title)
	
	# 占位
	var spacer = Control.new()
	spacer.custom_minimum_size.x = 80
	hbox.add_child(spacer)
	
	return bar

func _create_progress_bar() -> Control:
	var container = PanelContainer.new()
	container.custom_minimum_size.y = 50
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.14, 0.16)
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
	
	progress_label = Label.new()
	var total = FishDatabase.get_fish_count()
	var unlocked = PlayerData.unlocked_fish.size()
	progress_label.text = "收集进度: %d / %d" % [unlocked, total]
	progress_label.add_theme_font_size_override("font_size", 18)
	hbox.add_child(progress_label)
	
	var progress = ProgressBar.new()
	progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress.max_value = total
	progress.value = unlocked
	progress.show_percentage = false
	progress.custom_minimum_size.y = 20
	hbox.add_child(progress)
	
	return container

func _create_fish_card(fish: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(210, 150)
	
	var is_unlocked = PlayerData.is_fish_unlocked(fish.id)
	
	var style = StyleBoxFlat.new()
	if is_unlocked:
		style.bg_color = Color(0.2, 0.25, 0.3)
	else:
		style.bg_color = Color(0.15, 0.15, 0.15)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)
	
	# 鱼图标（色块）
	var icon_center = CenterContainer.new()
	vbox.add_child(icon_center)
	
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(60, 40)
	if is_unlocked:
		icon.color = fish.get("color", Color.GRAY)
	else:
		icon.color = Color(0.3, 0.3, 0.3)
	icon_center.add_child(icon)
	
	# 鱼名
	var name_label = Label.new()
	if is_unlocked:
		name_label.text = fish.name
		var quality_color = GameManager.get_quality_color(fish.quality)
		name_label.add_theme_color_override("font_color", quality_color)
	else:
		name_label.text = "???"
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	
	# 信息
	if is_unlocked:
		var info_label = Label.new()
		info_label.text = "%.1f-%.1fkg" % [fish.min_weight, fish.max_weight]
		info_label.add_theme_font_size_override("font_size", 12)
		info_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(info_label)
		
		var price_label = Label.new()
		price_label.text = "💰 %d" % fish.base_price
		price_label.add_theme_font_size_override("font_size", 12)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(price_label)
	else:
		var hint_label = Label.new()
		hint_label.text = "未解锁"
		hint_label.add_theme_font_size_override("font_size", 12)
		hint_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(hint_label)
	
	return card

func _on_back_pressed() -> void:
	GameManager.return_to_menu()
