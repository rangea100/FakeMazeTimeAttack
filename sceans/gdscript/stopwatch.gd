extends Control

@onready var time_label: Label = $TimeLabel

var running: bool = false
var elapsed_time: float = 0.0
var signal_lost: bool = false

func _process(delta: float) -> void:
	if running:
		elapsed_time += delta
		if signal_lost:
			time_label.text = "--:--.--"
		else:
			time_label.text = format_time(elapsed_time)

func start_stopwatch():
	running = true
	elapsed_time = 0.0

func stop_stopwatch():
	running = false

func format_time(seconds: float) -> String:
	var minutes = int(seconds / 60)
	var secs = int(seconds) % 60
	var millis = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, secs, millis]
