extends GameTemplate2D

signal level_over(win: bool)

@onready var ball_scene: PackedScene = load("res://src/brick/ball.tscn")
@onready var brick_scene: PackedScene = load("res://src/brick/brick.tscn")
@onready var indestructible_scene: PackedScene = load("res://src/brick/indestructible.tscn")

@onready var life := 1  # override

var level := 1

var exit_flag := false
var prolong_flag := false
var precise_flag := false
signal precise_signal

var items := {
	"proliferation": 0,
	"prolong": 0,
	"precise": 0,
}


func _ready() -> void:
	select_level(level)


func _process(_delta: float) -> void:
	if exit_flag:
		var timer := Timer.new()
		timer.wait_time = 10
		add_child(timer)
		timer.start()
		await timer.timeout
		exit.emit()

	$HUD/Info.text = "level: {0}\nlife: {1}".format([level, life])
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

	var items_index := 0
	for value in items.values():
		var text: String = $ItemList.get_item_text(items_index)
		text = text.rstrip("0123456789")
		text += str(value)
		$ItemList.set_item_text(items_index, text)
		items_index += 1

	if get_tree().get_nodes_in_group("BrickBall").size() > 99:
		$HUD/BallNumberInfo.show()
	else:
		$HUD/BallNumberInfo.hide()

	if precise_flag:
		$HUD/PreciseInfo.show()
	else:
		$HUD/PreciseInfo.hide()


func select_level(lv: int) -> void:
	# supply
	life += 10
	items["proliferation"] += 3
	items["prolong"] += 5
	items["precise"] += 2

	for child in get_children():
		if child is BrickBall:
			child.queue_free()

	# level
	for indestructible in get_tree().get_nodes_in_group("BrickIndestructible"):
		indestructible.display(str(level))
	match lv:
		1:
			life = 30
			items["proliferation"] = 10
			items["prolong"] = 10
			items["precise"] = 10
			for x in range(32 * 10, 32 * 20, 64):
				for y in range(16 * 10, 16 * 20, 32):
					add_brick(Vector2(x, y))
		2:
			for x in range(32 * 10, 32 * 20, 32):
				for y in range(16 * 10, 16 * 20, 16):
					add_brick(Vector2(x, y))
		3:
			for x in range(32 * 10, 32 * 20, 32):
				for y in range(16 * 10, 16 * 24, 16):
					add_brick(Vector2(x, y))
		4:
			for x in range(32 * 0, 32 * 30, 64):
				for y in range(16 * 0, 16 * 24, 32):
					add_brick(Vector2(x + 16, y))
		5:
			for x in range(32 * 0, 32 * 30, 32):
				for y in range(16 * 0, 16 * 24, 16):
					var flag := true
					for node in get_tree().get_nodes_in_group("BrickIndestructible"):
						if node.tag != str(level):
							continue
						if (
							Vector2(x + 32, y + 8) == node.position
							or Vector2(x, y + 8) == node.position
						):
							flag = false
					if flag:
						add_brick(Vector2(x, y))
		6:
			level_over.emit(true)
		100:
			for x in range(0, 32 * 30, 32):
				for y in range(0, 16 * 28, 16):
					add_brick(Vector2(x, y))
		_:
			push_warning("Wrong level!")


func add_ball() -> void:
	if get_tree().get_nodes_in_group("BrickBall").size() > 99:
		return
	if life == 0:
		return
	life -= 1
	var ball: BrickBall = ball_scene.instantiate()
	ball.position = $Platform.position
	ball.position.x += 32
	ball.position.y -= 8
	ball.set_linear_velocity(Vector2(randf_range(-1, 1), -1))
	if precise_flag:
		ball.set_linear_velocity(get_global_mouse_position() - ball.position)
		precise_signal.emit()
	ball.connect("hit_audio", _on_ball_hit_audio)
	add_child(ball)


func add_brick(posi: Vector2) -> void:
	var brick: BrickBrick = brick_scene.instantiate()
	brick.position = posi
	add_child(brick)


func _on_bottom_area_body_entered(ball: Node2D) -> void:
	if ball is not BrickBall:
		return
	ball.queue_free()

	# supply
	if randf() < 0.01:
		items["proliferation"] += 1
	elif randf() < 0.03:
		items["prolong"] += 1
	elif randf() < 0.005:
		items["precise"] += 1
	#call_deferred("add_ball")


func _on_level_over(win: bool) -> void:
	if win:
		$HUD/Info.text = "you win!"
	else:
		$HUD/Info.text = "you lose!"
	exit_flag = true


func _on_item_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		return
	match index:
		0:
			proliferation()
		1:
			prolong()
		2:
			precise()


func proliferation() -> void:
	if get_tree().get_nodes_in_group("BrickBall").size() > 99:
		return
	$HUD/ItemInfo.hide()
	if items["proliferation"] <= 0:
		return
	items["proliferation"] -= 1
	for child in get_children():
		if child is not BrickBall:
			continue
		var ball: BrickBall = ball_scene.instantiate()
		ball.position = child.position
		ball.linear_velocity = child.linear_velocity
		add_child(ball)

		ball.linear_velocity = ball.linear_velocity.rotated(PI / 8)
		child.linear_velocity = child.linear_velocity.rotated(-PI / 8)


func prolong() -> void:
	$HUD/ItemInfo.hide()
	if prolong_flag:
		return
	if items["prolong"] <= 0:
		return
	items["prolong"] -= 1
	prolong_flag = true
	$Platform/Sprite2D.scale.x = 2
	$Platform/CollisionShape2D.scale.x = 2
	$Platform/CollisionShape2D.scale.y = 2
	$Platform/CollisionShape2D.position.y = 50
	var timer = Timer.new()
	add_child(timer)
	timer.start(5)
	await timer.timeout
	timer.queue_free()
	$Platform/Sprite2D.scale.x = 1
	$Platform/CollisionShape2D.scale.x = 1
	$Platform/CollisionShape2D.scale.y = 1
	$Platform/CollisionShape2D.position.y = 29
	prolong_flag = false


func precise() -> void:
	if precise_flag:
		return
	if items["precise"] <= 0:
		return
	items["precise"] -= 1
	var timer := Timer.new()
	add_child(timer)
	precise_flag = true
	timer.start(1)
	await precise_signal
	precise_flag = false
	timer.queue_free()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("num1"):
		proliferation()
	elif event.is_action_pressed("num2"):
		prolong()
	elif event.is_action_pressed("num3"):
		precise()


func _on_ball_hit_audio(kind: String, posi: Vector2) -> void:
	var timer := Timer.new()
	var audio := AudioStreamPlayer2D.new()
	audio.position = posi
	add_child(timer)
	add_child(audio)

	match kind:
		"hard":
			audio.stream = load("res://art/audio/Hits/Hard Hits.wav")
			audio.play(0.0)
			timer.start(0.14)
		"wood":
			audio.stream = load("res://art/audio/Hits/Wood Hits.wav")
			audio.play(0.16)
			timer.start(0.16)
		"metal":
			audio.stream = load("res://art/audio/Hits/Metal Hit.wav")
			audio.play(0.12)
			timer.start(0.14)
	await timer.timeout
	timer.queue_free()
	audio.queue_free()


func _on_hud_exit() -> void:
	exit.emit()
