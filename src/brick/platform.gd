extends StaticBody2D
class_name BrickPlatform


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	position.x = get_global_mouse_position().x
