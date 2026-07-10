extends Camera2D

@export_range(0.0001, 1) var _zoom_increment: float = 0.01
var _min_zoom: float = 0.01
var _max_zoom: float = 2.5

@export_range(0.0001, 5) var _drag_increment: float = 1
@export_range(0.0001, 1) var _center_increment: float = 0.01

@onready var _zoom_increment_vector: Vector2 = Vector2(_zoom_increment, _zoom_increment)
@onready var _min_zoom_vector: Vector2 = Vector2(_min_zoom, _min_zoom)
@onready var _max_zoom_vector: Vector2 = Vector2(_max_zoom, _max_zoom)

var rect: Rect2
var _last_pointer_position: Vector2 = Vector2.ZERO
var _is_dragging: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		# if scrollwheel used then zoom in/out
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= _zoom_increment_vector
			zoom = clamp(zoom, _min_zoom_vector, _max_zoom_vector)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += _zoom_increment_vector
			zoom = clamp(zoom, _min_zoom_vector, _max_zoom_vector)
		# if left click down somewhere thats not a cell then start dragging
	 	# once left click released then stop dragging
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.pressed
	elif event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		if _last_pointer_position == Vector2.ZERO:
			_last_pointer_position = event.position
		if _is_dragging:
			var diff: Vector2 = event.position - _last_pointer_position
			position += -diff * _drag_increment
		_last_pointer_position = event.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# check if position is out of the rect and if it is then drag it back towards
	# the center
	if not rect.has_point(position):
		var vec: Vector2 = rect.get_center() - position
		position += vec * _center_increment
