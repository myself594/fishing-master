extends Control
## 钓鱼场景 - 核心玩法

enum FishingState { IDLE, CASTING, WAITING, BITE, HOOKING, FIGHTING, SUCCESS, FAIL }

var current_state: FishingState = FishingState.IDLE
var pond_data: Dictionary = {}
var current_fish: Dictionary = {}

# 抛竿相关
var cast_power: float = 0.0
var cast_power_direction: int = 1  # 力度条方向
var cast_distance: float = 0.0
const CAST_POWER_SPEED: float = 1.5

# 等待咬钩相关
var wait_timer: float = 0.0
var bite_time: float = 0.0
var bite_window: float = 1.5  # 咬钩判定窗口

# 遛鱼相关
var fish_stamina: float = 100.0
var line_tension: float = 0.0
var is_pulling: bool = false
const TENSION_INCREASE_RATE: float = 35.0
const TENSION_DECREASE_RATE: float = 25.0
const STAMINA_DECREASE_RATE: float = 20.0
const STAMINA_RECOVER_RATE: float = 5.0

# UI 元素
var power_bar: ProgressBar
var float_sprite: ColorRect  # 浮漂（用色块代替）
var fish_stamina_bar: ProgressBar
var line_tension_bar: ProgressBar
var status_label: Label
var bait_label: Label
var instruction_label: Label
var water_rect: ColorRect
var fishing_line: Line2D
var background_texture: TextureRect
var ambient_player: AudioStreamPlayer

# 动画相关
var float_base_y: float = 0.0
var float_bob_time: float = 0.0

func _ready() -> void:
	pond_data = PondDatabase.get_pond(GameManager.current_pond)
	_setup_ui()
	_start_idle()

