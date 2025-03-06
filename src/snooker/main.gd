extends Node2D

@onready var ball_scene: PackedScene = load("res://src/snooker/ball.tscn")


func _ready() -> void:
	add_ball(SnookerBall.Ball.WRITE, Vector2(100, 200))
	add_ball(SnookerBall.Ball.RED, Vector2(150, 250))


func _process(_delta: float) -> void:
	pass


func add_ball(ball: SnookerBall.Ball, posi: Vector2) -> void:
	var ball_packed = ball_scene.instantiate()
	ball_packed.init(ball, posi)
	add_child(ball_packed)
