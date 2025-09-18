extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 6
@onready var camera_3d: Camera3D = $Camera3D
@export var kando: float = 0.5
@onready var pause_menue: Control = $"../CanvasLayer/pause_menue"
@onready var scope: Camera3D = $SubViewport/Camera3D
@export var min_fov := 25.0
@export var max_fov := 95.0
@export var zoom_speed := 5.0
@onready var true_view: TextureRect = $"../CanvasLayer/player_ui/true_view"
@onready var animation_player: AnimationPlayer = $"../CanvasLayer/player_ui/AnimationPlayer"
@onready var sub_viewport: SubViewport = $SubViewport


var can_move: bool = false




var pause:bool = false
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_update_size()
	get_viewport().size_changed.connect(_update_size)
	SignalManager.on_game_compleat.connect(_on_game_complete)
func _update_size():
	sub_viewport.size = get_viewport().size
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and can_move:
		print(-event.relative)
		rotate_y(deg_to_rad(-event.relative.x*kando))
		camera_3d.rotate_x(deg_to_rad(-event.relative.y*kando))
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x,-90,90)
func _process(delta):
	scope.global_transform = $Camera3D.global_transform
	kando = Settings.sensitivity
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor() and can_move:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if can_move:
		var camera_direction:Vector2 = Input.get_vector("VisiLeft","VisiRight","VisUp","VisiDown").normalized()
		rotate_y(deg_to_rad(-camera_direction.x*kando*7))
		camera_3d.rotate_x(deg_to_rad(-camera_direction.y*kando*7))
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x,-90,90)
		var input_dir := Input.get_vector("left", "right", "up", "down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ui_on":
		can_move = true
func _on_game_complete() -> void:
	can_move = false
	velocity.x = 0
	velocity.z = 0
	$"../Camera3D".current = true
	$"../Camera3D".position = $"..".center
	$"../Camera3D".position.y = 50
	match Settings.map_size:
		11,21:
			$"../Camera3D".size = 100
		31,41:
			$"../Camera3D".size = 200
		85:
			$"../Camera3D".size = 400
