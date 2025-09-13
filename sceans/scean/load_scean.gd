extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
var target_scene_path: Variant
var is_loading: bool = false
var option: Dictionary
func _ready() -> void:
	$AnimationPlayer.play("now_loading")
func start_loading(path: Variant,setted_options: Dictionary = {}) -> void:
	target_scene_path = path
	option = setted_options
	var err = ResourceLoader.load_threaded_request(target_scene_path, "PackedScene")
	if err != OK:
		push_error("Failed to start threaded load: %s" % target_scene_path)
		return
	is_loading = true
	set_process(true)

func _process(delta: float) -> void:
	if not is_loading:
		return

	var progress :Array= []
	var status: = ResourceLoader.load_threaded_get_status(target_scene_path, progress)

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		progress_bar.value = progress[0] * 100.0
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene: PackedScene = ResourceLoader.load_threaded_get(target_scene_path)
		is_loading = false
		set_process(false)
		SceneManager.change_scene(scene,option)
		# LoadingScreen を非表示
		self.visible = false
		# または親から外す場合
		if self.get_parent():
			self.get_parent().remove_child(self)
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Threaded load failed: %s" % target_scene_path)
		is_loading = false
		set_process(false)
