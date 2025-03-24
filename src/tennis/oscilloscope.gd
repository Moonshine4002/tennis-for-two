#@tool
extends Node2D
class_name Oscilloscope

@export var width := 800
@export var height := 600
@export var percentage := Vector2()
@export var percentages: Array[Vector2] = []

@export var strength := 2.0
@export var color := Color.SKY_BLUE
@export var intensity := 2.0
@export var life := 1.0
@export var noise := Vector2(1, 1)
@export var shift := Vector2(0, 0)

@export var texture: Texture2D
@export var texture_rect: Rect2

var dots: Array[Dot] = []
var polys: Array[Poly] = []


func _process(delta: float) -> void:
	update(delta)
	add_noise()
	add_dot()
	add_dots()
	add_polyline()
	queue_redraw()


func update(delta: float) -> void:
	for dot in dots:
		if not dot.update(delta):
			dots.erase(dot)
	for poly in polys:
		if not poly.update(delta):
			polys.erase(poly)


func add_polyline() -> void:
	var coordinates: Array[Vector2] = []
	for percentage in percentages:
		coordinates.append(Vector2(width * percentage.x, height * percentage.y))
	polys.append(Poly.new(self, coordinates, color, strength, intensity, life / 5))


func add_dots() -> void:
	return
	for percentage in percentages:
		var coordinate := Vector2(width * percentage.x, height * percentage.y)
		dots.append(Dot.new(self, coordinate, strength / 2, color, intensity, life / 5))


func add_dot() -> void:
	if percentage == Vector2():
		return
	var coordinate := Vector2(width * percentage.x, height * percentage.y)
	dots.append(Dot.new(self, coordinate, strength / 2, color, intensity, life / 5))  # 5τ


func _draw():
	if texture_rect:
		draw_texture_rect_region(texture, Rect2(0, 0, width, height), texture_rect)
	else:
		draw_texture_rect(texture, Rect2(0, 0, width, height), false)
	for dot in dots:
		dot.draw()
	for poly in polys:
		poly.draw()


func add_noise():
	var shift_x = randfn(0, shift.x / width)
	var shift_y = randfn(0, shift.y / height)
	for i in range(percentages.size()):
		percentages[i].x += shift_x + randfn(0, noise.x / width)
		percentages[i].y += shift_y + randfn(0, noise.y / height)


class Poly:
	extends Primitive
	var coordinates: Array[Vector2]
	var width: float

	func _init(
		canvas_: CanvasItem,
		coordinates_: Array[Vector2],
		base_: Color,
		width_: float,
		intensity_ := 2.0,
		lifespan_ := 0.1,
	) -> void:
		coordinates = coordinates_  # TODO
		width = width_
		super._init(canvas_, base_, intensity_, lifespan_)

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
		base_: Color,
		intensity_ := 2.0,
		lifespan_ := 0.1,
	) -> void:
		coordinate = coordinate_
		radius = radius_
		super._init(canvas_, base_, intensity_, lifespan_)

	func draw() -> void:
		canvas.draw_circle(coordinate, radius, color)


class Primitive:
	var canvas: CanvasItem
	var base: Color
	var intensity: float
	var lifespan: float
	var color: Color
	var _time: float

	func _init(
		canvas_: CanvasItem,
		base_: Color,
		intensity_ := 2.0,
		lifespan_ := 0.1,
	) -> void:
		canvas = canvas_
		base = base_
		intensity = intensity_
		lifespan = lifespan_
		color = Color.MAGENTA
		_time = Time.get_ticks_usec() / 1e6
		update_color()

	func update(delta: float) -> bool:
		if lifespan == 0:
			return false
		update_color()
		if _color_to_grey() <= 0.66:
			return false
		return true

	func update_color() -> void:
		if lifespan == 0:
			color = base * intensity
			color.a = base.a
			return
		var delta := Time.get_ticks_usec() / 1e6 - _time
		var attenuation := intensity * exp(-delta / lifespan)
		color = base * attenuation
		color.a = base.a

	func _color_to_grey() -> float:
		return (color.r * 0.299 + color.g * 0.587 + color.b * 0.114) * color.a