func _process(delta: float) -> void:
	match current_state:
		FishingState.IDLE:
			_process_idle(delta)
		FishingState.CASTING:
			_process_casting(delta)
		FishingState.WAITING:
			_process_waiting(delta)
		FishingState.BITE:
			_process_bite(delta)
		FishingState.FIGHTING:
			_process_fighting(delta)
	
	_update_float_animation(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		var pressed = false
		if event is InputEventScreenTouch:
			pressed = event.pressed
		elif event is InputEventMouseButton:
			pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
		
		match current_state:
			FishingState.IDLE:
				if pressed:
					_start_casting()
			FishingState.CASTING:
				if not pressed:
					_finish_casting()
			FishingState.BITE:
				if pressed:
					_try_hook()
			FishingState.FIGHTING:
				is_pulling = pressed

func _setup_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# 背景（优先使用背景图片）
	var bg_image_path = pond_data.get("background_image", "")
	if bg_image_path != "" and ResourceLoader.exists(bg_image_path):
		# 使用背景图片
		background_texture = TextureRect.new()
		background_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
		background_texture.texture = load(bg_image_path)
		background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

		# 应用水面涟漪 Shader
		var shader_material = ShaderMaterial.new()
		var shader = load("res://assets/shaders/water_ripple.gdshader")
		var noise_tex = load("res://assets/textures/water_noise.tres")
		if shader and noise_tex:
			shader_material.shader = shader
			# 设置噪声纹理
			shader_material.set_shader_parameter("noise_texture", noise_tex)
			# 设置 Shader 参数
			shader_material.set_shader_parameter("wave_speed", 0.08)
			shader_material.set_shader_parameter("wave_strength", 0.008)
			shader_material.set_shader_parameter("water_start", 0.3)  # 上方30%无效果
			shader_material.set_shader_parameter("refraction_strength", 0.005)
			background_texture.material = shader_material
			print("水面涟漪 Shader 已加载（带噪声纹理）")
		else:
			print("警告：无法加载水面涟漪 Shader 或噪声纹理")

		add_child(background_texture)

		# 创建透明水面区域（用于兼容现有代码）
		water_rect = ColorRect.new()
		water_rect.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		water_rect.anchor_top = 0.4
		water_rect.color = Color(0, 0, 0, 0)  # 透明
		add_child(water_rect)
	else:
		# 使用色块背景（备用）
		var bg = ColorRect.new()
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.color = pond_data.get("background_color", Color(0.2, 0.4, 0.3))
		add_child(bg)

		# 天空渐变（上半部分）
		var sky = ColorRect.new()
		sky.set_anchors_preset(Control.PRESET_TOP_WIDE)
		sky.anchor_bottom = 0.4
		sky.color = Color(0.4, 0.6, 0.8)
		add_child(sky)

		# 水面
		water_rect = ColorRect.new()
		water_rect.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		water_rect.anchor_top = 0.4
		water_rect.color = pond_data.get("water_color", Color(0.2, 0.5, 0.6, 0.9))
		add_child(water_rect)

	# 播放环境音效（循环）
	var ambient_path = pond_data.get("ambient_sound", "")
	if ambient_path != "" and ResourceLoader.exists(ambient_path):
		ambient_player = AudioStreamPlayer.new()
		ambient_player.stream = load(ambient_path)
		ambient_player.volume_db = -10  # 降低音量作为背景音
		ambient_player.autoplay = true
		ambient_player.finished.connect(_on_ambient_finished)
		add_child(ambient_player)

	# 钓鱼线
	fishing_line = Line2D.new()
	fishing_line.width = 2.0
	fishing_line.default_color = Color(0.3, 0.3, 0.3)
	add_child(fishing_line)
	
	# 浮漂
	float_sprite = ColorRect.new()
	float_sprite.custom_minimum_size = Vector2(20, 40)
	float_sprite.size = Vector2(20, 40)
	float_sprite.color = Color(1.0, 0.2, 0.1)
	float_sprite.position = Vector2(360, 500)
	float_sprite.visible = false
	add_child(float_sprite)
	float_base_y = float_sprite.position.y
	
	# 顶部信息栏
	var top_bar = _create_top_bar()
	add_child(top_bar)
	
	# 力度条（抛竿时显示）
	var power_container = CenterContainer.new()
	power_container.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	power_container.anchor_top = 0.7
	power_container.anchor_bottom = 0.75
	add_child(power_container)
	
	var power_vbox = VBoxContainer.new()
	power_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	power_container.add_child(power_vbox)
	
	var power_label = Label.new()
	power_label.text = "力度"
	power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	power_vbox.add_child(power_label)
	
	power_bar = ProgressBar.new()
	power_bar.custom_minimum_size = Vector2(300, 30)
	power_bar.max_value = 100
	power_bar.value = 0
	power_bar.show_percentage = false
	power_vbox.add_child(power_bar)
	power_bar.visible = false
	power_label.visible = false
	power_bar.get_parent().get_parent().set_meta("power_label", power_label)
	
	# 遛鱼UI
	var fight_container = VBoxContainer.new()
	fight_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	fight_container.anchor_top = 0.15
	fight_container.anchor_bottom = 0.35
	fight_container.custom_minimum_size = Vector2(350, 150)
	fight_container.add_theme_constant_override("separation", 15)
	add_child(fight_container)
	fight_container.visible = false
	fight_container.name = "FightUI"
	
	var fish_name_label = Label.new()
	fish_name_label.name = "FishNameLabel"
	fish_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fish_name_label.add_theme_font_size_override("font_size", 24)
	fight_container.add_child(fish_name_label)
	
	# 鱼体力
	var stamina_hbox = HBoxContainer.new()
	stamina_hbox.add_theme_constant_override("separation", 10)
	fight_container.add_child(stamina_hbox)
	
	var stamina_label = Label.new()
	stamina_label.text = "🐟 鱼体力"
	stamina_label.custom_minimum_size.x = 100
	stamina_hbox.add_child(stamina_label)
	
	fish_stamina_bar = ProgressBar.new()
	fish_stamina_bar.custom_minimum_size = Vector2(200, 25)
	fish_stamina_bar.max_value = 100
	fish_stamina_bar.value = 100
	fish_stamina_bar.show_percentage = false
	stamina_hbox.add_child(fish_stamina_bar)
	
	# 线张力
	var tension_hbox = HBoxContainer.new()
	tension_hbox.add_theme_constant_override("separation", 10)
	fight_container.add_child(tension_hbox)
	
	var tension_label = Label.new()
	tension_label.text = "⚡ 线张力"
	tension_label.custom_minimum_size.x = 100
	tension_hbox.add_child(tension_label)
	
	line_tension_bar = ProgressBar.new()
	line_tension_bar.custom_minimum_size = Vector2(200, 25)
	line_tension_bar.max_value = 100
	line_tension_bar.value = 0
	line_tension_bar.show_percentage = false
	tension_hbox.add_child(line_tension_bar)
	
	# 操作提示
	instruction_label = Label.new()
	instruction_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	instruction_label.anchor_top = 0.82
	instruction_label.anchor_bottom = 0.88
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	instruction_label.add_theme_font_size_override("font_size", 24)
	instruction_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(instruction_label)
	
	# 状态标签
	status_label = Label.new()
	status_label.set_anchors_preset(Control.PRESET_CENTER)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 36)
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	status_label.visible = false
	add_child(status_label)
	
	# 底部按钮栏
	var bottom_bar = _create_bottom_bar()
	add_child(bottom_bar)

