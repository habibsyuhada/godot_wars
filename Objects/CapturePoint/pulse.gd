extends Node2D
class_name CapturePointVisual

@export var fill_alpha: float = 0.18
@export var border_alpha: float = 0.9
@export var border_width: float = 3.0
@export var progress_width: float = 6.0
@export var circle_segments: int = 72

# radius diambil dari CollisionShape2D (CircleShape2D)
@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"

var radius: float = 48.0

# state visual
var owner_team: int = 0
var capturing_team: int = 0
var progress: float = 0.0       # 0..1
var contested: bool = false

# warna tim (customize sesuai tim kamu)
func _team_color(team: int) -> Color:
	match team:
		1: return Color(0.2, 0.6, 1.0, 1.0)  # biru
		2: return Color(1.0, 0.3, 0.3, 1.0)  # merah
		3: return Color(0.3, 1.0, 0.5, 1.0)  # hijau
		_: return Color(0.485, 0.485, 0.485, 1.0)          # netral

func _ready() -> void:
	var circle := collision_shape.shape as CircleShape2D
	if circle != null:
		radius = circle.radius
	queue_redraw()

func set_owner_team(team: int) -> void:
	owner_team = team
	queue_redraw()

func set_capture_state(new_capturing_team: int, new_progress: float, is_contested: bool) -> void:
	capturing_team = new_capturing_team
	progress = clamp(new_progress, 0.0, 1.0)
	contested = is_contested
	queue_redraw()

func _draw() -> void:
	# base colors
	var base_col: Color = _team_color(owner_team)
	var border_col: Color = base_col
	var fill_col: Color = Color(base_col.r, base_col.g, base_col.b, fill_alpha)
	border_col.a = border_alpha

	# kalau contested, tampilin abu-abu biar jelas
	#if contested:
		#fill_col = Color(0.6, 0.6, 0.6, 0.14)
		#border_col = Color(0.85, 0.85, 0.85, 0.95)

	# ====== base static area ======
	draw_circle(Vector2.ZERO, radius, fill_col)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, circle_segments, border_col, border_width)

	# ====== capturing progress like a clock ======
	# progress arc dari jam 12, searah jarum jam
	if capturing_team != 0 and progress > 0.0 and not contested:
		var cap_col: Color = _team_color(capturing_team)
		cap_col.a = 0.95

		# start dari -90° (jam 12)
		var start_angle: float = -PI * 0.5
		var end_angle: float = start_angle + (TAU * progress)

		# arc tebal di pinggir
		draw_arc(Vector2.ZERO, radius, start_angle, end_angle, circle_segments, cap_col, progress_width)

		# optional: garis “jarum” ke ujung progress biar kayak jam beneran
		var tip: Vector2 = Vector2(cos(end_angle), sin(end_angle)) * radius
		draw_line(Vector2.ZERO, tip, cap_col, 2.0)
