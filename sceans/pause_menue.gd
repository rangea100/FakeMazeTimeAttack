extends Control
var pause:bool =false
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $options
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var finish_menu: Panel = $finish_menu


func _ready() -> void:
	main_buttons.visible = true
	options.visible = false
	rich_text_label.visible = true


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		if pause == false:
			pause = !pause
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
			show()
		else:
			pause = !pause
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
			hide()


func _on_button_pressed() -> void:
	pause = !pause
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	hide()


func _on_button_2_pressed() -> void:
	main_buttons.visible = false
	rich_text_label.visible = false
	finish_menu.visible = true
	animation_player.play("finish_menu_on")


func _on_setting_pressed() -> void:
	main_buttons.visible = false
	rich_text_label.visible = false
	options.visible = true
	animation_player.play("option_on")


func _on_back_option_pressed() -> void:
	animation_player.play("option_off")
	await animation_player.animation_finished
	main_buttons.visible = true
	rich_text_label.visible = true
	options.visible = false


func _on_fullscreen_control_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_resolutioncontrol_item_selected(index: int) -> void:
	var viewport_wide = [1152,1920]
	var viewport_high = [628,1080]
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


func _on_back_finish_menu_pressed() -> void:
	animation_player.play("finish_menu_off")
	await animation_player.animation_finished
	main_buttons.visible = true
	rich_text_label.visible = true
	finish_menu.visible = false


func _on_finish_pressed() -> void:
	pause = !pause
	SceneManager.change_scene("res://sceans/title.tscn",{"pattern":"fade"})
	get_tree().paused = false
