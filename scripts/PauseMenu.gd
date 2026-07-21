extends CanvasLayer

@onready var _continue_button: Button = $"VBoxContainer/Continue Button"
@onready var _reset_button: Button = $"VBoxContainer/Reset Button"
@onready var _difficulty_dropdown: OptionButton = $"VBoxContainer/Difficulty Dropdown"
@onready var _mode_dropdown: OptionButton = $"VBoxContainer/Mode Dropdown"
@onready var _quit_button: Button = $"VBoxContainer/Quit Button"

@onready var _grid_manager: GridContainer = $"../Grid"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_continue_button.pressed.connect(_on_esc)
	_reset_button.pressed.connect(_reset_game)
	_difficulty_dropdown.item_selected.connect(_set_difficulty)
	_mode_dropdown.item_selected.connect(_set_mode)
	_quit_button.pressed.connect(_quit_game)
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		_on_esc()

func _on_esc() -> void:
	visible = not visible
	if visible:
		Engine.time_scale = 0
	else:
		Engine.time_scale = 1

func _reset_game() -> void:
	_grid_manager.reset()
	_on_esc()

func _set_difficulty(item_index: int) -> void:
	_grid_manager.set_difficulty(item_index)

func _set_mode(item_index: int) -> void:
	_grid_manager.set_mode(item_index)

func _quit_game() -> void:
	get_tree().quit()
