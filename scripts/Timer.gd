extends RichTextLabel

var _time_passed: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_time_passed = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time_passed += delta
	text = "[img height=1.25em color=ffffffff]textures/stopwatch.png[/img] [b][color=ffffffff]%d[/color][/b]" % roundi(_time_passed)
