#@tool
extends Node2D
class_name Oscilloscope

@export var width := 800
@export var height := 600
@export var percentage := Vector2()
@export var percentages: Array[Vector2] = []

@export var strength := 5.0
@export var base := Color.SKY_BLUE
@export var intensity := 2.0
@export var attenuation := 0.1
@export var frequency := 60.0

@export var texture: Texture2D
@export var texture_rect: Rect2

var action_point := 0.0


func _ready() -> void:
	Dot.s_dots.clear()


func _process(delta: float) -> void:
	add_dot()
	add_dots(delta)
	Dot.s_update(delta)
	queue_redraw()


func add_dots(delta: float) -> void:
	for percentage in percentages:
		var coordinate := Vector2(width * percentage.x, height * percentage.y)
		Dot.new(self, coordinate, strength, base, intensity, attenuation)

	'''
	if percentages.size() == 0:
		return
	action_point += delta
	var step := 1 / frequency
	while action_point > 0:
		var percent := 1 - action_point / delta

		var index := int(percentages.size() * percent)
		var percentage0 := percentages[index]
		var percentage1: Vector2
		if index == percentages.size() - 1:
			percentage1 = percentage0
		else:
			percentage1 = percentages[index + 1]
		var percentage := (percentage0 + percentage1) / 2
		var coordinate := Vector2(width * percentage.x, height * percentage.y)
		Dot.new(self, coordinate, strength, base, intensity, attenuation)

		action_point -= step
	'''


func add_dot() -> void:
	if percentage == Vector2():
		return
	var coordinate := Vector2(width * percentage.x, height * percentage.y)
	Dot.new(self, coordinate, strength, base, intensity, attenuation)


func _draw():
	if texture_rect:
		draw_texture_rect_region(texture, Rect2(0, 0, width, height), texture_rect)
	else:
		draw_texture_rect(texture, Rect2(0, 0, width, height), false)
	Dot.s_draw()


class Dot:
	static var s_dots: Array[Dot] = []

	var canvas: CanvasItem
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
		canvas_: CanvasItem,
		coordinate_: Vector2,
		radius_: float,
		color_: Color,
		intensity_ := 2.0,
		fade_ := 0.1,
		fade_init := 0.0,
	) -> void:
		canvas = canvas_
		coordinate = coordinate_
		radius = radius_
		color = color_
		intensity = intensity_
		fade = fade_
		s_dots.append(self)
		update(fade_init)

	static func s_draw():
		for dot in Dot.s_dots:
			dot.draw()

	func draw() -> void:
		canvas.draw_circle(coordinate, radius, color)
		#canvas.draw_polyline(coordinates, color, radius / 2)

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
