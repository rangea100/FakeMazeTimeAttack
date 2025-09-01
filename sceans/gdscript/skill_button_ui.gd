extends TextureRect
class_name SkillButtonUI

@export var icon_node: TextureRect
@export var count_label: Label
@export var signal_lost: TextureRect
@export var timer_node: Timer
@export var skill_data: Resource


var remaining_uses: int = 3
var is_active: bool = false
var disabled: bool = false
var time_left: float
var wait_time:float
var not_skill: bool = false

func _ready():
	_apply_skill_data()
	update_ui()
	wait_time= timer_node.wait_time


func _process(delta: float) -> void:
	time_left = timer_node.time_left


# Inspector で skill_data を変更した瞬間に呼ばれる
func _validate_property(property_info: Dictionary) -> void:
	if property_info.has("name") and property_info["name"] == "skill_data":
		_apply_skill_data()


func _apply_skill_data():
	if not skill_data:
		return
	
	# icon が設定されていれば自動で TextureRect に反映
	if "icon" in skill_data:
		icon_node.texture = skill_data.icon
	
	# max_uses が設定されていれば使用回数を初期化
	if "max_uses" in skill_data:
		remaining_uses = skill_data.max_uses
	
	update_ui()


func update_ui():
	if disabled:
		signal_lost.visible = true
	elif remaining_uses <= 0:
		signal_lost.visible = false
		modulate.a = 0.5
	else:
		signal_lost.visible = false
		icon_node.modulate.a = 1.0
	
	count_label.text = str(remaining_uses)


func _on_timer_timeout():
	is_active = false
	update_ui()

func animetion_play():
	$AnimationPlayer.play("skill_on")
