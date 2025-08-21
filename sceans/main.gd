extends Node3D
@onready var gridmap: GridMap = $GridMap

const INBIGIBLE_MARKER_ID = 1 # MeshLibrary に登録したマーカー用ブロックのID
const PROJECTION_MARKER_ID = 2
const SIZE := 21
var combined_grid : Array = []

func _ready():
	var grid1 = generate_maze()
	var grid2 = generate_maze()
	combined_grid = combine_grids(grid1, grid2)

	# スタート・ゴールを設置
	set_start_and_goal()

	# GridMapに配置
	place_combined_grid()
	
	for cell in gridmap.get_used_cells():
		var item = gridmap.get_cell_item(cell)
		if item == INBIGIBLE_MARKER_ID:
			var local_pos = gridmap.map_to_local(cell)
			
			# GridMap のグローバル座標に変換
			var world_pos = gridmap.to_global(local_pos)
			# MeshInstance3D を作成
			var mesh_instance =  preload("res://sceans/invisible.tscn").instantiate()
			mesh_instance.transform.origin = world_pos
			add_child(mesh_instance)

			# マーカーを削除して GridMap 側には残さない
			gridmap.set_cell_item(cell, GridMap.INVALID_CELL_ITEM)
		if item == PROJECTION_MARKER_ID:
			var local_pos = gridmap.map_to_local(cell)
			
			# GridMap のグローバル座標に変換
			var world_pos = gridmap.to_global(local_pos)
			# MeshInstance3D を作成
			var mesh_instance =  preload("res://sceans/projection.tscn").instantiate()
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
				_: pass # 通路は何も置かない
