extends RigidBody2D

signal ball_hit
signal ball_hit_floor
signal ball_screen_exited

@export var force_speed = 3
@export var rotation_speed = PI
@export var thrust = Vector2(0, -25000)

var left_force = 1
var right_force = 1
var left_rotation = 0
var right_rotation = 0

var left_permission = true
var right_permission = true
var reset = false
var side = "left"


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if Input.is_action_pressed("left_turn_clockwise"):
		left_rotation += rotation_speed * delta
	if Input.is_action_pressed("left_turn_counterclockwise"):
		left_rotation -= rotation_speed * delta
	if Input.is_action_pressed("left_up"):
		left_force += force_speed * delta
	if Input.is_action_pressed("left_down"):
		left_force -= force_speed * delta
	left_force = clamp(left_force, 0.5, 2)
	
	if Input.is_action_pressed("right_turn_clockwise"):
		right_rotation += rotation_speed * delta
	if Input.is_action_pressed("right_turn_counterclockwise"):
		right_rotation -= rotation_speed * delta
	if Input.is_action_pressed("right_up"):
		right_force += force_speed * delta
	if Input.is_action_pressed("right_down"):
		right_force -= force_speed * delta
	right_force = clamp(right_force, 0.5, 2)


func _integrate_forces(state):
	if Input.is_action_pressed("left_hit") and left_permission:
		print("left hit")
		ball_hit.emit()
		left_permission = false
		var force_vector = thrust * left_force
		state.apply_force(force_vector.rotated(left_rotation))
	elif Input.is_action_pressed("right_hit") and right_permission:
		print("right hit")
		ball_hit.emit()
		right_permission = false
		var force_vector = thrust * right_force
		state.apply_force(force_vector.rotated(right_rotation))
	#state.apply_torque()
	
	if reset:
		reset = false
		if side == "left":
			position = Vector2(100, 100)
		else:
			position = Vector2(get_viewport_rect().size.x - 100, 100)
		linear_velocity = Vector2(0, 0)
		angular_velocity = 0


func _on_body_entered(body: Node) -> void:
	ball_hit_floor.emit()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	ball_screen_exited.emit()


func reset_ball(player_side):
	reset = true
	side = player_side
