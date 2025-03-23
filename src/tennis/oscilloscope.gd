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

@export var texture: Texture2D
@export var texture_rect: Rect2

var action_point := 0.0

var dots: Array[Dot] = []
var polys: Array[Poly] = []


func _process(delta: float) -> void:
	for dot in dots:
		if not dot.update(delta):
			dots.erase(dot)
	for poly in polys:
		if not poly.update(delta):
			polys.erase(poly)
	add_dot()
	add_dots(delta)
	add_polyline(delta)
	queue_redraw()


func add_polyline(delta: float) -> void:
	var coordinates: Array[Vector2] = []
	for percentage in percentages:
		coordinates.append(Vector2(width * percentage.x, height * percentage.y))
	polys.append(Poly.new(self, coordinates, base, strength, intensity, attenuation))


func add_dots(delta: float) -> void:
	return
	for percentage in percentages:
		var coordinate := Vector2(width * percentage.x, height * percentage.y)
		dots.append(Dot.new(self, coordinate, strength / 2, base, intensity, attenuation))


func add_dot() -> void:
	if percentage == Vector2():
		return
	var coordinate := Vector2(width * percentage.x, height * percentage.y)
	dots.append(Dot.new(self, coordinate, strength / 2, base, intensity, attenuation))


func _draw():
	if texture_rect:
		draw_texture_rect_region(texture, Rect2(0, 0, width, height), texture_rect)
	else:
		draw_texture_rect(texture, Rect2(0, 0, width, height), false)
	for dot in dots:
		dot.draw()
	for poly in polys:
		poly.draw()


class Poly:
	extends Primitive
	var coordinates: Array[Vector2]
	var width: float

	func _init(
		canvas_: CanvasItem,
		coordinates_: Array[Vector2],
		color_: Color,
		width_: float,
		intensity_ := 2.0,
		fade_ := 0.1,
	) -> void:
		coordinates = coordinates_  # TODO
		width = width_
		super._init(canvas_, color_, intensity_, fade_)

	func draw() -> void:
		canvas.draw_polyline(coordinates, color, width)


class Dot:
	extends Primitive
	var coordinate: Vector2
	var radius: float

	func _init(
		canvas_: CanvasItem,
		coordinate_: Vector2,
		radius_: float,
		color_: Color,
		intensity_ := 2.0,
		fade_ := 0.1,
	) -> void:
		coordinate = coordinate_
		radius = radius_
		super._init(canvas_, color_, intensity_, fade_)

	func draw() -> void:
		canvas.draw_circle(coordinate, radius, color)


class Primitive:
	var canvas: CanvasItem
	var color: Color:
		set(value):
			color = value
		get():
			return Color(color.r * intensity, color.g * intensity, color.b * intensity, color.a)
	var intensity: float
	var fade: float

	func _init(
		canvas_: CanvasItem,
		color_: Color,
		intensity_ := 2.0,
		fade_ := 0.1,
	) -> void:
		canvas = canvas_
		color = color_
		intensity = intensity_
		fade = fade_

	func update(delta: float) -> bool:
		if fade == 0:
			return false
		intensity *= pow(fade, delta)
		if _color_to_grey() <= 0.66:
			return false
		return true

	func _color_to_grey() -> float:
		return (color.r * 0.299 + color.g * 0.587 + color.b * 0.114) * color.a
