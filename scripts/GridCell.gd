extends TextureButton

enum CellState {HIDDEN, SHOWN, FLAGGED, BOMBED}
signal on_cell_changed(coord: Vector2i, state: CellState)

@onready var _label: RichTextLabel = $Number
@onready var _bomb_icon: Node = $Bomb
@onready var _flag_icon: Node = $Flag

var neighbours: Array = []
var coordinate: Vector2i = Vector2i.ZERO
var has_bomb: bool = false
var _state: CellState = CellState.HIDDEN

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT:
			if has_bomb:
				_state = CellState.BOMBED
				_is_bombed()
			else:
				_state = CellState.SHOWN
				_is_shown()
			on_cell_changed.emit(coordinate, _state)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
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

func _is_shown() -> void:
	_label.visible = true
	_label.text = "%d" % _get_num_bombs()
	_bomb_icon.visible = false
	_flag_icon.visible = false
	self.disabled = true

func _is_bombed() -> void:
	_label.visible = false
	_bomb_icon.visible = true
	_flag_icon.visible = false
	self.disabled = true

func _is_flagged() -> void:
	_label.visible = false
	_bomb_icon.visible = false
	_flag_icon.visible = true

func _is_hidden() -> void:
	_label.visible = false
	_bomb_icon.visible = false
	_flag_icon.visible = false
