extends HSlider
var audio_bus_id
@export var audio_bus_name: String
@export var audio_id:int
func _ready() -> void:
	value_changed.connect(_on_value_changed)
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	value = Settings.volume[audio_id]

func _on_value_changed(value: float) -> void:
	Settings.volume[audio_id] = value
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id,db if Settings.audio[audio_id] else linear_to_db(0))
