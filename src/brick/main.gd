extends Node

signal level_over(win: bool)
signal exit(node: Node)

@onready var ball_scene: PackedScene = load("res://src/brick/ball.tscn")
@onready var brick_scene: PackedScene = load("res://src/brick/brick.tscn")

@onready var life := 100

var level := 1

var exit_flag := false


func _ready() -> void:
	select_level(level)


func _process(_delta: float) -> void:
	if exit_flag:
		var timer := Timer.new()
		timer.wait_time = 10
		add_child(timer)
		timer.start()
		await timer.timeout
		exit.emit(self)

	$Info.text = "life: {0}".format([life])
	var brick_flag := false
	for child in get_children():
		if child is BrickBrick:
			brick_flag = true
	if not brick_flag:
		level += 1
		select_level(level)
	if life == 0:
		var ball_flag := false
		for child in get_children():
			if child is BrickBall:
				ball_flag = true
		if not ball_flag:
			level_over.emit(false)


func select_level(lv: int) -> void:
	for child in get_children():
		if child is BrickBall:
			child.queue_free()

	match lv:
		1:
			for x in range(32 * 10, 32 * 20, 64):
				for y in range(16 * 10, 16 * 20, 32):
					add_brick(Vector2(x, y))
		2:
			for x in range(32 * 10, 32 * 20, 32):
				for y in range(16 * 10, 16 * 20, 16):
					add_brick(Vector2(x, y))
		3:
			level_over.emit(true)
		100:
			for x in range(0, 32 * 30, 32):
				for y in range(0, 16 * 28, 16):
					add_brick(Vector2(x, y))
		_:
			push_warning("Wrong level!")


func add_ball() -> void:
	if life == 0:
		return
	life -= 1
	var ball: BrickBall = ball_scene.instantiate()
	ball.position = $Platform.position
	ball.position.x += 32
	ball.set_linear_velocity(Vector2(randf_range(-1, 1), -1))
	add_child(ball)


func add_brick(posi: Vector2) -> void:
	var brick: BrickBrick = brick_scene.instantiate()
	brick.position = posi
	add_child(brick)


func _on_bottom_area_body_entered(ball: Node2D) -> void:
	if ball is not BrickBall:
		return
	ball.queue_free()
	#call_deferred("add_ball")


func _on_level_over(win: bool) -> void:
	if win:
		$Info.text = "you win!"
	else:
		$Info.text = "you lose!"
	exit_flag = true
