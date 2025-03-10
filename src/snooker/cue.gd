extends Node2D


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	position = get_global_mouse_position()


func set_cue(angle: float):
	rotation = angle


func set_force(percentage: float):
	$ColorRect.scale.y = percentage


func fade() -> void:
	$Cue.modulate.a = 0.5
	$ColorRect.modulate.a = 0.5


func solid() -> void:
	$Cue.modulate.a = 1
	$ColorRect.modulate.a = 1
