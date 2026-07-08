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
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _cells: Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_grid(_width, _height)

func generate_grid(width: int, height: int) -> void:
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
	# TODO
	print("cell at %v set to %s" % [coord, state])


func set_mode(mode: Mode) -> void:
	_mode = mode
	
func set_difficulty(diff: Difficulty) -> void:
	_difficulty = diff
