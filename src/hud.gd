extends CanvasLayer


func _ready() -> void:
	pass  # Replace with function body.


func _process(_delta: float) -> void:
	pass


func set_left_arrow(rotation_, force):
	$ArrowLeft.rotation = rotation_
	$ArrowLeft.scale = Vector2(0.04, (force + 0.5) * 0.04)


func set_right_arrow(rotation_, force):
	$ArrowRight.rotation = rotation_
	$ArrowRight.scale = Vector2(0.04, (force + 0.5) * 0.04)
