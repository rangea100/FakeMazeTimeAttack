extends Control

@onready var title_button: Panel = $title_button
@onready var options: Panel = $options
@onready var start_option: Panel = $start_option
@onready var ranking_button: Button = $ranking_button
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	SceneManager.fade_in()
	AudioManager.bgm_fade_out(1.0)
	animation_player.play("title_on")
	await  animation_player.animation_finished
	animation_player.play("title")

func _on_start_pressed() -> void:
	start_option.visible = true
	title_button.visible = false
	ranking_button.visible = false
	AudioManager.play_SE("res://assets/sound/on.mp3")
	$start_option/AnimationPlayer.play("ui_on")
	#SceneManager.change_scene("res://sceans/scean/main.tscn",{"pattarn":"fade"})


func _on_end_pressed() -> void:
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
