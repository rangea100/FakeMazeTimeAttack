extends Resource
class_name Skill

@export var name: String
@export var icon: Texture2D
@export var max_uses: int = 3
@export var duration: float = 5.0
@export var key: String = "skill_fireball"


var is_active: bool = false
var remaining_uses: int

func init():
	remaining_uses = max_uses
