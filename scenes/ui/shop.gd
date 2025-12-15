extends Control
## 商店界面

var gold_label: Label
var tab_container: TabContainer

func _ready() -> void:
	_setup_ui()
	_update_gold_display()
	PlayerData.gold_changed.connect(_on_gold_changed)

func _setup_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# 背景
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.12, 0.15, 0.18)
	add_child(bg)
	
	# 主布局
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)
	
	# 顶部栏
	var top_bar = _create_top_bar()
	main_vbox.add_child(top_bar)
	
	# Tab容器
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(tab_container)
	
	# 鱼竿标签页
	var rods_scroll = _create_rods_tab()
	rods_scroll.name = "🎣 鱼竿"
	tab_container.add_child(rods_scroll)
	
	# 饵料标签页
	var baits_scroll = _create_baits_tab()
	baits_scroll.name = "🪱 饵料"
	tab_container.add_child(baits_scroll)

func _create_top_bar() -> Control:
	var bar = PanelContainer.new()
	bar.custom_minimum_size.y = 70
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.15)
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
	title.text = "🏪 鱼具店"
	title.add_theme_font_size_override("font_size", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(title)
	
	# 金币
	gold_label = Label.new()
	gold_label.add_theme_font_size_override("font_size", 24)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	hbox.add_child(gold_label)
	
	return bar

func _create_rods_tab() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)
	
	var rods = RodDatabase.get_all_rods()
	for rod in rods:
		var card = _create_rod_card(rod)
		vbox.add_child(card)
	
	return scroll

func _create_rod_card(rod: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 120)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.22, 0.25)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	card.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	margin.add_child(hbox)
	
	# 图标（色块代替）
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(60, 80)
	icon.color = rod.get("color", Color.GRAY)
	hbox.add_child(icon)
	
	# 信息
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 5)
	hbox.add_child(info_vbox)
	
	var name_label = Label.new()
	name_label.text = rod.name
	name_label.add_theme_font_size_override("font_size", 22)
	var quality_color = RodDatabase.get_rod_quality_color(rod.quality)
	name_label.add_theme_color_override("font_color", quality_color)
	info_vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = rod.description
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info_vbox.add_child(desc_label)
	
	var stats_label = Label.new()
	stats_label.text = "距离 ×%.1f | 张力 +%d%%" % [rod.cast_distance, rod.tension_bonus]
	stats_label.add_theme_font_size_override("font_size", 14)
	info_vbox.add_child(stats_label)
	
	# 按钮
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(100, 50)
	hbox.add_child(btn)
	
	var is_owned = rod.id in PlayerData.owned_rods
	var is_equipped = PlayerData.current_rod == rod.id
	
	if is_equipped:
		btn.text = "使用中"
		btn.disabled = true
	elif is_owned:
		btn.text = "装备"
		btn.pressed.connect(_on_equip_rod.bind(rod.id))
	else:
		if rod.price > 0:
			btn.text = "💰 %d" % rod.price
			btn.pressed.connect(_on_buy_rod.bind(rod.id))
		else:
			btn.text = "已拥有"
			btn.disabled = true
	
	return card

func _create_baits_tab() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)
	
	var baits = BaitDatabase.get_all_baits()
	for bait in baits:
		var card = _create_bait_card(bait)
		vbox.add_child(card)
	
	return scroll

func _create_bait_card(bait: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 100)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.22, 0.25)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	card.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	margin.add_child(hbox)
	
	# 图标
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(50, 50)
	icon.color = bait.get("color", Color.GRAY)
	hbox.add_child(icon)
	
	# 信息
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 3)
	hbox.add_child(info_vbox)
	
	var owned_count = PlayerData.owned_baits.get(bait.id, 0)
	
	var name_label = Label.new()
	name_label.text = "%s (持有: %d)" % [bait.name, owned_count]
	name_label.add_theme_font_size_override("font_size", 20)
	info_vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = bait.description
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info_vbox.add_child(desc_label)
	
	var effect_label = Label.new()
	effect_label.text = bait.effect
	effect_label.add_theme_font_size_override("font_size", 14)
	effect_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	info_vbox.add_child(effect_label)
	
	# 购买按钮
	var btn_vbox = VBoxContainer.new()
	btn_vbox.add_theme_constant_override("separation", 5)
	hbox.add_child(btn_vbox)
	
	var buy_10 = Button.new()
	buy_10.text = "×10 💰%d" % (bait.price * 10)
	buy_10.custom_minimum_size = Vector2(120, 35)
	buy_10.pressed.connect(_on_buy_bait.bind(bait.id, 10))
	btn_vbox.add_child(buy_10)
	
	var buy_50 = Button.new()
	buy_50.text = "×50 💰%d" % (bait.price * 50)
	buy_50.custom_minimum_size = Vector2(120, 35)
	buy_50.pressed.connect(_on_buy_bait.bind(bait.id, 50))
	btn_vbox.add_child(buy_50)
	
	return card

func _update_gold_display() -> void:
	gold_label.text = "💰 %d" % PlayerData.gold

func _on_gold_changed(new_amount: int) -> void:
	gold_label.text = "💰 %d" % new_amount

func _on_back_pressed() -> void:
	GameManager.return_to_menu()

func _on_buy_rod(rod_id: String) -> void:
	var rod = RodDatabase.get_rod(rod_id)
	if PlayerData.buy_rod(rod_id):
		AudioManager.play_sfx(AudioManager.SFX.COIN)
		_show_message("购买成功！已获得 %s" % rod.name)
		_refresh_shop()
	else:
		_show_message("金币不足！")

func _on_equip_rod(rod_id: String) -> void:
	PlayerData.equip_rod(rod_id)
	var rod = RodDatabase.get_rod(rod_id)
	_show_message("已装备 %s" % rod.name)
	_refresh_shop()

func _on_buy_bait(bait_id: String, amount: int) -> void:
	var bait = BaitDatabase.get_bait(bait_id)
	if PlayerData.buy_bait(bait_id, amount):
		AudioManager.play_sfx(AudioManager.SFX.COIN)
		_show_message("购买成功！获得 %s ×%d" % [bait.name, amount])
		_refresh_shop()
	else:
		_show_message("金币不足！")

func _refresh_shop() -> void:
	# 重新加载场景
	var current_tab = tab_container.current_tab
	get_tree().reload_current_scene()

func _show_message(text: String) -> void:
	var popup = AcceptDialog.new()
	popup.dialog_text = text
	popup.title = "提示"
	add_child(popup)
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)
