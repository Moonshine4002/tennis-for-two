extends RigidBody2D

signal ball_hit
signal ball_hit_floor
signal ball_screen_exited

enum Side { LEFT, RIGHT }

@export var force_speed = 3
@export var rotation_speed = 2 * PI
@export var thrust = Vector2(0, -25000)

var left_force = 0.5
var right_force = 0.5
var left_rotation = 0
var right_rotation = 0

var left_permission = true
var right_permission = true
var reset = false
var side = Side.LEFT


func _ready() -> void:
	pass  # Replace with function body.


func _process(delta: float) -> void:
	# TODO: move
	if Input.is_action_pressed("left_turn_clockwise"):
		left_rotation += rotation_speed * delta
	if Input.is_action_pressed("left_turn_counterclockwise"):
		left_rotation -= rotation_speed * delta
	if Input.is_action_pressed("left_up"):
		left_force += force_speed * delta
	if Input.is_action_pressed("left_down"):
		left_force -= force_speed * delta
	left_force = clamp(left_force, 0, 1)

	if Input.is_action_pressed("right_turn_clockwise"):
		right_rotation += rotation_speed * delta
	if Input.is_action_pressed("right_turn_counterclockwise"):
		right_rotation -= rotation_speed * delta
	if Input.is_action_pressed("right_up"):
		right_force += force_speed * delta
	if Input.is_action_pressed("right_down"):
		right_force -= force_speed * delta
	right_force = clamp(right_force, 0, 1)


func _reset() -> bool:
	if reset:
		reset = false
		var center = get_viewport_rect().size / 2
		var rand_y = randf_range(150, 250)
		var rand_x = randf_range(300, 500)
		if side == Side.LEFT:
			position = center + Vector2(-rand_x, -rand_y)
		else:
			position = center + Vector2(rand_x, -rand_y)
		linear_velocity = Vector2(0, 0)
		angular_velocity = 0
		return true
	return false


func _integrate_forces(state):
	if _reset():
		return

	var state_flag := false
	var normalized_vector
	var force_vector
	var thrust_vector
	if Input.is_action_pressed("left_hit") and left_permission:
		print("left hit")
		ball_hit.emit()
		left_permission = false
		normalized_vector = thrust.normalized().rotated(left_rotation)
		force_vector = normalized_vector * left_force * 1250
		thrust_vector = force_vector * thrust.length()
		state_flag = true
	elif Input.is_action_pressed("right_hit") and right_permission:
		print("right hit")
		ball_hit.emit()
		right_permission = false
		normalized_vector = thrust.normalized().rotated(right_rotation)
		force_vector = normalized_vector * right_force * 1250
		thrust_vector = force_vector * thrust.length()
		state_flag = true

	if state_flag:
		print(state.linear_velocity, normalized_vector, force_vector, thrust_vector)
		state.linear_velocity = (
			-(state.linear_velocity - force_vector).reflect(normalized_vector) * 0.8 + force_vector
		)
		#state.apply_force(thrust_vector)
		#state.apply_torque()


func _on_body_entered(body: Node) -> void:
	ball_hit_floor.emit()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	ball_screen_exited.emit()


func reset_ball(player_side):
	reset = true
	side = player_side
