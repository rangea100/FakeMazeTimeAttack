extends Node

var ranking: Array = []  # 記録を保持

const SAVE_PATH := "user://ranking.json"

func _ready() -> void:
	load_ranking()

# 記録を追加
func add_record(player_name: String, time: float,timer:String, items: Array,size: int) -> void:
	var record = {
		"name": player_name,
		"time": time,
		"timer":timer,
		"items": items,
		"size":int(size)
	}
	ranking.append(record)
	
	# タイムでソート（昇順 = 早い方が上）
	ranking.sort_custom(func(a, b):
		return a["time"] < b["time"]
	)
	
	# 上位10件だけ残す
	#if ranking.size() > 10:
		#ranking = ranking.slice(0, 10)

	save_ranking()

# 保存
func save_ranking() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(ranking))
	file.close()

# 読み込み
func load_ranking() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text = file.get_as_text()
	var data = JSON.parse_string(text)
	if data is Array:
		ranking = data
	file.close()

#ファイル外部読み込み
func _on_file_dialog_file_selected(path: String) -> void:
	print("yobidasidekiteru")
	# 選択されたファイルを ranking.json に上書きコピー
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var data := file.get_as_text()
		var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		save_file.store_string(data)
		save_file.close()
		print("ranking.json を上書きしました")
		# 再ロード
		load_ranking()


func clear_ranking():
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify([])) # 空配列を保存
		file.close()
		print("ランキングをリセットしました")
	else:
		print("ranking.json を開けませんでした")