func _create_top_bar() -> Control:
	var bar = PanelContainer.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.custom_minimum_size.y = 60
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
	bar.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	bar.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(hbox)
	
	# 钓场名
	var pond_label = Label.new()
	pond_label.text = pond_data.get("name", "未知钓场")
	pond_label.add_theme_font_size_override("font_size", 20)
	hbox.add_child(pond_label)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)
	
	# 饵料显示
	bait_label = Label.new()
	var bait = BaitDatabase.get_bait(PlayerData.current_bait)
	var bait_count = PlayerData.get_current_bait_count()
	bait_label.text = "%s ×%d" % [bait.get("name", "饵料"), bait_count]
	bait_label.add_theme_font_size_override("font_size", 18)
	hbox.add_child(bait_label)
	
	return bar

func _create_bottom_bar() -> Control:
	var bar = PanelContainer.new()
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.custom_minimum_size.y = 80
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
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
	back_btn.text = "返回"
	back_btn.custom_minimum_size = Vector2(100, 50)
	back_btn.pressed.connect(_on_back_pressed)
	hbox.add_child(back_btn)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)
	
	# 更换饵料按钮
	var bait_btn = Button.new()
	bait_btn.text = "换饵"
	bait_btn.custom_minimum_size = Vector2(100, 50)
	bait_btn.pressed.connect(_on_change_bait_pressed)
	hbox.add_child(bait_btn)
	
	return bar

# ===== 状态处理 =====

func _start_idle() -> void:
	current_state = FishingState.IDLE
	float_sprite.visible = false
	instruction_label.text = "长按屏幕蓄力抛竿"
	_update_fishing_line(false)

func _process_idle(_delta: float) -> void:
	pass

func _start_casting() -> void:
	# 检查饵料
	if PlayerData.get_current_bait_count() <= 0:
		_show_message("饵料不足！请购买饵料")
		return
	
	current_state = FishingState.CASTING
	cast_power = 0.0
	cast_power_direction = 1
	power_bar.visible = true
	power_bar.get_parent().get_parent().get_meta("power_label").visible = true
	instruction_label.text = "松手抛竿"
	AudioManager.play_sfx(AudioManager.SFX.CAST)

func _process_casting(delta: float) -> void:
	# 力度条来回摆动
	cast_power += CAST_POWER_SPEED * 100 * delta * cast_power_direction
	if cast_power >= 100:
		cast_power = 100
		cast_power_direction = -1
	elif cast_power <= 0:
		cast_power = 0
		cast_power_direction = 1
	
	power_bar.value = cast_power

func _finish_casting() -> void:
	power_bar.visible = false
	power_bar.get_parent().get_parent().get_meta("power_label").visible = false
	
	# 计算抛竿距离
	var rod = RodDatabase.get_rod(PlayerData.current_rod)
	cast_distance = (cast_power / 100.0) * rod.get("cast_distance", 1.0)
	
	# 消耗饵料
	PlayerData.use_bait()
	_update_bait_display()
	
	# 显示浮漂
	float_sprite.visible = true
	var float_x = 200 + cast_distance * 300  # 根据力度计算位置
	float_sprite.position.x = float_x
	float_base_y = 480 + (1.0 - cast_power / 100.0) * 50
	float_sprite.position.y = float_base_y
	
	_update_fishing_line(true)
	
	AudioManager.play_sfx(AudioManager.SFX.SPLASH)
	
	# 进入等待状态
	_start_waiting()

