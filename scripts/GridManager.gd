extends GridContainer

enum Mode {NORMAL, CUSTOM}
enum Difficulty {EASY, MEDIUM, HARD}

@export var _mode: Mode = Mode.NORMAL
@export var _difficulty: Difficulty = Difficulty.EASY
@export var _width: int = 16
@export var _num_bombs: int = 16

var _grid_cell_asset: PackedScene = preload("res://scenes/grid_cell.tscn")
var _grid_cell_asset2: PackedScene = preload("res://scenes/grid_cell_2.tscn")
var _border_cell_asset: PackedScene = preload("res://scenes/border_cell.tscn")
@onready var _camera: Camera2D = $"../Camera2D"
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _cells: Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_grid(_width)

func generate_grid(width) -> void:
	columns = width + 2 # surrounding left and right and top and down cells are
	# for borders
	size = Vector2i(columns * 48, columns * 48)
	
	# spawn in all the cells into the container
	for i in width + 2:
		var row: Array[Node] = []
		for j in width + 2:
			if i == 0 or i == width + 1 or j == 0 or j == width + 1:
				var instance: Node = _border_cell_asset.instantiate()
				add_child(instance)
			else:
				var instance: Node
				if (i + j) % 2 == 0:
					instance = _grid_cell_asset.instantiate()
				else:
					instance = _grid_cell_asset2.instantiate()
				add_child(instance)
				instance.coordinate = Vector2i(i - 1, j - 1)
				instance.on_cell_changed.connect(_on_cell_changed)
				row.append(instance)
		if len(row) > 0:
			_cells.append(row)
		
	# loop through all the cells to find their neighbours and add them
	for i in width:
		for j in width:
			var cell: Node = _cells[i][j]
			var neighbours: Array[Node] = []
			# top row
			if 0 < i and 0 < j:
				neighbours.append(_cells[i - 1][j - 1])
			if 0 < j:
				neighbours.append(_cells[i][j - 1])
			if 0 < j and i < width - 1:
				neighbours.append(_cells[i + 1][j - 1])
			# middle row
			if 0 < i:
				neighbours.append(_cells[i - 1][j])
			if i < width - 1:
				neighbours.append(_cells[i + 1][j])
			# bottom row
			if 0 < i and j < width - 1:
				neighbours.append(_cells[i - 1][j + 1])
			if j < width - 1:
				neighbours.append(_cells[i][j + 1])
			if j < width - 1 and i < width - 1:
				neighbours.append(_cells[i + 1][j + 1])
			cell.neighbours = neighbours
	
	# place bombs on random cells
	var _bombs_to_place: int = _num_bombs
	while _bombs_to_place > 0:
		var num: int = _rng.randi_range(0, width * width - 1)
		var coord: Vector2i = Vector2i(num % width, num / width)
		if _cells[coord.x][coord.y].has_bomb:
			continue
		else:
			_cells[coord.x][coord.y].has_bomb = true
			_bombs_to_place -= 1
			print("bomb at %v" % coord)
	
	# set the camera properties
	var vp: Vector2 = get_viewport_rect().size
	print(vp)
	var grid_size: Vector2 = Vector2(float(width) * 48, float(width) * 48)
	print(grid_size)
	var grid_rect: Rect2 = Rect2(Vector2.ZERO, Vector2((width + 2) * 48, (width + 2) * 48))
	var zoom: float = min(vp.x / grid_size.x, vp.y / grid_size.y)
	_camera.rect = grid_rect
	_camera.zoom = Vector2(zoom, zoom)
	_camera.position = grid_rect.get_center()

	


func _on_cell_changed(coord: Vector2i, state) -> void:
	print("cell at %v set to %s" % [coord, state])
	# check if all the bomb cells have been flagged correctly
	if state == 3: # 3 = BOMBED
		print("you lost the game")
		# loop through all the cells and if its a bomb one then show it gradually,
		# then quit at the end
		for row in _cells:
			for cell in row:
				if not cell.has_bomb:
					continue
				await get_tree().create_timer(0.15).timeout
				cell._is_bombed()
		await get_tree().create_timer(2.0).timeout
		get_tree().quit()
	elif _has_won():
		print("you win the game")
		get_tree().quit()

func _has_won() -> bool:
	# brute force search: loop through all nodes and check if for each has_bomb
	# cell if the cell is also flagged
	for row in _cells:
		for cell in row:
			if cell.has_bomb and not cell._state == 2: # 2 = FLAGGED
				return false
	return true

func set_mode(mode: Mode) -> void:
	if mode == _mode:
		return
	# if mode = NORMAL then make a rectangular grid
	# if mode = CUSTOM then make a randomly-connected shape grid with cells that
	# can show either surrounding square 8 or surrounding square 24
	_mode = mode
	if _mode == Mode.NORMAL:
		generate_grid(_width)
	else:
		# TODO
		pass

func set_difficulty(diff: Difficulty) -> void:
	# diffuclty determines max size of board and number of bombs
	if diff == _difficulty:
		return
	
	_difficulty = diff
	if _difficulty == Difficulty.EASY:
		_width = 8
		_num_bombs = 16
		generate_grid(_width)
	elif _difficulty == Difficulty.MEDIUM:
		_width = 12
		_num_bombs = 24
		generate_grid(_width)
	elif _difficulty == Difficulty.HARD:
		_width = 18
		_num_bombs = 36
		generate_grid(_width)
