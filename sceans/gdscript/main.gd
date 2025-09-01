extends Node3D
@onready var gridmap: GridMap = $GridMap
@onready var floor: CSGBox3D = $floor


const INBIGIBLE_MARKER_ID = 1 # MeshLibrary に登録したマーカー用ブロックのID
const PROJECTION_MARKER_ID = 2
const TRAP_MARKER_ID = 5
const GOAL_MARKER_ID = 6
@export var SIZE :int= 21
var combined_grid : Array = []
var trap_count: int
func _ready():
	# 好きなサイズを設定
	SIZE = Settings.map_size
	match SIZE:
		11:
			trap_count = 5
		21:
			trap_count = 10
		31:
			trap_count = 20
		41:
			trap_count = 30
		85:
			trap_count = 60
	var w: float = (SIZE-1)*3
	var h: float = 1.0
	var d: float = (SIZE-1)*3
	floor.size = Vector3(w, h, d)
	$WorldEnvironment.environment.fog_density = (0.5 if Settings.dark_mode else 0.1)
# 左上基準にしたいので、半分分だけマイナス方向にずらす
	floor.position = Vector3(w/2, -h/2, d/2)
	var grid1 = generate_maze()
	var grid2 = generate_maze()
	combined_grid = combine_grids(grid1, grid2)
	if Settings.trap_installation:
		place_traps(trap_count)
	# スタート・ゴールを設置
	set_start_and_goal()
	
	# GridMapに配置
	place_combined_grid()
	#girtmap置き換え
	replace_grit()

func replace_grit() -> void:
	for cell in gridmap.get_used_cells():
		var item = gridmap.get_cell_item(cell)
		if item == INBIGIBLE_MARKER_ID:
			var local_pos = gridmap.map_to_local(cell)
			
			# GridMap のグローバル座標に変換
			var world_pos = gridmap.to_global(local_pos)
			# MeshInstance3D を作成
			var mesh_instance =  preload("res://sceans/scean/invisible.tscn").instantiate()
			mesh_instance.transform.origin = world_pos
			add_child(mesh_instance)
			# マーカーを削除して GridMap 側には残さない
			gridmap.set_cell_item(cell, GridMap.INVALID_CELL_ITEM)
		if item == PROJECTION_MARKER_ID:
			var local_pos = gridmap.map_to_local(cell)
			
			# GridMap のグローバル座標に変換
			var world_pos = gridmap.to_global(local_pos)
			# MeshInstance3D を作成
			var mesh_instance =  preload("res://sceans/scean/projection.tscn").instantiate()
			mesh_instance.transform.origin = world_pos
			add_child(mesh_instance)
			gridmap.set_cell_item(cell, GridMap.INVALID_CELL_ITEM)
		if item == TRAP_MARKER_ID:
			var local_pos = gridmap.map_to_local(cell)
			
			# GridMap のグローバル座標に変換
			var world_pos = gridmap.to_global(local_pos)
			# MeshInstance3D を作成
			var mesh_instance =  preload("res://sceans/scean/trap.tscn").instantiate()
			mesh_instance.transform.origin = world_pos
			add_child(mesh_instance)
			# マーカーを削除して GridMap 側には残さない
			gridmap.set_cell_item(cell, GridMap.INVALID_CELL_ITEM)
		if item == GOAL_MARKER_ID:
			var local_pos = gridmap.map_to_local(cell)
			
			# GridMap のグローバル座標に変換
			var world_pos = gridmap.to_global(local_pos)
			# MeshInstance3D を作成
			var mesh_instance =  preload("res://sceans/scean/goal.tscn").instantiate()
			mesh_instance.transform.origin = world_pos
			add_child(mesh_instance)
			# マーカーを削除して GridMap 側には残さない
			gridmap.set_cell_item(cell, GridMap.INVALID_CELL_ITEM)
# 穴掘り法で迷路生成
func generate_maze() -> Array:
	var grid = []
	for y in range(SIZE):
		var row = []
		for x in range(SIZE):
			row.append(1)
		grid.append(row)

	var start_x = (randi() % (SIZE / 2)) * 2 + 1
	var start_y = (randi() % (SIZE / 2)) * 2 + 1
	grid[start_y][start_x] = 0

	dig(grid, start_x, start_y)
	return grid


func dig(grid: Array, x: int, y: int):
	var directions = [Vector2(0,-1), Vector2(0,1), Vector2(-1,0), Vector2(1,0)]
	directions.shuffle()

	for dir in directions:
		var nx = x + int(dir.x) * 2
		var ny = y + int(dir.y) * 2
		if nx > 0 and nx < SIZE-1 and ny > 0 and ny < SIZE-1:
			if grid[ny][nx] == 1:
				grid[y + int(dir.y)][x + int(dir.x)] = 0
				grid[ny][nx] = 0
				dig(grid, nx, ny)


# 2つの迷路を合成
func combine_grids(grid1: Array, grid2: Array) -> Array:
	var result = []
	for y in range(SIZE):
		var row = []
		for x in range(SIZE):
			var a = grid1[y][x]
			var b = grid2[y][x]

			if a == 0 and b == 0:
				row.append(0)
			elif a == 1 and b == 1:
				row.append(1)
			elif a == 0 and b == 1:
				row.append(2)
			elif a == 1 and b == 0:
				row.append(3)
		result.append(row)
	return result


# スタートとゴールを設置
func set_start_and_goal():
	# 左上3マスをスタート
	combined_grid[0][0] = 4
	combined_grid[0][1] = 4
	combined_grid[1][0] = 4

	# 右下3マスをゴール
	combined_grid[SIZE-1][SIZE-1] = 5
	combined_grid[SIZE-1][SIZE-2] = 5
	combined_grid[SIZE-2][SIZE-1] = 5
	combined_grid[SIZE-2][SIZE-2] = 7
# トラップをランダム配置
# トラップをランダム配置
func place_traps(count: int):
	var candidates = []
	for y in range(SIZE):
		for x in range(SIZE):
			if combined_grid[y][x] == 0: # 通路だけ候補
				# スタート位置(1,1)とゴール位置(SIZE-2, SIZE-2)は除外
				if (x == 1 and y == 1) or (x == SIZE-2 and y == SIZE-2):
					continue
				candidates.append(Vector2i(x, y))

	candidates.shuffle()

	for i in range(min(count, candidates.size())):
		var pos = candidates[i]
		combined_grid[pos.y][pos.x] = 6 # トラップ


# GridMapに配置
func place_combined_grid():
	gridmap.clear()
	for y in range(SIZE):
		for x in range(SIZE):
			match combined_grid[y][x]:
				1: gridmap.set_cell_item(Vector3i(x, 0, y), 0) # 普通の壁
				2: gridmap.set_cell_item(Vector3i(x, 0, y), 2) # 見た目だけの壁
				3: gridmap.set_cell_item(Vector3i(x, 0, y), 1) # 透明な壁
				4: gridmap.set_cell_item(Vector3i(x, 0, y), 3) # スタート壁
				5: gridmap.set_cell_item(Vector3i(x, 0, y), 4) # ゴール壁
				6: gridmap.set_cell_item(Vector3i(x, 0, y), 5)#トラップ
				7: gridmap.set_cell_item(Vector3i(x, 0, y), 6)
				_: pass # 通路は何も置かない
