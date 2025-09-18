extends Control
@onready var true_view: TextureRect = $true_view
@onready var viewmap: Control = $map/viewmapcon
@onready var map: Control = $map
@onready var background: TextureProgressBar = $map/background
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sub_viewport: SubViewport = $"../../player/SubViewport"
@onready var progress_bar: ProgressBar = $map/ProgressBar
@onready var player: CharacterBody3D = $"../../player"
@onready var view_but_bar: TextureProgressBar = $view_but_meter/TextureProgressBar
@onready var map_camera: Camera3D = $"../../player/minimap/Camera3D"
@onready var stopwatch: Control = $stopwatch
@onready var skill: SkillManager = $skill
@onready var game_clear: Control = $"../game_clear"
@onready var main: Node3D = $"../.."

@export var drain_time: float = 7.5 
@export var recovery_time: float = 15.0
@export var item_1_count:int = 3
@export var item_2_count:int = 1
@export var item_3_count:int = 5
var item_1_use:bool = false
var item_2_use:bool = false
var item_3_use:bool = false
var using_item: bool = false  # 使用中かどうかを判定
var can_use:bool = true
var use_ui: bool = false
var true_view_on:bool = false
var signal_lost_flug = false

func _ready() -> void:
	_update_size()
	get_viewport().size_changed.connect(_update_size)
	map.visible = false
	$background.visible = false
	$background2.visible = false
	$view_but_meter.visible = false
	$PlayerLabel.text = Settings.player_name
	$mapsizeLabel.text = str(Settings.map_size) + "x" + str(Settings.map_size)
	background.value = 0
	true_view.scale = Vector2(0.01,0.01)
	view_but_bar.value = 100
	skill.set_all_skills_notskill(true)
	SignalManager.on_game_compleat.connect(_on_game_complete)
	AudioManager.play_BGM("res://assets/sound/音ゲー.ogg",0.0,0.0,1.0,true)
	#await wait_for_key("e")
	await get_tree().create_timer(1.5).timeout
	animation_player.play("ui_on")
var last_input_method = "keyboard"  # "keyboard" または "controller"

func _input(event):
	if event is InputEventKey and event.pressed:
		if last_input_method != "keyboard":
			last_input_method = "keyboard"
			_on_input_method_changed()
	
	elif event is InputEventJoypadButton and event.pressed:
		if last_input_method != "controller":
			last_input_method = "controller"
			_on_input_method_changed()
	
	elif event is InputEventJoypadMotion and abs(event.axis_value) > 0.2:
		if last_input_method != "controller":
			last_input_method = "controller"
			_on_input_method_changed()
func _on_input_method_changed():
	if last_input_method == "keyboard":
		$key_display/Label.text = "1"
		$key_display/Label2.text = "2"
		$key_display/Label3.text = "3"
		$key_display/Label4.text = "E"
	elif last_input_method == "controller":
		$key_display/Label.text = "L"
		$key_display/Label2.text = "ZL"
		$key_display/Label3.text = "R"
		$key_display/Label4.text = "X"
func wait_for_key(key: String) -> void:
	while true:
		var ev: InputEvent = await get_tree().create_timer(0.01).timeout
		# ポーリング的にキー押下を確認
		if Input.is_action_just_pressed(key):
			return
