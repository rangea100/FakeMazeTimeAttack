extends Control


@onready var _11x_11: VBoxContainer = $"Panel/TabContainer/11x11/VBoxContainer"
@onready var _21x_21: VBoxContainer = $"Panel/TabContainer/21x21/VBoxContainer"
@onready var _31x_31: VBoxContainer = $"Panel/TabContainer/31x31/VBoxContainer"
@onready var _41x_41: VBoxContainer = $"Panel/TabContainer/41x41/VBoxContainer"
@onready var _85x_85: VBoxContainer = $"Panel/TabContainer/85x85/VBoxContainer"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var file_dialog: FileDialog = $FileDialog
@onready var tab_container: TabContainer = $Panel/TabContainer
@onready var load_file_dialog: FileDialog = $LoadFileDialog
@onready var filter: Panel = $Panel/filter
@onready var filter_button: TextureButton = $Panel/FilterButton


signal ranking_off
var _11:int = 0
var _21:int = 0
var _31:int = 0
var _41:int = 0
var _85:int = 0
var ui_on:bool =false
func _ready():
	show_ranking()
	tab_container.set_tab_hidden(5,true)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.filters = ["*.json ; JSON Files"]
	load_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	load_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_file_dialog.filters = ["*.json ; JSON Files"]
	ui_on = true
	for child in $Panel/filter/GridContainer.get_children():
		if child is CheckBox:
			child.toggled.connect(_on_filter_checkbox_toggled.bind(child))
func _process(delta: float) -> void:
	Settings.filter = Settings.filter_setting.any(
	func(sub): return sub.any(func(v): return v)
)
	if Settings.filter or not Settings.name_filter == "":
		filter_button.texture_normal = preload("res://assets/filterbutton_on.png")
		filter_button.texture_hover = preload("res://assets/filterbutton_on_hover.png")
	else:
		filter_button.texture_normal = preload("res://assets/filterbutton.png")
		filter_button.texture_hover = preload("res://assets/filterbutton_hover.png")
	if Settings.develoer_mode:
		tab_container.set_tab_hidden(5,false)
	else:
		tab_container.set_tab_hidden(5,true)
func save_json_dialog():
	file_dialog.popup()
	file_dialog.file_selected.connect(func(path):
		save_json(path, RankingSave.ranking))
		
func load_json_dialog():
	load_file_dialog.popup()
func save_json(path: String, data: Array) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))  # インデント付きで保存
		file.close()
		print("保存しました:", path)
	else:
		print("保存に失敗しました:", path)
func show_ranking():
	RankingSave.load_ranking()
	_11= 0
	_21= 0
	_31= 0
	_41= 0
	_85= 0
	for child in _11x_11.get_children():
		child.queue_free()
	for child in _21x_21.get_children():
		child.queue_free()
	for child in _31x_31.get_children():
		child.queue_free()
	for child in _41x_41.get_children():
		child.queue_free()
	for child in _85x_85.get_children():
		child.queue_free()

	if RankingSave.ranking.size() == 0:
		print("そこになにもなかった")

	for i in range(RankingSave.ranking.size()):
		var r = RankingSave.ranking[i]
		match r["size"]:
			11,11.0:
				_11 += 1
				var row = preload("res://sceans/scean/parsonal.tscn").instantiate()
				row.set_data(_11, r["name"], r["timer"], r["items"])
				_11x_11.add_child(row)
			21,21.0:
				_21 += 1
				var row = preload("res://sceans/scean/parsonal.tscn").instantiate()
				row.set_data(_21, r["name"], r["timer"], r["items"])
				_21x_21.add_child(row)
			31,31.0:
				_31 += 1
				var row = preload("res://sceans/scean/parsonal.tscn").instantiate()
				row.set_data(_31, r["name"], r["timer"], r["items"])
				_31x_31.add_child(row)
			41,41.0:
				_41 += 1
				var row = preload("res://sceans/scean/parsonal.tscn").instantiate()
				row.set_data(_41, r["name"], r["timer"], r["items"])
				_41x_41.add_child(row)
			85,85.0:
				_85 += 1
				var row = preload("res://sceans/scean/parsonal.tscn").instantiate()
				row.set_data(_85, r["name"], r["timer"], r["items"])
				_85x_85.add_child(row)

func show_ranking_bord() -> void:
	visible = true
	animation_player.play("ranking_on")

func hide_ranking() -> void:
	AudioManager.play_SE("res://assets/sound/off.mp3")
	animation_player.play("ranking_off")
	await animation_player.animation_finished
	visible = false
	ranking_off.emit()




func _on_load_file_dialog_file_selected(path: String) -> void:
	print("ya")
	RankingSave._on_file_dialog_file_selected(path)
	show_ranking()



func _on_clear_pressed() -> void:
	RankingSave.clear_ranking()
	show_ranking()
	animation_player.play("delete_check_off")
	await animation_player.animation_finished
	$Panel/delete_chek.visible = false
	_set_disabled_recursive(self,false)


func _on_tab_container_tab_changed(tab: int) -> void:
	if ui_on:
		AudioManager.play_SE("res://assets/sound/select.mp3")
	


func _on_filter_button_pressed() -> void:
	AudioManager.play_SE("res://assets/sound/select.mp3")
	filter.visible = true
	animation_player.play("filter_setting_on")
	_set_disabled_recursive(self,true)
	_set_disabled_recursive(filter,false)

func _on_back_pressed() -> void:
	AudioManager.play_SE("res://assets/sound/off.mp3")
	animation_player.play("filter_setting_off")
	await animation_player.animation_finished
	filter.visible = false
	_set_disabled_recursive(self,false)

func _on_filter_checkbox_toggled(button_pressed: bool, checkbox: CheckBox) -> void:
	AudioManager.play_SE("res://assets/sound/select.mp3")
	match checkbox.name:
		"ItemOn":
			Settings.filter_setting[0][0] = button_pressed
		"ItemOff":
			Settings.filter_setting[0][1] = button_pressed
		"TrapOn":
			Settings.filter_setting[1][0] = button_pressed
		"TrapOff":
			Settings.filter_setting[1][1] = button_pressed
		"DarkOn":
			Settings.filter_setting[2][0] = button_pressed
		"DarkOff":
			Settings.filter_setting[2][1] = button_pressed
	#print(Settings.filter_setting,Settings.filter)
func _set_disabled_recursive(node: Node, disable: bool) -> void:
	for child in node.get_children():
		if child is Control:
			# "disabled" プロパティを持つUIは無効化
			if "disabled" in child:
				child.disabled = disable
			# クリックを受けないようにする
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE if disable else Control.MOUSE_FILTER_PASS
			# さらに子供がいるなら再帰的に処理
			_set_disabled_recursive(child, disable)


func _on_back_delete_pressed() -> void:
	animation_player.play("delete_check_off")
	await animation_player.animation_finished
	$Panel/delete_chek.visible = false
	_set_disabled_recursive(self,false)


func _on_clear_on_pressed() -> void:
	$Panel/delete_chek.visible = true
	animation_player.play("delete_check_on")
	_set_disabled_recursive(self,true)
	_set_disabled_recursive($Panel/delete_chek,false)


func _on_name_filter_text_changed(new_text: String) -> void:
	Settings.name_filter = new_text
