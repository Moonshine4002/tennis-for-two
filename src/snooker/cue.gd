extends Node2D


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	position = get_global_mouse_position()


func set_cue(angle: float):
	rotation = angle


func set_force(percentage: float):
	$ColorRect.scale.y = percentage
