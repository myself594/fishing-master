extends Control
## 主菜单界面

var selected_pond: String = ""

# UI 引用
var gold_label: Label
var level_label: Label
var exp_bar: ProgressBar
var ponds_container: VBoxContainer
var bottom_bar: HBoxContainer

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_update_display()

func _setup_ui() -> void:
	# 根节点设置
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# 背景
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.15, 0.2, 0.25)
	add_child(bg)
	
	# 主布局
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)
	
	# === 顶部状态栏 ===
	var top_bar = _create_top_bar()
	main_vbox.add_child(top_bar)
	
	# === 标题 ===
	var title_container = CenterContainer.new()
	title_container.custom_minimum_size.y = 120
	main_vbox.add_child(title_container)
	
	var title = Label.new()
	title.text = "🎣 钓鱼大师"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	title_container.add_child(title)
	
	# === 钓场选择区域 ===
	var ponds_scroll = ScrollContainer.new()
	ponds_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(ponds_scroll)
	
	ponds_container = VBoxContainer.new()
	ponds_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ponds_container.add_theme_constant_override("separation", 20)
	ponds_scroll.add_child(ponds_container)
	
	var ponds_margin = MarginContainer.new()
	ponds_margin.add_theme_constant_override("margin_left", 40)
	ponds_margin.add_theme_constant_override("margin_right", 40)
	ponds_margin.add_theme_constant_override("margin_top", 20)
	ponds_margin.add_theme_constant_override("margin_bottom", 20)
	
	# 移动ponds_container到margin内
	ponds_scroll.remove_child(ponds_container)
	ponds_margin.add_child(ponds_container)
	ponds_scroll.add_child(ponds_margin)
	
	_create_pond_cards()
	
	# === 底部导航栏 ===
	bottom_bar = _create_bottom_bar()
	main_vbox.add_child(bottom_bar)

func _create_top_bar() -> Control:
	var bar = PanelContainer.new()
	bar.custom_minimum_size.y = 80
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.15, 0.2)
	bar.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	bar.add_child(hbox)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(margin)
	
	var content = HBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(content)
	
	# 头像和等级
	var avatar_box = HBoxContainer.new()
	avatar_box.add_theme_constant_override("separation", 10)
	content.add_child(avatar_box)
	
	var avatar = ColorRect.new()
	avatar.custom_minimum_size = Vector2(50, 50)
	avatar.color = Color(0.3, 0.5, 0.7)
	avatar_box.add_child(avatar)
	
	var level_vbox = VBoxContainer.new()
	avatar_box.add_child(level_vbox)
	
	level_label = Label.new()
	level_label.text = "Lv.1"
	level_label.add_theme_font_size_override("font_size", 24)
	level_vbox.add_child(level_label)
	
	exp_bar = ProgressBar.new()
	exp_bar.custom_minimum_size = Vector2(100, 10)
	exp_bar.show_percentage = false
	exp_bar.value = 0
	level_vbox.add_child(exp_bar)
	
	# 占位
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)
	
	# 金币显示
	gold_label = Label.new()
	gold_label.text = "💰 0"
	gold_label.add_theme_font_size_override("font_size", 28)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	content.add_child(gold_label)
	
	return bar

func _create_pond_cards() -> void:
	var ponds = PondDatabase.get_all_ponds()
	
	for pond in ponds:
		var card = _create_pond_card(pond)
		ponds_container.add_child(card)

func _create_pond_card(pond: Dictionary) -> Control:
	var card = Button.new()
	card.custom_minimum_size = Vector2(0, 180)
	card.set_meta("pond_id", pond.id)
	card.pressed.connect(_on_pond_selected.bind(pond.id))
	
	# 卡片样式
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = pond.background_color
	style_normal.corner_radius_top_left = 15
	style_normal.corner_radius_top_right = 15
	style_normal.corner_radius_bottom_left = 15
	style_normal.corner_radius_bottom_right = 15
	card.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = pond.background_color.lightened(0.1)
	card.add_theme_stylebox_override("hover", style_hover)
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = pond.background_color.darkened(0.1)
	card.add_theme_stylebox_override("pressed", style_pressed)
	
	# 卡片内容
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	card.add_child(margin)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 8)
	margin.add_child(content_vbox)
	
	# 钓场名称
	var name_label = Label.new()
	name_label.text = pond.name
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	content_vbox.add_child(name_label)
	
	# 描述
	var desc_label = Label.new()
	desc_label.text = pond.description
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 0.8))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	content_vbox.add_child(desc_label)
	
	# 信息行
	var info_hbox = HBoxContainer.new()
	info_hbox.add_theme_constant_override("separation", 30)
	content_vbox.add_child(info_hbox)
	
	# 入场费
	var fee_label = Label.new()
	if pond.entry_fee > 0:
		fee_label.text = "💰 %d" % pond.entry_fee
	else:
		fee_label.text = "免费"
	fee_label.add_theme_font_size_override("font_size", 20)
	fee_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	info_hbox.add_child(fee_label)
	
	# 鱼种数
	var fish_label = Label.new()
	fish_label.text = "🐟 %d种" % pond.fish_count
	fish_label.add_theme_font_size_override("font_size", 20)
	info_hbox.add_child(fish_label)
	
	# 难度
	var diff_label = Label.new()
	diff_label.text = "⭐".repeat(pond.difficulty)
	diff_label.add_theme_font_size_override("font_size", 20)
	info_hbox.add_child(diff_label)
	
	# 锁定状态
	var is_locked = PlayerData.level < pond.unlock_level
	if is_locked:
		# 添加锁定遮罩
		var lock_overlay = ColorRect.new()
		lock_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		lock_overlay.color = Color(0, 0, 0, 0.6)
		lock_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(lock_overlay)
		
		var lock_label = Label.new()
		lock_label.set_anchors_preset(Control.PRESET_CENTER)
		lock_label.text = "🔒 需要 Lv.%d" % pond.unlock_level
		lock_label.add_theme_font_size_override("font_size", 24)
		lock_label.add_theme_color_override("font_color", Color.WHITE)
		card.add_child(lock_label)
		
		card.disabled = true
	
	return card