func _process(delta: float) -> void:
	$map/map_ex_bar.value= ($skill/SkillButton1.time_left / $skill/SkillButton1.wait_time) * 10
	$map/truemap_bar.value= ($skill/SkillButton2.time_left / $skill/SkillButton2.wait_time) * 10
	if Settings.map_rotaition:
		$"../../player/minimap/TextureRect".rotation = 0
		$"../../player/minimap/North".rotation = $"../../player".rotation.y
		$"../../player/minimap/Camera3D".rotation.y = $"../../player".rotation.y
	else:
		$"../../player/minimap/Camera3D".rotation.y = 0
		$"../../player/minimap/North".rotation = 0
		$"../../player/minimap/TextureRect".rotation = -$"../../player".rotation.y
	if using_item and can_use:
		view_but_bar.value -= (view_but_bar.max_value / drain_time) * delta
		if view_but_bar.value <= 0:
			view_but_bar.value = 0
			can_use = false
			using_item = false  # 強制的に使用解除
			animation_player.play("view_off")
			using_item=false
	elif not can_use:  
		# クールタイム中は回復だけ
		view_but_bar.tint_progress = Color(1,1,0)
		view_but_bar.value += (view_but_bar.max_value / recovery_time) * delta
		if view_but_bar.value >= view_but_bar.max_value:
			view_but_bar.value = view_but_bar.max_value
			can_use = true  # 再び使用可能
			view_but_bar.tint_progress = Color(0,1,0)
	else:
		view_but_bar.value += (view_but_bar.max_value / 10) * delta
	
	if Input.is_action_just_pressed("e") and not animation_player.is_playing()and can_use and use_ui:
		if signal_lost_flug:
			pass
		else:
			true_view_on = !true_view_on
			if true_view_on:
				true_view.visible = true
				animation_player.play("view_on")
				using_item = true
			else:
				animation_player.play("view_off")
				using_item=false
	if Input.is_action_just_pressed("y")and use_ui:
		if Settings.develoer_mode:
			Settings.player_name = ""
			$PlayerLabel.visible = false
			SignalManager.on_game_compleat.emit()
		var env = $"../../WorldEnvironment".environment
		print(env.ssao_enabled)
		print(Settings.preset)
		print(Settings.graphics)
func _update_size() -> void:
	true_view.pivot_offset = size/2
	viewmap.pivot_offset = map.size/2
	sub_viewport.size = size

func signal_lost(time:float) -> void:
	true_view_on = false
	use_ui= false
	animation_player.play("view_off")
	stopwatch.signal_lost = true
	$map/viewmapcon.visible = false
	$map/Label.visible = true
	$map/Label.text = "Signal\nLost"
	$"../../player/Camera3D/noise".visible = true
	$signal_lost_text.visible = true
	view_but_bar.tint_progress = Color(1,0,0)
	signal_lost_flug = true
	using_item=false
	skill.set_all_skills_disabled(true)
	progress_bar.value = 0
	var tween = create_tween()
	tween.tween_property(progress_bar,"value",100,time)
	await tween.finished
	animation_player.play("restoration_map")
	$"../../player/Camera3D/noise".visible = false
	signal_lost_flug = false
	$signal_lost_text.visible = false
	view_but_bar.tint_progress = Color(0,1,0)
	use_ui= true
	stopwatch.signal_lost = false
	skill.set_all_skills_disabled(not Settings.item_can_use)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "view_off":
		true_view.visible = false
	if anim_name == "ui_on":
		$view_but_meter.visible = true
		use_ui= true
		stopwatch.start_stopwatch()
		skill.set_all_skills_notskill(false)
		skill.set_all_skills_disabled(not Settings.item_can_use)
		$key_display.visible = true


func _on_trap_hitbox_body_entered(body: Node3D) -> void:
	if signal_lost_flug == false:
		signal_lost(10)

func _on_game_complete() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"../pause_menue".can_pause = false
	stopwatch.stop_stopwatch()
	$"../game_clear/Label".text = "クリアタイムは"+stopwatch.format_time(stopwatch.elapsed_time)+"です。"
	if Settings.player_name== "":
		pass
	else:
		if Settings.map_save:
			RankingSave.add_record(Settings.player_name,stopwatch.elapsed_time,stopwatch.format_time(stopwatch.elapsed_time),Settings.regulation,Settings.map_size,Settings.saved_map)
			RankingSave.save_ranking()
		else:
			RankingSave.add_record(Settings.player_name,stopwatch.elapsed_time,stopwatch.format_time(stopwatch.elapsed_time),Settings.regulation,Settings.map_size)
			RankingSave.save_ranking()
		
	game_clear.visible = true
	game_clear.modulate.a = 0
	var tween =  create_tween()
	tween.tween_property(game_clear,"modulate:a",1.0,1.5)
	print("game_clea")
	main.show_path(main.path,main.wait)
	await tween.finished

func _on_main_path_drawn_completed() -> void:
	await get_tree().create_timer(2.0).timeout
	SceneManager.change_scene("res://sceans/scean/title.tscn",{"pattern":"fade"})
