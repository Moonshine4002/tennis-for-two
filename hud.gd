extends CanvasLayer


func _ready() -> void:
	pass  # Replace with function body.


func _process(delta: float) -> void:
	pass


func set_left_arrow(rotation, force):
	$ArrowLeft.rotation = rotation
	$ArrowLeft.scale = Vector2(0.04, (force + 0.5) * 0.04)


func set_right_arrow(rotation, force):
	$ArrowRight.rotation = rotation
	$ArrowRight.scale = Vector2(0.04, (force + 0.5) * 0.04)
