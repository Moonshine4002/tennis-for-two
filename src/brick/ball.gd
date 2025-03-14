extends RigidBody2D
class_name BrickBall

@export var velocity := 750.0


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	set_linear_velocity(linear_velocity.normalized() * velocity)


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	if body is BrickBrick:
		body.queue_free()
	if body is BrickPlatform:
		return
