extends StaticBody2D
class_name BrickPlatform


func _ready() -> void:
	$AudioListener2D.make_current()


func _process(_delta: float) -> void:
	$AudioListener2D.position = get_global_mouse_position()


func _physics_process(_delta: float) -> void:
	if get_parent().precise_flag:
		return
	position.x = get_global_mouse_position().x - 32
