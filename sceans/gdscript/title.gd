extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var options: Panel = $options
@onready var start_option: Panel = $start_option
@onready var ranking_button: Button = $ranking_button

func _ready() -> void:
	$VBoxContainer/Button.grab_focus()
	AudioManager.bgm_fade_out(1.0)

func _on_start_pressed() -> void:
	start_option.visible = true
	rich_text_label.visible = false
	v_box_container.visible = false
	ranking_button.visible = false
	AudioManager.play_SE("res://assets/sound/on.mp3")
	$start_option/AnimationPlayer.play("ui_on")
	#SceneManager.change_scene("res://sceans/scean/main.tscn",{"pattarn":"fade"})


func _on_end_pressed() -> void:
	get_tree().quit()



func _on_button_3_pressed() -> void:
	rich_text_label.visible = false
	v_box_container.visible = false
	ranking_button.visible = false
	options.on_option()
	AudioManager.play_SE("res://assets/sound/on.mp3")



func _on_options_option_offed() -> void:
	rich_text_label.visible = true
	v_box_container.visible = true
	ranking_button.visible = true
	
func _on_start_option_offed() -> void:
	rich_text_label.visible = true
	v_box_container.visible = true
	ranking_button.visible = true


func _on_ranking_button_pressed() -> void:
	rich_text_label.visible = false
	v_box_container.visible = false
	ranking_button.visible = false
	AudioManager.play_SE("res://assets/sound/on.mp3")
	$Ranking.show_ranking_bord()


func _on_ranking_ranking_off() -> void:
	rich_text_label.visible = true
	v_box_container.visible = true
	ranking_button.visible = true