func _start_waiting() -> void:
	current_state = FishingState.WAITING
	
	# 随机咬钩时间（3-15秒）
	var base_time = randf_range(3.0, 15.0)
	# 钓场加成
	var bite_bonus = pond_data.get("bite_rate_bonus", 0.0)
	bite_time = base_time * (1.0 - bite_bonus * 0.3)
	wait_timer = 0.0
	
	instruction_label.text = "等待咬钩..."

func _process_waiting(delta: float) -> void:
	wait_timer += delta
	
	if wait_timer >= bite_time:
		_trigger_bite()

func _trigger_bite() -> void:
	current_state = FishingState.BITE
	
	# 随机生成鱼
	current_fish = FishDatabase.get_random_fish(
		pond_data.id,
		PlayerData.current_bait,
		cast_distance
	)
	
	# 咬钩提示
	AudioManager.play_sfx(AudioManager.SFX.BITE)
	AudioManager.vibrate()
	
	instruction_label.text = "⚠️ 鱼咬钩了！点击提竿！"
	status_label.text = "!"
	status_label.visible = true
	
	# 开始咬钩计时
	wait_timer = 0.0
	bite_window = 1.5  # 1.5秒判定窗口

func _process_bite(delta: float) -> void:
	wait_timer += delta
	
	# 浮漂下沉动画
	float_sprite.position.y = float_base_y + sin(wait_timer * 15) * 10 + 20
	
	if wait_timer > bite_window:
		# 超时，鱼跑了
		_fishing_fail("提竿太慢，鱼跑了！")

func _try_hook() -> void:
	status_label.visible = false
	
	if wait_timer < 0.3:
		# 太早
		_fishing_fail("提竿太早，鱼跑了！")
	elif wait_timer <= bite_window:
		# 成功提竿
		var is_perfect = wait_timer >= 0.5 and wait_timer <= 0.8
		_start_fighting(is_perfect)
	else:
		# 太晚（理论上不会执行到这里）
		_fishing_fail("提竿太慢，鱼跑了！")

func _start_fighting(is_perfect: bool) -> void:
	current_state = FishingState.FIGHTING
	
	# 初始化遛鱼数据
	fish_stamina = current_fish.get("stamina", 50)
	line_tension = 0.0
	is_pulling = false
	
	# 完美提竿加成
	if is_perfect:
		current_fish["perfect_hook"] = true
		fish_stamina *= 0.8  # 鱼体力降低20%
	
	# 显示遛鱼UI
	var fight_ui = get_node("FightUI")
	fight_ui.visible = true
	
	var fish_name = current_fish.get("name", "未知鱼")
	var quality_name = GameManager.get_quality_name(current_fish.get("quality", 0))
	var quality_color = GameManager.get_quality_color(current_fish.get("quality", 0))
	
	var name_label = fight_ui.get_node("FishNameLabel")
	name_label.text = "🐟 %s (%s)" % [fish_name, quality_name]
	name_label.add_theme_color_override("font_color", quality_color)
	
	fish_stamina_bar.max_value = current_fish.get("stamina", 50)
	fish_stamina_bar.value = fish_stamina
	line_tension_bar.value = 0
	
	instruction_label.text = "按住拉鱼 / 松开休息"

func _process_fighting(delta: float) -> void:
	var rod = RodDatabase.get_rod(PlayerData.current_rod)
	var tension_bonus = rod.get("tension_bonus", 0)
	var max_tension = 100 + tension_bonus
	
	if is_pulling:
		# 拉鱼：消耗鱼体力，增加线张力
		fish_stamina -= STAMINA_DECREASE_RATE * delta
		line_tension += TENSION_INCREASE_RATE * delta
		AudioManager.play_sfx(AudioManager.SFX.REEL)
	else:
		# 休息：线张力下降，鱼缓慢恢复体力
		line_tension -= TENSION_DECREASE_RATE * delta
		fish_stamina += STAMINA_RECOVER_RATE * delta
	
	# 限制范围
	fish_stamina = clamp(fish_stamina, 0, current_fish.get("stamina", 50))
	line_tension = clamp(line_tension, 0, max_tension)
	
	# 更新UI
	fish_stamina_bar.value = fish_stamina
	line_tension_bar.value = line_tension
	
	# 判定结果
	if fish_stamina <= 0:
		_fishing_success()
	elif line_tension >= max_tension:
		_fishing_fail("线断了！")

