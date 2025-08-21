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

@export var drain_time: float = 7.5 
@export var recovery_time: float = 15.0
var using_item: bool = false  # 使用中かどうかを判定
var can_use:bool = true

var true_view_on:bool = false
var signal_lost_flug = false

func _ready() -> void:
	_update_size()
	get_viewport().size_changed.connect(_update_size)
	map.visible = false
	$background.visible = false
	$background2.visible = false
	true_view.visible = false
	background.value = 0
	true_view.scale = Vector2(0.01,0.01)
	view_but_bar.value = 100
	await get_tree().create_timer(1.0).timeout
	animation_player.play("ui_on")
func _process(delta: float) -> void:
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
	
	if Input.is_action_just_pressed("e") and not animation_player.is_playing()and can_use:
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
	if Input.is_action_just_pressed("y"):
		signal_lost(5.0)
func _update_size() -> void:
	true_view.pivot_offset = size/2
	viewmap.pivot_offset = map.size/2
	sub_viewport.size = size

func signal_lost(time:float) -> void:
	true_view_on = false
	animation_player.play("view_off")
	$map/viewmapcon.visible = false
	$map/Label.visible = true
	$map/Label.text = "Signal\nLost"
	$"../../player/Camera3D/noise".visible = true
	$signal_lost_text.visible = true
	view_but_bar.tint_progress = Color(1,0,0)
	signal_lost_flug = true
	using_item=false
	progress_bar.value = 0
	var tween = create_tween()
	tween.tween_property(progress_bar,"value",100,time)
	await tween.finished
	animation_player.play("restoration_map")
	$"../../player/Camera3D/noise".visible = false
	signal_lost_flug = false
	$signal_lost_text.visible = false
	view_but_bar.tint_progress = Color(0,1,0)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "view_off":
		true_view.visible = false
	if anim_name == "ui_on":
		$view_but_meter.visible = true
