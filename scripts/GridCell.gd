extends Button

enum CellState {HIDDEN, SHOWN, FLAGGED, BOMBED}
signal on_cell_changed(coord: Vector2i, state: CellState)

var _flag_icon: Texture2D = preload("res://textures/flag_triangle.png")
var _bomb_icon: Texture2D = preload("res://textures/fire.png")

var neighbours: Array = []
var coordinate: Vector2i = Vector2i.ZERO
var has_bomb: bool = false
var _state: CellState = CellState.HIDDEN

func _ready() -> void:
	_is_hidden()

func _gui_input(event: InputEvent) -> void:
	if disabled:
		return
	if event is InputEventMouseButton and event.is_pressed():
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and _state == CellState.SHOWN and _get_num_flags() == _get_num_flags():
			# TODO: reveal the surrounding cells when clicked on it again
			# IFF there are n flagged where n is the number of bombs shown on
			# this cell
			pass
		elif event.button_index == MOUSE_BUTTON_LEFT and _state == CellState.HIDDEN:
			if has_bomb:
				_state = CellState.BOMBED
				_is_bombed()
			else:
				expand()
				_state = CellState.SHOWN
			on_cell_changed.emit(coordinate, _state)
		elif event.button_index == MOUSE_BUTTON_RIGHT and _state == CellState.HIDDEN:
			if _state == CellState.HIDDEN:
				_state = CellState.FLAGGED
				_is_flagged()
			elif _state == CellState.FLAGGED:
				_state = CellState.HIDDEN
				_is_hidden()
			on_cell_changed.emit(coordinate, _state)
			
			

func _get_num_bombs() -> int:
	var num: int = 0
	for cell: Node in neighbours:
		if cell.has_bomb:
			num += 1
	return num

func _get_num_flags() -> int:
	var num: int = 0
	for cell: Node in neighbours:
		if cell._state == CellState.FLAGGED:
			num += 1
	return num

func expand() -> void:
	if _state == CellState.SHOWN or _state == CellState.FLAGGED:
		return
	# recursively call other cells to also show themselves if they are also within a 0
	# radius of a bomb until a cell with a non-0 number of surrounding bombs is found
	_is_shown()
	_state = CellState.SHOWN
	if (_get_num_bombs() == 0 and not has_bomb) or _get_num_bombs() == _get_num_flags():
		for cell in neighbours:
			cell.expand()

func _is_shown() -> void:
	var num_bombs: int = _get_num_bombs()
	if num_bombs == 0:
		text = ""
	else:
		text = "%d" % _get_num_bombs()
	icon = null
	self.disabled = true

func _is_bombed() -> void:
	text = ""
	icon = _bomb_icon
	self.disabled = true

func _is_flagged() -> void:
	text = ""
	icon = _flag_icon

func _is_hidden() -> void:
	text = ""
	icon = null
