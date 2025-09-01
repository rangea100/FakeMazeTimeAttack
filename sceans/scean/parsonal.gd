extends Panel

@onready var rank_label: Label = $rank_label
@onready var player_name: Label = $Player_name
@onready var time: Label = $Time
@onready var regulation: Label = $regulation
var pending_data = null

func _ready():
	# _ready になるまで set_data が呼ばれた場合の待機処理
	if pending_data:
		_apply_data(pending_data)
		pending_data = null
func set_data(rank: int, name: String, timer: String, items: Array) -> void:
	if is_inside_tree():  # 既に _ready が呼ばれていれば即適用
		_apply_data({"rank": rank, "name": name, "timer": timer, "items": items})
	else:
		# _ready 前なら保存しておく
		pending_data = {"rank": rank, "name": name, "timer": timer, "items": items}

func _apply_data(data: Dictionary) -> void:
	rank_label.text = str(data["rank"]) + ":"
	player_name.text = data["name"]
	time.text = data["timer"]
	regulation.text = "アイテム :"+("on" if data["items"][0] else "off")+"\n"+"トラップ:"+("on" if data["items"][1] else "off")+"\n"+"暗闇     :"+("on" if data["items"][2] else "off")
