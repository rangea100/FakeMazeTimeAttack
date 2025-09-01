extends Node
@onready var bgm: AudioStreamPlayer = $BGM
@onready var environment: AudioStreamPlayer = $Environment
@onready var se: AudioStreamPlayer = $SE

@onready var bgm_stream: AudioStreamInteractive = bgm.stream
@onready var label: Label = $CanvasLayer/BGMDisplay/Label
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

var BGM_name:String

signal fadeout_finished

func play_BGM(path:String = "",endfade_time:float = 0.0,startfade_time:float = 0.0,pitch_scale:float = 1.0,display:bool = false) -> void:
	if endfade_time != 0.0:
		await bgm_fade_out(endfade_time)
	if path == "":
		bgm.stop()
		bgm.volume_db = 0.0
		return
	bgm.stream = load(path)
	bgm.pitch_scale = abs(pitch_scale)
	if startfade_time == 0.0:
		bgm.volume_db = 0.0
	else:
		bgm_fade_in(startfade_time)
	if !bgm.is_playing():
		bgm.play()
	await get_tree().create_timer(1.0).timeout
	if display:
		if animation_player.is_playing():
			await animation_player.animation_finished
		label.text = "♪～" + str(bgm.stream.resource_path.get_file().get_basename()) + "～♪"
		animation_player.play("BGM_display")

func bgm_fade_out(endfade_time:float) -> void:
	var tween:Tween = create_tween()
	tween.tween_property(bgm,"volume_db",-80.0,endfade_time)
	await tween.finished
	emit_signal("fadeout_finished")

func bgm_fade_in(startfade_time:float) -> void:
	bgm.volume_db = -40.0
	var tween:Tween = create_tween()
	tween.tween_property(bgm,"volume_db",0.0,startfade_time).set_ease(Tween.EASE_OUT)

func play_SE(path:String,pitch_scale:float = 1.0) -> void:
	se.stream = load(path)
	se.pitch_scale = pitch_scale
	se.play()
