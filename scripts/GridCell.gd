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
	if disabled or Engine.time_scale == 0:
		return
	if event is InputEventMouseButton and event.is_pressed():
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and _state == CellState.HIDDEN:
			if has_bomb:
				_state = CellState.BOMBED
				_is_bombed()
			else:
				expand()
				_state = CellState.SHOWN
			on_cell_changed.emit(coordinate, _state)
		elif event.button_index == MOUSE_BUTTON_RIGHT and (_state == CellState.HIDDEN or _state == CellState.FLAGGED):
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
		if not cell:
			continue
		if cell.has_bomb:
			num += 1
	return num

func _get_num_flags() -> int:
	var num: int = 0
	for cell: Node in neighbours:
		if not cell:
			continue
		if cell._state == CellState.FLAGGED:
			num += 1
	return num

func expand() -> void:
	if _state == CellState.SHOWN or _state == CellState.FLAGGED:
		return
	_is_shown()
	_state = CellState.SHOWN
	if _get_num_bombs() == 0 and not has_bomb:
		for cell in neighbours:
			if not cell:
				continue
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
