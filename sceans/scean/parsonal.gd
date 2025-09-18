extends Panel

@onready var rank_label: Label = $rank_label
@onready var player_name: Label = $Player_name
@onready var time: Label = $Time
@onready var regulation: Label = $regulation
@onready var button: Button = $Button

var pending_data = null
var item:Array
var player_name_text:String
var load_data:Dictionary
func _ready():
	# _ready になるまで set_data が呼ばれた場合の待機処理
	if pending_data:
		_apply_data(pending_data)
		pending_data = null
func set_data(rank: int, name: String, timer: String, items: Array,map_size:int = 0,map: Array = []) -> void:
	item = items
	player_name_text = name
	load_data = {"items": items,"map":map,"map_size":map_size}
	if is_inside_tree():  # 既に _ready が呼ばれていれば即適用
		_apply_data({"rank": rank, "name": name, "timer": timer, "items": items,"map":map})
	else:
		# _ready 前なら保存しておく
		pending_data = {"rank": rank, "name": name, "timer": timer, "items": items,"map":map}
func _process(delta: float) -> void:
	visible = check_item(item) and is_name_filtered(player_name_text)
func _apply_data(data: Dictionary) -> void:
	rank_label.text = str(data["rank"]) + ":"
	player_name.text = data["name"]
	time.text = data["timer"]
	regulation.text = "アイテム :"+("on" if data["items"][0] else "off")+"\n"+"トラップ:"+("on" if data["items"][1] else "off")+"\n"+"暗闇     :"+("on" if data["items"][2] else "off")
	if data["map"] == [] or not data.has("map"):
		button.text = "迷路なし\nセットを適応"
		button.remove_theme_color_override("font_color")
		button.remove_theme_color_override("font_hover_color")
		button.remove_theme_color_override("font_focus_color")
	else:
		button.text = "迷路あり\nセットを適応"
		button.add_theme_color_override("font_color", Color(1, 1, 0)) # 黄色文字
		button.add_theme_color_override("font_hover_color", Color(1, 1, 0))
		button.add_theme_color_override("font_focus_color", Color(1, 1, 0))
func check_item(item: Array) -> bool:
	for i in range(Settings.filter_setting.size()):
		var cond_true = Settings.filter_setting[i][0]
		var cond_false = Settings.filter_setting[i][1]

		# もし両方 false なら「条件なし」なのでスキップ
		if not cond_true and not cond_false:
			continue

		# もし item[i] が true なのに cond_true が許可されてないならNG
		if item[i] and not cond_true:
			return false

		# もし item[i] が false なのに cond_false が許可されてないならNG
		if not item[i] and not cond_false:
			return false
	return true

func is_name_filtered(name: String) -> bool:
	var filter = Settings.name_filter.to_lower()
	if filter == "":
		return true  # フィルターが空なら全て表示
	return name.to_lower().find(filter) != -1


func _on_button_pressed() -> void:
	Settings.load_item_can_use = load_data["items"][0]
	Settings.load_trap_installation = load_data["items"][1]
	Settings.load_dark_mode = load_data["items"][2]
	Settings.map = load_data["map"]
	Settings.load_map_size = load_data["map_size"]
	SignalManager.on_load_set.emit()
