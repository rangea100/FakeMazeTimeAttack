extends Panel
@onready var tab_menu: TabMenu = $TabMenu
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var master: HSlider = %Master
@onready var se: HSlider = %SE
@onready var bgm: HSlider = %BGM
@onready var environment: HSlider = %Environment

signal option_offed
var can_ui:bool=  false
var ui_on:bool = false

func _ready() -> void:
	%CollisionMiss.disabled = !Settings.develoer_mode
	for tab in $TabMenu.get_tab_count()-1:
		var menu = $TabMenu.get_child(tab).get_node("MarginContainer/Menu")
		if menu:
			menu.call_deferred("master_init")
func _process(delta: float) -> void:
	if Input.is_action_pressed("commemd") or Settings.develoer_mode:
		tab_menu.set_tab_hidden(3,false)
		tab_menu.set_tab_disabled(3,false)
	else:
		tab_menu.set_tab_hidden(3,true)
		tab_menu.set_tab_disabled(3,true)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back") and ui_on:
		_on_back_option_pressed()
#---------- 押された時の処理 ------------
func _on_menu_actioned(item: Control, value: Variant) -> void:
	if (item is CheckButton or item is OptionButton) and can_ui == true:
		AudioManager.play_SE("res://assets/sound/select.mp3")
	match item.name:
		#--------- 画面 ----------------------
		"FullScrean":
			Settings.fullscreen_mode = value
			if value == true:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		"WindowSize":
			print("option:",value)
			Settings.resoltion_nomber = value
			var viewport_wide = [1152,1280,1920]
			var viewport_high = [628,720,1080]
			var old_size = DisplayServer.window_get_size()
			var old_pos = DisplayServer.window_get_position()
			var new_size =Vector2i(viewport_wide[value],viewport_high[value])
			# 新旧サイズの差分
			var diff = new_size - old_size

			# 中心を保つように位置を調整（左上をずらす）
			var new_pos = old_pos - diff / 2

			# 先に位置を設定 → その後サイズを設定
			DisplayServer.window_set_position(new_pos)

			DisplayServer.window_set_size(new_size)
		"GraphicsPreset":
			Settings.graphics = value
			match value:
				0:
					Settings.set_preset("res://sceans/resource/performance_preset.tres")
				1:
					Settings.set_preset("res://sceans/resource/balanced_preset.tres")
				2:
					Settings.set_preset("res://sceans/resource/quality_preset.tres")
		#--------------------------------------------------
		#---------- ゲーム -----------------------------------
		"MapControal":
			Settings.map_rotaition = value
		"Sensitivity":
			Settings.sensitivity = value
		#--------------------------------------------------
		#---------- サウンド -----------------------------------
		"MasterLabel":
			Settings.audio[0] = value
			var audio_bus_id = AudioServer.get_bus_index("Master")
			var db = linear_to_db(Settings.volume[0] if value else 0)
			AudioServer.set_bus_volume_db(audio_bus_id,db)
			master.visible = value
		"Master":
			Settings.volume[0] = value
			var audio_bus_id = AudioServer.get_bus_index("Master")
			var db = linear_to_db(value)
			AudioServer.set_bus_volume_db(audio_bus_id,db)
		"SELabel":
			Settings.audio[1] = value
			var audio_bus_id = AudioServer.get_bus_index("SE")
			var db = linear_to_db(Settings.volume[1] if value else 0)
			AudioServer.set_bus_volume_db(audio_bus_id,db)
			se.visible = value
		"SE":
			Settings.volume[1] = value
			var audio_bus_id = AudioServer.get_bus_index("SE")
			var db = linear_to_db(value)
			AudioServer.set_bus_volume_db(audio_bus_id,db)
		"BGMLabel":
			Settings.audio[2] = value
			var audio_bus_id = AudioServer.get_bus_index("BGM")
			var db = linear_to_db(Settings.volume[2] if value else 0)
			AudioServer.set_bus_volume_db(audio_bus_id,db)
			bgm.visible = value
		"BGM":
			Settings.volume[2] = value
			var audio_bus_id = AudioServer.get_bus_index("BGM")
			var db = linear_to_db(value)
			AudioServer.set_bus_volume_db(audio_bus_id,db)
		"EnvironmentLabel":
			Settings.audio[3] = value
			var audio_bus_id = AudioServer.get_bus_index("Environment")
			var db = linear_to_db(Settings.volume[3] if value else 0)
			AudioServer.set_bus_volume_db(audio_bus_id,db)
			environment.call_deferred("show" if value else "hide")
		"Environment":
			Settings.volume[3] = value
			var audio_bus_id = AudioServer.get_bus_index("Environment")
			var db = linear_to_db(value)
			AudioServer.set_bus_volume_db(audio_bus_id,db)
		#--------------------------------------------------
		#-------------------- 開発者特権 ---------------------
		"DeveloperMode":
			Settings.develoer_mode = value
			%CollisionMiss.disabled = !value
		"CollisonMiss":
			Settings.collision_miss = value
#----------------------- 初期化 -------------------------
func _on_menu_request_init(item: Control) -> void:
	match item.name:
		#----------画面------------------
		"FullScrean":
			item.button_pressed = Settings.fullscreen_mode
		"WindowSize":
			item.selected = Settings.resoltion_nomber
		"GraphicsPreset":
			item.selected = Settings.graphics
		#--------------------------------------------------
		#---------- ゲーム ---------------------------------
		"MapControal":
			item.button_pressed=Settings.map_rotaition
		"Sensitivity":
			item.value = Settings.sensitivity
		#--------------------------------------------------
		#---------- サウンド -------------------------------
		"MasterLabel":
			item.button_pressed = Settings.audio[0]
		"Master":
			item.value = Settings.volume[0]
		"SELabel":
			item.button_pressed = Settings.audio[1]
		"SE":
			item.value = Settings.volume[1]
		"BGMLabel":
			item.button_pressed = Settings.audio[2]
		"BGM":
			item.value = Settings.volume[2]
		"EnvironmentLabel":
			item.button_pressed = Settings.audio[3]
		"Environment":
			item.value = Settings.volume[3]
		#--------------------------------------------------
		#-------------------- 開発者特権 ---------------------
		"DeveloperMode":
			item.button_pressed = Settings.develoer_mode
		"CollisionMiss":
			item.button_pressed = Settings.collision_miss
	call_deferred("ui_on_t")
func ui_on_t():
	can_ui = true
func on_option() -> void:
	ui_on = true
	visible = true
	animation_player.play("option_on")
	$TabMenu.ui_on = true
	$TabMenu.focus()

func _on_back_option_pressed() -> void:
	if can_ui:
		AudioManager.play_SE("res://assets/sound/off.mp3")
	animation_player.play("option_off")
	await animation_player.animation_finished
	visible = false
	ui_on = false
	$TabMenu.ui_on = false
	option_offed.emit()

#--- visibleなどのノードがないとできない設定はここに ----------------------
func _on_menu_reqest_visible(item: Control) -> void:
	match item.name:
		"MasterLabel":
			master.visible = Settings.audio[0]
		"SELabel":
			se.visible = Settings.audio[1]
		"BGMLabel":
			bgm.visible = Settings.audio[2]
		"EnvironmentLabel":
			environment.visible = Settings.audio[3]
