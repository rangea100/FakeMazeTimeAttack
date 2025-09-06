extends Panel
@onready var advanced_setting_button: CheckButton = $AdvancedSettingButton
@onready var advanced_setting: Control = $AdvancedSetting
@onready var difficulty: HBoxContainer = $difficulty
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var start_chek: Panel = $start_chek
@onready var player_name: LineEdit = $player_name

var ui_on:bool = false
var active_button: Button = null
signal start_option_offed
func _ready() -> void:
	start_chek.visible = false
	visible = false
	$difficulty/normal.grab_focus()
	_on_button_difficulty_pressed($difficulty/normal)
	_on_advanced_setting_button_toggled(advanced_setting_button.button_pressed)
	for child in difficulty.get_children():
		if child is Button:
			child.pressed.connect(_on_button_difficulty_pressed.bind(child))
	ui_on = true
func _on_button_difficulty_pressed(button:Button) -> void:
	if ui_on:
		AudioManager.play_SE("res://assets/sound/select.mp3")
	button.focus_mode = Control.FOCUS_NONE
	 # 以前のアクティブボタンの見た目をリセット
	if active_button:
		active_button.remove_theme_color_override("font_color")
		active_button.remove_theme_color_override("font_hover_color")
		active_button.remove_theme_color_override("bg_color")

	# 新しいアクティブボタンを登録
	active_button = button

	# 見た目を強調
	active_button.add_theme_color_override("font_color", Color(1, 1, 0)) # 黄色文字
	active_button.add_theme_color_override("font_hover_color", Color(1, 1, 0)) # 黄色文字
	active_button.add_theme_color_override("bg_color", Color(0.3, 0.3, 0.3)) # 背景グレー
	match button.name:
		"easy":
			advance_setting_cont(0,true,false,false)
		"normal":
			advance_setting_cont(1,true,true,false)
		"hard":
			advance_setting_cont(2,false,true,false)
		"extra":
			advance_setting_cont(3,false,true,true)
		_:
			print("その他のボタン")

func advance_setting_cont(map_size:int,item_can:bool,trap_ins:bool,dark:bool) -> void:
	$AdvancedSetting/GridContainer/MapSize.select(map_size)
	var map_size_convat=[11,21,31,41,85]
	Settings.map_size = map_size_convat[map_size]
	$AdvancedSetting/GridContainer/UsingItem.button_pressed = item_can
	Settings.item_can_use = item_can
	$AdvancedSetting/GridContainer/TrapInstallation.button_pressed = trap_ins
	Settings.trap_installation = trap_ins
	$AdvancedSetting/GridContainer/DarkMode.button_pressed = dark
	Settings.dark_mode = dark

func _on_advanced_setting_button_toggled(toggled_on: bool) -> void:
	if ui_on:
		AudioManager.play_SE("res://assets/sound/select.mp3")
	# 見た目（半透明化）はルートコンテナに適用
	advanced_setting.modulate.a = (1.0 if toggled_on else 0.5)
	difficulty.modulate.a = (0.5 if toggled_on else 1.0)
	# 子孫ノードをすべて処理
	_set_disabled_recursive(advanced_setting, not toggled_on)
	_set_disabled_recursive(difficulty, toggled_on)
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


func _on_back_pressed() -> void:
	AudioManager.play_SE("res://assets/sound/off.mp3")
	animation_player.play("ui_off")
	await animation_player.animation_finished
	visible = false
	start_option_offed.emit()


func _on_start_pressed() -> void:
	AudioManager.play_SE("res://assets/sound/check.mp3")
	start_chek.visible = true
	if player_name.text == "":
		$start_chek/no_player.visible = true
		$start_chek/Label.visible = false
	else:
		$start_chek/no_player.visible =false
		$start_chek/Label.visible = true
	animation_player.play("chek_start_on")
	_set_disabled_recursive(self, true)
	_set_disabled_recursive(start_chek, false)


func _on_back_start_check_pressed() -> void:
	AudioManager.play_SE("res://assets/sound/off.mp3")
	animation_player.play("chek_start_off")
	await animation_player.animation_finished
	start_chek.visible = false
	_set_disabled_recursive(self, false)
	ui_on = false
	_on_advanced_setting_button_toggled(advanced_setting_button.button_pressed)
	ui_on = true


func _on_start_start_chek_pressed() -> void:
	AudioManager.play_SE("res://assets/sound/start.mp3")
	Settings.player_name = player_name.text
	Settings.regulation = [Settings.item_can_use,Settings.trap_installation,Settings.dark_mode]
	SceneManager.change_scene("res://sceans/scean/main.tscn",{"pattarn":"fade"})



func _on_map_size_item_selected(index: int) -> void:
	AudioManager.play_SE("res://assets/sound/select.mp3")
	var map_size=[11,21,31,41,85]
	Settings.map_size = map_size[index]


func _on_using_item_toggled(toggled_on: bool) -> void:
	AudioManager.play_SE("res://assets/sound/select.mp3")
	Settings.item_can_use=toggled_on


func _on_trap_installation_toggled(toggled_on: bool) -> void:
	AudioManager.play_SE("res://assets/sound/select.mp3")
	Settings.trap_installation=toggled_on


func _on_dark_mode_toggled(toggled_on: bool) -> void:
	AudioManager.play_SE("res://assets/sound/select.mp3")
	Settings.dark_mode = toggled_on
