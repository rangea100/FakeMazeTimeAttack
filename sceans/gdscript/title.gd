extends Control

@onready var title_button: Panel = $title_button
@onready var options: Panel = $options
@onready var start_option: Panel = $start_option
@onready var ranking_button: Button = $ranking_button
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var load_chek: Panel = $load_chek

signal load_aset_on
func _ready() -> void:
	title_button.scale = Vector2.ZERO
	AudioManager.bgm_fade_out(1.0)
	SceneManager.fade_in({"on_fade_in":func():animation_player.play("title_on")})
	await  animation_player.animation_finished
	print("ready")
	animation_player.play("title")
	SignalManager.on_load_set.connect(load_aset)

func _on_start_pressed() -> void:
	start_option.visible = true
	title_button.visible = false
	ranking_button.visible = false
	AudioManager.play_SE("res://assets/sound/on.mp3")
	$start_option/AnimationPlayer.play("ui_on")
	#SceneManager.change_scene("res://sceans/scean/main.tscn",{"pattarn":"fade"})


func _on_end_pressed() -> void:
	SceneManager.fade_out()
	await SceneManager.fade_complete
	get_tree().quit()



func _on_button_3_pressed() -> void:
	title_button.visible = false
	ranking_button.visible = false
	options.on_option()
	AudioManager.play_SE("res://assets/sound/on.mp3")



func _on_options_option_offed() -> void:
	title_button.visible = true
	ranking_button.visible = true
	
func _on_start_option_offed() -> void:
	title_button.visible = true
	ranking_button.visible = true


func _on_ranking_button_pressed() -> void:
	title_button.visible = false
	ranking_button.visible = false
	AudioManager.play_SE("res://assets/sound/on.mp3")
	$Ranking.show_ranking_bord()


func _on_ranking_ranking_off() -> void:
	title_button.visible = true
	ranking_button.visible = true

func load_aset()->  void:
	AudioManager.play_SE("res://assets/sound/check.mp3")
	load_chek.visible = true
	$load_chek/Label.visible = true if Settings.map == [] else false
	$load_chek/With_map.visible = false if Settings.map == [] else true
	animation_player.play("load_check_on")


func _on_back_pressed() -> void:
	AudioManager.play_SE("res://assets/sound/off.mp3")
	animation_player.play("load_check_off")
	await animation_player.animation_finished
	Settings.map = []


func _on_load_pressed() -> void:
	AudioManager.play_SE("res://assets/sound/select.mp3")
	load_aset_on.emit()
	load_chek.visible = false
	start_option.visible = true
	$start_option/AnimationPlayer.play("ui_on")
	$Ranking.hide_ranking_bord()


func _on_start_option_load_back() -> void:
	AudioManager.play_SE("res://assets/sound/off.mp3")
	$Ranking.show_ranking_bord()
	start_option.hide_start_option()
