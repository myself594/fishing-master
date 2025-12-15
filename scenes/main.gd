extends Control
## 主入口场景 - 启动后跳转到主菜单

func _ready() -> void:
	# 设置全屏
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	
	# 等待一帧确保autoload加载完成
	await get_tree().process_frame
	
	# 跳转到主菜单
	GameManager.change_scene("main_menu")
