extends TileMapLayer

@export var _width: int = 16
@export var _height: int = 16
@export var _num_bombs: int = 10

@export var _flag_asset: PackedScene
@export var _text_asset: PackedScene
@export var _bomb_asset: PackedScene

var _flags: Array[Node] = []
var _has_bomb: Array[Array] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_grid(_width, _height)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var tile_pos: Vector2i = local_to_map(self.to_local(event.position))
		if tile_pos.x < 0 or tile_pos.x >= _width:
			return
		if tile_pos.y < 0 or tile_pos.y >= _height:
			return

		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT:
			_show_cell(tile_pos)
		elif event.button_index == MOUSE_BUTTON_MASK_RIGHT:
			_set_flag(tile_pos)

func make_grid(width, height) -> void:
	var num_bombs_left_to_place: int = _num_bombs
	for i in width:
		var row: Array = []
		for j in height:
			set_cell(Vector2i(i, j), 0, Vector2i(0,0), 0)
			if num_bombs_left_to_place > 0 && _rng.randf() > 0.5:
				num_bombs_left_to_place -= 1
				row.append(true)
			else:
				row.append(false)
		_has_bomb.append(row)

func _show_cell(coord: Vector2i) -> void:
	set_cell(coord, 1, Vector2i(0, 0), 0)
	if _has_bomb[coord.x][coord.y]:
		var instance = _bomb_asset.instantiate()
		add_sibling(instance)
		instance.position = self.to_global(map_to_local(coord))
		print("GAME IS LOST")
	else:
		var instance = _text_asset.instantiate()
		add_sibling(instance)
		instance.position = self.to_global(map_to_local(coord)) - Vector2(24, 24)
		# find position in local 2d array and find out number of surrounding bombs
		(instance as Label).text = "%d" % _num_surrounding_bombs(coord)
	
	# check if there are any flags at that position and if so then remove them
	for i in _flags.size():
		if local_to_map(self.to_local(_flags[i].position)).distance_to(coord) < 1:
			_flags[i].free()
			_flags.remove_at(i)
			break

func _set_flag(coord: Vector2i) -> void:
	var instance = _flag_asset.instantiate()
	add_sibling(instance)
	instance.position = self.to_global(map_to_local(coord))
	_flags.append(instance)

func _num_surrounding_bombs(coord: Vector2i) -> int:
	var num: int = 0
	# top row
	if 0 < coord.x and 0 < coord.y and _has_bomb[coord.x - 1][coord.y - 1]:
		num += 1
	if 0 < coord.y and _has_bomb[coord.x][coord.y - 1]:
		num += 1
	if 0 < coord.y and coord.x < _width - 1 and _has_bomb[coord.x + 1][coord.y - 1]:
		num += 1
	# middle row
	if 0 < coord.x and _has_bomb[coord.x - 1][coord.y]:
		num += 1
	if coord.x < _width - 1 and _has_bomb[coord.x + 1][coord.y]:
		num += 1
	# bottom row
	if 0 < coord.x and coord.y < _height - 1 and _has_bomb[coord.x - 1][coord.y + 1]:
		num += 1
	if coord.y < _height - 1 and _has_bomb[coord.x][coord.y + 1]:
		num += 1
	if coord.y < _height - 1 and coord.x < _width - 1 and _has_bomb[coord.x + 1][coord.y + 1]:
		num += 1
	return num
