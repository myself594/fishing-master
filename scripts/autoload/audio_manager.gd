extends Node
## 音频管理器 - 控制游戏音效（MVP版本暂用占位）

var sfx_enabled: bool = true
var music_enabled: bool = true
var sfx_volume: float = 1.0
var music_volume: float = 0.8

# 音效类型
enum SFX {
	CAST,       # 抛竿
	SPLASH,     # 落水
	BITE,       # 咬钩
	REEL,       # 收线
	CATCH,      # 钓到
	FAIL,       # 失败
	BUTTON,     # 按钮
	COIN,       # 金币
	LEVEL_UP,   # 升级
}

func play_sfx(sfx_type: SFX) -> void:
	if not sfx_enabled:
		return
	# MVP版本暂不实现实际音效，仅打印日志
	match sfx_type:
		SFX.CAST:
			print("[SFX] 抛竿音效")
		SFX.SPLASH:
			print("[SFX] 落水音效")
		SFX.BITE:
			print("[SFX] 咬钩音效")
		SFX.REEL:
			print("[SFX] 收线音效")
		SFX.CATCH:
			print("[SFX] 钓到音效")
		SFX.FAIL:
			print("[SFX] 失败音效")
		SFX.BUTTON:
			print("[SFX] 按钮音效")
		SFX.COIN:
			print("[SFX] 金币音效")
		SFX.LEVEL_UP:
			print("[SFX] 升级音效")

func play_music(music_name: String) -> void:
	if not music_enabled:
		return
	print("[Music] 播放背景音乐: ", music_name)

func stop_music() -> void:
	print("[Music] 停止背景音乐")

func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled

func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if not enabled:
		stop_music()

func vibrate() -> void:
	# 手机震动
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(100)
	print("[Vibrate] 震动反馈")
