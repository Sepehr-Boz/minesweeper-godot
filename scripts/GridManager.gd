extends Node2D

enum Mode {NORMAL, CUSTOM}
enum Difficulty {EASY, MEDIUM, HARD}

@export var _mode: Mode = Mode.NORMAL
@export var _difficulty: Difficulty = Difficulty.EASY
@export var _width: int = 16
@export var _height: int = 16
@export var _num_bombs: int = 16

var _cell_asset: PackedScene = preload("res://scenes/grid_cell.tscn")
@onready var _cell_container: Node = $"Cell Container"
@onready var _camera: Camera2D = $"../Camera2D"
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _cells: Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_grid(_width, _height)

func generate_grid(width: int, height: int) -> void:
	_camera.position = Vector2(width * 24, height * 24)
	var vp: Vector2 = get_viewport_rect().size
	print(vp)
	var grid_size: Vector2 = Vector2(float(width) * 52, float(height) * 52)
	print(grid_size)
	var grid_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(width * 48, height * 48))
	var zoom: float = min(vp.x / grid_size.x, vp.y / grid_size.y)
	_camera.rect = grid_rect
	_camera.zoom = Vector2(zoom, zoom)
	# set all the cells and save them
	var num_bombs_left_to_place: int = _num_bombs
	for i in width:
		var row: Array[Node] = []
		for j in height:
			var instance: Node = _cell_asset.instantiate()
			_cell_container.add_child(instance)
			var pos: Vector2i = Vector2i(i, j)
			instance.position = pos * 48
			instance.coordinate = pos
			instance.on_cell_changed.connect(_on_cell_changed)
			if num_bombs_left_to_place > 0 && _rng.randf() > 0.5:
				num_bombs_left_to_place -= 1
				instance.has_bomb = true
				print("bomb at %v" % pos)
			row.append(instance)
		_cells.append(row)
	# loop through all the cells to find their neighbours and add them
	for i in width:
		for j in height:
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
			if 0 < i and j < height - 1:
				neighbours.append(_cells[i - 1][j + 1])
			if j < height - 1:
				neighbours.append(_cells[i][j + 1])
			if j < height - 1 and i < width - 1:
				neighbours.append(_cells[i + 1][j + 1])
			cell.neighbours = neighbours

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
		generate_grid(_width, _height)
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
		_height = 16
		generate_grid(_width, _height)
	elif _difficulty == Difficulty.MEDIUM:
		_width = 16
		_height = 24
		generate_grid(_width, _height)
	elif _difficulty == Difficulty.HARD:
		_width = 24
		_height = 32
		generate_grid(_width, _height)
