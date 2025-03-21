#@tool
extends Node2D
class_name Oscilloscope

@export var width := 800
@export var height := 600
@export var horizontal := 0.0:
	set(value):
		horizontal = value
		#queue_redraw()
@export var vertical := 0.0:
	set(value):
		vertical = value
		#queue_redraw()

@export var texture: Texture2D:
	set(value):
		texture = value
		#queue_redraw()


func _process(delta: float) -> void:
	horizontal = randf()
	vertical = randf()

	var position_ := Vector2(width * horizontal, height * vertical)
	var radius := 10
	var color := Color.SKY_BLUE * 2
	Dot.new(position_, radius, color)

	Dot.s_update(delta)
	queue_redraw()


func _draw():
	draw_texture(texture, Vector2())
	draw_dot()


func draw_dot():
	for dot in Dot.s_dots:
		draw_circle(dot.position, dot.radius, dot.color)


class Dot:
	static var s_dots: Array[Dot] = []
	static var fade := 0.01

	var position: Vector2
	var radius: float
	var color: Color:
		set(value):
			color = value
		get():
			return Color(color.r * intensity, color.g * intensity, color.b * intensity, color.a)
	var intensity: float

	func _init(position_: Vector2, radius_: float, color_: Color) -> void:
		position = position_
		radius = radius_
		color = color_
		s_dots.append(self)

		intensity = 1.0

	static func s_update(delta: float) -> void:
		for dot in s_dots:
			dot.update(delta)

	func update(delta: float) -> void:
		intensity *= pow(fade, delta)
		if _color_to_grey() <= 1:
			#color = Color()
			s_dots.erase(self)

	func _color_to_grey() -> float:
		return (color.r * 0.299 + color.g * 0.587 + color.b * 0.114) * color.a