func _fishing_success() -> void:
	current_state = FishingState.SUCCESS
	
	get_node("FightUI").visible = false
	float_sprite.visible = false
	
	AudioManager.play_sfx(AudioManager.SFX.CATCH)
	
	# 更新统计
	PlayerData.increment_fish_caught()
	PlayerData.update_biggest_fish(current_fish.get("weight", 0.0))
	
	# 跳转结算
	GameManager.finish_fishing(current_fish, true)

func _fishing_fail(reason: String) -> void:
	current_state = FishingState.FAIL
	
	get_node("FightUI").visible = false
	status_label.visible = false
	
	AudioManager.play_sfx(AudioManager.SFX.FAIL)
	
	# 新手保护：荷花池前3次不扣饵料
	if pond_data.get("newbie_protection", false):
		var fail_count = PlayerData.get_data("lotus_fail_count", 0)
		if fail_count < 3:
			PlayerData.set_data("lotus_fail_count", fail_count + 1)
			# 返还饵料
			PlayerData.owned_baits[PlayerData.current_bait] = PlayerData.owned_baits.get(PlayerData.current_bait, 0) + 1
			PlayerData.save_game()
	
	_show_fail_dialog(reason)

func _show_fail_dialog(reason: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "钓鱼失败"
	dialog.dialog_text = reason + "\n\n再试一次？"
	dialog.get_ok_button().text = "继续"
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(_on_fail_continue)

func _on_fail_continue() -> void:
	_start_idle()

# ===== 辅助函数 =====

func _update_float_animation(delta: float) -> void:
	if not float_sprite.visible:
		return
	
	if current_state == FishingState.WAITING:
		float_bob_time += delta
		float_sprite.position.y = float_base_y + sin(float_bob_time * 2) * 5

func _update_fishing_line(show: bool) -> void:
	if show and float_sprite.visible:
		var start_pos = Vector2(100, 100)  # 鱼竿位置
		var end_pos = float_sprite.position + Vector2(10, 0)
		fishing_line.points = [start_pos, end_pos]
		fishing_line.visible = true
	else:
		fishing_line.visible = false

func _update_bait_display() -> void:
	var bait = BaitDatabase.get_bait(PlayerData.current_bait)
	var bait_count = PlayerData.get_current_bait_count()
	bait_label.text = "%s ×%d" % [bait.get("name", "饵料"), bait_count]

func _show_message(text: String) -> void:
	var popup = AcceptDialog.new()
	popup.dialog_text = text
	popup.title = "提示"
	add_child(popup)
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)

func _on_back_pressed() -> void:
	GameManager.return_to_menu()

func _on_change_bait_pressed() -> void:
	# 简单的饵料切换对话框
	var dialog = AcceptDialog.new()
	dialog.title = "选择饵料"
	
	var vbox = VBoxContainer.new()
	dialog.add_child(vbox)
	
	var baits = BaitDatabase.get_all_baits()
	for bait in baits:
		var count = PlayerData.owned_baits.get(bait.id, 0)
		if count > 0:
			var btn = Button.new()
			btn.text = "%s ×%d" % [bait.name, count]
			btn.pressed.connect(func():
				PlayerData.equip_bait(bait.id)
				_update_bait_display()
				dialog.queue_free()
			)
			vbox.add_child(btn)
	
	if vbox.get_child_count() == 0:
		dialog.dialog_text = "没有可用饵料！请去商店购买。"

	add_child(dialog)
	dialog.popup_centered()

func _on_ambient_finished() -> void:
	# 环境音效循环播放
	if ambient_player:
		ambient_player.play()
