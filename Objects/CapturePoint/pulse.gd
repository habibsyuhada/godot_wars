extends Node2D

@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"
var pulse_max_radius: float

@export var base_radius := 0.0
@export var pulse_width := 3.0
@export var pulse_duration := 0.8
@export var pulse_gap := 0.3

var pulse_radius := 24.0
var pulse_alpha := 1.0
var team_color := Color(1, 1, 1, 1)

func _ready():
	var circle_shape = collision_shape.shape as CircleShape2D
	if circle_shape:
		pulse_max_radius = circle_shape.radius
	_start_pulse_loop()

func _draw():
	draw_arc(Vector2.ZERO, pulse_max_radius, 0.0, TAU, 48, Color(team_color.r, team_color.g, team_color.b, 0.25), 2.0)
	draw_arc(Vector2.ZERO, pulse_radius, 0.0, TAU, 48, Color(team_color.r, team_color.g, team_color.b, pulse_alpha), pulse_width)

func _start_pulse_loop():
	while true:
		pulse_radius = base_radius
		pulse_alpha = 1.0
		queue_redraw()

		var tween = create_tween()
		tween.set_parallel(true)

		tween.tween_method(_set_pulse_radius, base_radius, pulse_max_radius, pulse_duration)
		tween.tween_method(_set_pulse_alpha, 1.0, 0.0, pulse_duration)

		await tween.finished
		await get_tree().create_timer(pulse_gap).timeout

func _set_pulse_radius(v: float):
	pulse_radius = v
	queue_redraw()

func _set_pulse_alpha(v: float):
	pulse_alpha = v
	queue_redraw()
