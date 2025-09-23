class_name TabMenu
extends TabContainer
var ui_on:bool = false
func _ready() -> void:
	tab_changed.connect(_on_tab_container_tab_changed)

func _input(event: InputEvent) -> void:
	if not ui_on:
		return

	if event.is_action_pressed("tab_left"):
		_select_prev_tab()
	elif event.is_action_pressed("tab_right"):
		_select_next_tab()


func _select_prev_tab() -> void:
	var i = current_tab - 1
	while i >= 0:
		if not is_tab_disabled(i):
			current_tab = i
			return
		i -= 1


func _select_next_tab() -> void:
	var max_tabs = get_tab_count()
	var i = current_tab + 1
	while i < max_tabs:
		if not is_tab_disabled(i):
			current_tab = i
			return
		i += 1


func _on_tab_container_tab_changed(tab: int) -> void:
	AudioManager.play_SE("res://assets/sound/select.mp3")
	var current_tab = get_child(tab)
	var menu := current_tab.get_node_or_null("MarginContainer/Menu")
	if menu:
		menu.configure_focus()
func focus() -> void:
	var currented_tab = get_child(current_tab)
	var menu := currented_tab.get_node_or_null("MarginContainer/Menu")
	if menu:
		menu.call_deferred("configure_focus")