func _create_bottom_bar() -> HBoxContainer:
	var container = PanelContainer.new()
	container.custom_minimum_size.y = 100
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.15)
	container.add_theme_stylebox_override("panel", style)
	
	var bar = HBoxContainer.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.add_theme_constant_override("separation", 40)
	container.add_child(bar)
	
	# 按钮数据
	var buttons_data = [
		{"icon": "🎣", "text": "钓鱼", "action": "_on_fishing_pressed"},
		{"icon": "🏪", "text": "商店", "action": "_on_shop_pressed"},
		{"icon": "📚", "text": "图鉴", "action": "_on_fish_book_pressed"},
		{"icon": "🏆", "text": "排行", "action": "_on_ranking_pressed"},
	]
	
	for data in buttons_data:
		var btn = _create_nav_button(data.icon, data.text)
		btn.pressed.connect(Callable(self, data.action))
		bar.add_child(btn)
	
	# 包装返回
	var wrapper = HBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# 重新组织结构
	var final_container = PanelContainer.new()
	final_container.custom_minimum_size.y = 100
	final_container.add_theme_stylebox_override("panel", style)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	final_container.add_child(center)
	center.add_child(bar)
	
	return bar

func _create_nav_button(icon: String, text: String) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(80, 70)
	btn.flat = true
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.add_child(vbox)
	
	var icon_label = Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override("font_size", 32)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon_label)
	
	var text_label = Label.new()
	text_label.text = text
	text_label.add_theme_font_size_override("font_size", 16)
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(text_label)
	
	return btn

func _connect_signals() -> void:
	PlayerData.gold_changed.connect(_on_gold_changed)
	PlayerData.exp_changed.connect(_on_exp_changed)
	PlayerData.level_up.connect(_on_level_up)

func _update_display() -> void:
	gold_label.text = "💰 %d" % PlayerData.gold
	level_label.text = "Lv.%d" % PlayerData.level
	exp_bar.value = PlayerData.get_exp_progress() * 100

func _on_gold_changed(new_amount: int) -> void:
	gold_label.text = "💰 %d" % new_amount

func _on_exp_changed(new_exp: int, new_level: int) -> void:
	exp_bar.value = PlayerData.get_exp_progress() * 100
	level_label.text = "Lv.%d" % new_level

func _on_level_up(new_level: int) -> void:
	# 刷新钓场解锁状态
	for child in ponds_container.get_children():
		child.queue_free()
	_create_pond_cards()

func _on_pond_selected(pond_id: String) -> void:
	selected_pond = pond_id
	AudioManager.play_sfx(AudioManager.SFX.BUTTON)
	
	var pond = PondDatabase.get_pond(pond_id)
	if pond.is_empty():
		return
	
	# 检查金币
	if PlayerData.gold < pond.entry_fee:
		_show_message("金币不足！需要 %d 金币" % pond.entry_fee)
		return
	
	# 开始钓鱼
	GameManager.start_fishing(pond_id)

func _on_fishing_pressed() -> void:
	# 已在主页，可以提示选择钓场
	_show_message("请选择一个钓场开始钓鱼")

func _on_shop_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.BUTTON)
	GameManager.change_scene("shop")

func _on_fish_book_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.BUTTON)
	GameManager.change_scene("fish_book")

func _on_ranking_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.BUTTON)
	GameManager.change_scene("ranking")

func _show_message(text: String) -> void:
	# 简单的消息提示
	var popup = AcceptDialog.new()
	popup.dialog_text = text
	popup.title = "提示"
	add_child(popup)
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)
