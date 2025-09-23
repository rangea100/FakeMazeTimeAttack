class_name Menu
extends VBoxContainer

signal actioned(item: Control, value)
signal request_init(item: Control)
signal reqest_visible(item: Control)
@export var pointer: Node
@export var position_x: float
var connect_signal:bool = false
func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	configure_focus()
	# 各子アイテムの初期化を親に依頼
	for item in get_items():
		call_deferred("emit_signal", "request_init", item)
# マウスホイールでスクロールしたとき
func master_init() ->void:
	for item in get_items():
		call_deferred("emit_signal", "reqest_visible", item)
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	get_viewport().set_input_as_handled()

	var item = get_focused_item()
	#if is_instance_valid(item) and event.is_action_pressed("ui_accept"):
		## CheckButton や HSlider に対応
		#var val = _get_item_value(item)
		#actioned.emit(item, val)

func get_items() -> Array[Control]:
	var items: Array[Control] = []
	for child in get_children():
		if not child is Control: continue
		if child is Label: continue 
		if "Heading" in child.name: continue
		if "Divider" in child.name: continue
		items.append(child)
	return items

func configure_focus() -> void:
	var items = get_items()
	for i in items.size():
		var item: Control = items[i]
		item.focus_mode = Control.FOCUS_ALL
		# ---- クリックや値変更のシグナルを拾う ----
		if connect_signal == false:
			item.mouse_entered.connect(_on_item_mouse_entered.bind(item))
			if item is CheckButton:
				item.toggled.connect(_on_item_value_changed.bind(item))
			elif item is HSlider:
				item.value_changed.connect(_on_item_value_changed.bind(item))
			elif item is OptionButton:
				item.item_selected.connect(_on_option_selected.bind(item))
			elif item is Button:
				item.pressed.connect(_on_item_activated.bind(item))
			#connect_signal = true
		# 他にも LineEdit なら text_changed などをここで追加できる
		# -------------------------------------------
		if i == 0:
			item.focus_neighbor_top = item.get_path()
			item.focus_previous = item.get_path()
			item.call_deferred("grab_focus")
		else:
			item.focus_neighbor_top = items[i-1].get_path()
			item.focus_previous = items[i-1].get_path()

		if i == items.size() - 1:
			item.focus_neighbor_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i+1].get_path()
			item.focus_next = items[i+1].get_path()


# 現在フォーカスの取得
func get_focused_item() -> Control:
	var item = get_viewport().gui_get_focus_owner()
	return item if item in get_children() else null

func update_selection() -> void:
	var item = get_focused_item()
	if not item or not is_instance_valid(pointer):
		return
	# Menu 内のローカル座標でポインターを配置
	var y = item.global_position.y + item.get_size().y * 0.5
	pointer.global_position.y = y
	pointer.global_position.x = global_position.x+position_x

# キーボードでフォーカスが変わったとき
func _on_focus_changed(focused: Control) -> void:
	if not focused or not is_instance_valid(focused):
		return
	if focused in get_children():
		update_selection()
		#_scroll_to_item(focused)
# フォーカス項目が見えるようにスクロール
func _process(delta: float) -> void:
		update_selection()  # ポインターを更新


func _on_item_mouse_entered(item: Control) -> void:
	item.grab_focus()
	update_selection()

# ここで「値」を統一的に取得
func _get_item_value(item: Control) -> Variant:
	if item is CheckButton:
		return item.button_pressed
	elif item is HSlider:
		return item.value
	else:
		# 他のボタン等は「名前」を返すなど
		return item.name
# ボタンが押された時
func _on_item_activated(item: Control) -> void:
	print("huhahaha")
	var val = _get_item_value(item)
	actioned.emit(item, val)
# 値が変わった時（CheckButton/HSlider等）
func _on_item_value_changed(val, item: Control) -> void:
	actioned.emit(item, val)

# OptionButton 選択
func _on_option_selected(index: int, item: Control) -> void:
	# ここでは index が選ばれた値
	print(index)
	actioned.emit(item, index)
