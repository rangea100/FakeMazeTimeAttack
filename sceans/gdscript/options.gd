extends Panel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fullscreen_control: CheckButton = $"TabContainer/画面/FullscreenControl"
@onready var resolutioncontrol: OptionButton = $"TabContainer/画面/resolutioncontrol"
@onready var map_controal: CheckButton = $"TabContainer/ゲーム/mapControal"
@onready var sensitivity: HSlider = $TabContainer/ゲーム/sensitivity
@onready var graphics_preset: OptionButton = $TabContainer/画面/GraphicsPreset
var ui_on:bool=  false
signal option_offed
func _ready() -> void:
	fullscreen_control.button_pressed = Settings.fullscreen_mode
	resolutioncontrol.selected = Settings.resoltion_nomber
	map_controal.button_pressed = Settings.map_rotaition
	sensitivity.value = Settings.sensitivity
	$"TabContainer/開発者特権/developerMode".button_pressed = Settings.develoer_mode
	$TabContainer.set_tab_hidden(3,true)
	graphics_preset.selected = Settings.graphics
	ui_on = true
func _process(delta: float) -> void:
	if Input.is_action_pressed("commemd") or Settings.develoer_mode:
		$TabContainer.set_tab_hidden(3,false)
	else:
		$TabContainer.set_tab_hidden(3,true)
func _on_fullscreen_control_toggled(toggled_on: bool) -> void:
	if ui_on:
		AudioManager.play_SE("res://assets/sound/select.mp3")
	Settings.fullscreen_mode = toggled_on
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_resolutioncontrol_item_selected(index: int) -> void:
	if ui_on:
		AudioManager.play_SE("res://assets/sound/select.mp3")
	Settings.resoltion_nomber = index
	var viewport_wide = [1152,1280,1920]
	var viewport_high = [628,720,1080]
	var old_size = DisplayServer.window_get_size()
	var old_pos = DisplayServer.window_get_position()
	var new_size =	Vector2i(viewport_wide[index],viewport_high[index])
	# 新旧サイズの差分
	var diff = new_size - old_size

	# 中心を保つように位置を調整（左上をずらす）
	var new_pos = old_pos - diff / 2

	# 先に位置を設定 → その後サイズを設定
	DisplayServer.window_set_position(new_pos)

	DisplayServer.window_set_size(new_size)

func _on_back_option_pressed() -> void:
	if ui_on:
		AudioManager.play_SE("res://assets/sound/off.mp3")
	animation_player.play("option_off")
	await animation_player.animation_finished
	visible = false
	option_offed.emit()
func on_option() -> void:
	visible = true
	animation_player.play("option_on")


func _on_map_controal_toggled(toggled_on: bool) -> void:
	Settings.map_rotaition = toggled_on
	if ui_on:
		AudioManager.play_SE("res://assets/sound/select.mp3")


func _on_tab_container_tab_changed(tab: int) -> void:
	AudioManager.play_SE("res://assets/sound/select.mp3")
	pass


func _on_sensitivity_value_changed(value: float) -> void:
	Settings.sensitivity = value


func _on_developer_mode_toggled(toggled_on: bool) -> void:
	Settings.develoer_mode = toggled_on
	if ui_on:
		AudioManager.play_SE("res://assets/sound/select.mp3")



func _on_graphics_preset_item_selected(index: int) -> void:
	Settings.graphics = index
	AudioManager.play_SE("res://assets/sound/select.mp3")
	match index:
		0:
			Settings.set_preset("res://sceans/resource/performance_preset.tres")
		1:
			Settings.set_preset("res://sceans/resource/balanced_preset.tres")
		2:
			Settings.set_preset("res://sceans/resource/quality_preset.tres")
