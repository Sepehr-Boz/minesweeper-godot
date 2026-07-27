extends RichTextLabel

@onready var _grid_manager: Node = $"../../../Grid"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_grid_manager.on_cell_flagged.connect(_update_text)

func _update_text(num_flags: int) -> void:
	text = "[img height=1.25em color=ff0000ff]textures/flag_triangle.png[/img] [b][color=ffffffff]%d[/color][/b]" % num_flags
