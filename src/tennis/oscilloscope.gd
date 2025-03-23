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

@export var strength := 5.0
@export var base := Color.SKY_BLUE
@export var intensity := 2.0
@export var attenuation := 0.1
@export var frequency := 60.0:
	set(value):
		frequency = value

@export var texture: Texture2D:
	set(value):
		texture = value
		#queue_redraw()
@export var texture_rect: Rect2


func _process(delta: float) -> void:
	add_dot()
	Dot.s_update(delta)
	queue_redraw()


func add_dot() -> void:
	var coordinate := Vector2(width * horizontal, height * vertical)
	Dot.new(coordinate, strength, base, intensity, attenuation)


func _draw():
	if texture_rect:
		draw_texture_rect_region(texture, Rect2(0, 0, width, height), texture_rect)
	else:
		draw_texture_rect(texture, Rect2(0, 0, width, height), false)
	draw_dots()


func draw_dots():
	for dot in Dot.s_dots:
		draw_circle(dot.coordinate, dot.radius, dot.color)


class Dot:
	static var s_dots: Array[Dot] = []

	var coordinate: Vector2
	var radius: float
	var color: Color:
		set(value):
			color = value
		get():
			return Color(color.r * intensity, color.g * intensity, color.b * intensity, color.a)
	var intensity: float
	var fade: float

	func _init(
		coordinate_: Vector2, radius_: float, color_: Color, intensity_ := 2.0, fade_ := 0.1
	) -> void:
		coordinate = coordinate_
		radius = radius_
		color = color_
		s_dots.append(self)
		intensity = intensity_
		fade = fade_

	static func s_update(delta: float) -> void:
		for dot in s_dots:
			dot.update(delta)

	func update(delta: float) -> void:
		intensity *= pow(fade, delta)
		if _color_to_grey() <= 0.66:
			#color = Color()
			s_dots.erase(self)

	func _color_to_grey() -> float:
		return (color.r * 0.299 + color.g * 0.587 + color.b * 0.114) * color.a
