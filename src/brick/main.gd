extends Node

@onready var ball_scene: PackedScene = load("res://src/brick/ball.tscn")
@onready var brick_scene: PackedScene = load("res://src/brick/brick.tscn")


func _ready() -> void:
	level(1)
	add_ball()


func _process(_delta: float) -> void:
	pass


func level(lv: int) -> void:
	match lv:
		1:
			for x in range(0, 32 * 30, 32):
				for y in range(0, 10 * 44, 10):
					add_brick(Vector2(x, y))
		2:
			pass
		_:
			push_warning("Wrong level!")


func add_ball() -> void:
	var ball: BrickBall = ball_scene.instantiate()
	ball.position = Vector2(200, 500)
	ball.set_linear_velocity(Vector2(1000, -500))
	add_child(ball)


func add_brick(posi: Vector2) -> void:
	var brick: BrickBrick = brick_scene.instantiate()
	brick.position = posi
	add_child(brick)


func _on_bottom_area_body_entered(ball: Node2D) -> void:
	if ball is not BrickBall:
		return
	ball.queue_free()
	call_deferred("add_ball")
