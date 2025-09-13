extends Control
var pause:bool =false
var can_pause:bool = true
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
	if Input.is_action_just_pressed("esc") and can_pause:
		if pause == false:
			pause = !pause
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
			show()
			AudioManager.play_SE("res://assets/sound/on.mp3")
		else:
			pause = !pause
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
			hide()
			AudioManager.play_SE("res://assets/sound/off.mp3")
			Settings.apply_preset_safe(Settings.preset)
			SignalManager.on_game_restart.emit()


func _on_button_pressed() -> void:
	pause = !pause
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	hide()
	AudioManager.play_SE("res://assets/sound/off.mp3")
	Settings.apply_preset_safe(Settings.preset)
	SignalManager.on_game_restart.emit()


func _on_button_2_pressed() -> void:
	main_buttons.visible = false
	rich_text_label.visible = false
	finish_menu.visible = true
	AudioManager.play_SE("res://assets/sound/check.mp3")
	animation_player.play("finish_menu_on")


func _on_setting_pressed() -> void:
	main_buttons.visible = false
	rich_text_label.visible = false
	options.on_option()
	AudioManager.play_SE("res://assets/sound/select.mp3")


func _on_options_option_offed() -> void:
	main_buttons.visible = true
	rich_text_label.visible = true



func _on_back_finish_menu_pressed() -> void:
	AudioManager.play_SE("res://assets/sound/off.mp3")
	animation_player.play("finish_menu_off")
	await animation_player.animation_finished
	main_buttons.visible = true
	rich_text_label.visible = true
	finish_menu.visible = false

func _on_finish_pressed() -> void:
	pause = !pause
	AudioManager.play_SE("res://assets/sound/start.mp3")
	Settings.player_name = ""
	SceneManager.change_scene("res://sceans/scean/title.tscn",{"pattern":"fade"})
	get_tree().paused = false
