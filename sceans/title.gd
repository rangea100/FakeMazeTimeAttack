extends Control


func _on_start_pressed() -> void:
	SceneManager.change_scene("res://sceans/main.tscn",{"pattarn":"fade"})


func _on_end_pressed() -> void:
	get_tree().quit()
