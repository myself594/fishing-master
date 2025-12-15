extends Control
## 结算界面

func _ready() -> void:
	_setup_ui()
	AudioManager.play_sfx(AudioManager.SFX.CATCH)

func _setup_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var fish = GameManager.current_fish
	var is_success = fish.get("success", false)
	
	# 背景
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	if is_success:
		bg.color = Color(0.1, 0.2, 0.15)
	else:
		bg.color = Color(0.2, 0.1, 0.1)
	add_child(bg)
	
	# 主布局
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 30)
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(main_vbox)
	
	# 标题
	var title = Label.new()
	if is_success:
		title.text = "🎉 钓鱼成功！"
		title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	else:
		title.text = "😢 钓鱼失败"
		title.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	title.add_theme_font_size_override("font_size", 42)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title)
	
	if is_success and not fish.is_empty():
		# 鱼的信息卡片
		var card = _create_fish_card(fish)
		main_vbox.add_child(card)
		
		# 奖励信息
		var reward_box = _create_reward_box(fish)
		main_vbox.add_child(reward_box)
		
		# 完美提竿提示
		if fish.get("perfect_hook", false):
			var perfect_label = Label.new()
			perfect_label.text = "⭐ 完美提竿！经验+50%"
			perfect_label.add_theme_font_size_override("font_size", 20)
			perfect_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
			perfect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			main_vbox.add_child(perfect_label)
	
	# 按钮
	var btn_hbox = HBoxContainer.new()
	btn_hbox.add_theme_constant_override("separation", 30)
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(btn_hbox)
	
	var continue_btn = Button.new()
	continue_btn.text = "继续钓鱼"
	continue_btn.custom_minimum_size = Vector2(150, 60)
	continue_btn.add_theme_font_size_override("font_size", 22)
	continue_btn.pressed.connect(_on_continue_pressed)
	btn_hbox.add_child(continue_btn)
	
	var return_btn = Button.new()
	return_btn.text = "返回主页"
	return_btn.custom_minimum_size = Vector2(150, 60)
	return_btn.add_theme_font_size_override("font_size", 22)
	return_btn.pressed.connect(_on_return_pressed)
	btn_hbox.add_child(return_btn)

func _create_fish_card(fish: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(350, 200)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.2, 0.25)
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	card.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	card.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)
	
	# 鱼图标
	var icon_center = CenterContainer.new()
	vbox.add_child(icon_center)
	
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(100, 60)
	icon.color = fish.get("color", Color.GRAY)
	icon_center.add_child(icon)
	
	# 鱼名
	var name_label = Label.new()
	var quality_name = GameManager.get_quality_name(fish.get("quality", 0))
	name_label.text = "%s (%s)" % [fish.get("name", "未知鱼"), quality_name]
	name_label.add_theme_font_size_override("font_size", 28)
	var quality_color = GameManager.get_quality_color(fish.get("quality", 0))
	name_label.add_theme_color_override("font_color", quality_color)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	
	# 重量
	var weight_label = Label.new()
	weight_label.text = "%.2f kg" % fish.get("weight", 0.0)
	weight_label.add_theme_font_size_override("font_size", 24)
	weight_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(weight_label)
	
	return card

func _create_reward_box(fish: Dictionary) -> Control:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 50)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# 金币奖励
	var gold_vbox = VBoxContainer.new()
	gold_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(gold_vbox)
	
	var gold_icon = Label.new()
	gold_icon.text = "💰"
	gold_icon.add_theme_font_size_override("font_size", 40)
	gold_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_vbox.add_child(gold_icon)
	
	var gold_value = Label.new()
	gold_value.text = "+%d" % fish.get("gold_reward", 0)
	gold_value.add_theme_font_size_override("font_size", 28)
	gold_value.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	gold_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_vbox.add_child(gold_value)
	
	# 经验奖励
	var exp_vbox = VBoxContainer.new()
	exp_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(exp_vbox)
	
	var exp_icon = Label.new()
	exp_icon.text = "⭐"
	exp_icon.add_theme_font_size_override("font_size", 40)
	exp_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exp_vbox.add_child(exp_icon)
	
	var exp_reward = fish.get("exp_reward", 0)
	if fish.get("perfect_hook", false):
		exp_reward = int(exp_reward * 1.5)
	
	var exp_value = Label.new()
	exp_value.text = "+%d" % exp_reward
	exp_value.add_theme_font_size_override("font_size", 28)
	exp_value.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	exp_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exp_vbox.add_child(exp_value)
	
	return hbox

func _on_continue_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.BUTTON)
	# 返回钓鱼场景
	GameManager.change_scene("fishing")

func _on_return_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.BUTTON)
	GameManager.return_to_menu()
