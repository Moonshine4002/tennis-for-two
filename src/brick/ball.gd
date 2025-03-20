extends RigidBody2D
class_name BrickBall

signal hit_audio(kind: String, posi: Vector2)
@export var velocity_ := 600.0


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	set_linear_velocity(linear_velocity.normalized() * velocity_)


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	if body is BrickBall:
		hit_audio.emit("wood", position)
	elif body is BrickBrick:
		body.queue_free()
		hit_audio.emit("wood", position)
	elif body is BrickPlatform:
		hit_audio.emit("hard", position)
	elif body is BrickIndestructible:
		hit_audio.emit("metal", position)
	else:
		hit_audio.emit("wood", position)
