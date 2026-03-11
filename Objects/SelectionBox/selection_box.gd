extends Node2D

@export var padding := 8.0

@onready var tl: Sprite2D = $TL
@onready var tr: Sprite2D = $TR
@onready var bl: Sprite2D = $BL
@onready var br: Sprite2D = $BR

var target_unit: Node2D = null
var target_size: Vector2 = Vector2(16,16)

func _ready():
	visible = false

func _process(_delta):
	if target_unit == null:
		return

	if not is_instance_valid(target_unit):
		clear_target()
		return

	global_position = target_unit.global_position

func set_target(unit: Node2D, size: Vector2):
	target_unit = unit
	#target_size = size
	#print("size", size)
	update_layout()
	visible = true

func clear_target():
	print("clear")
	target_unit = null
	visible = false

func update_layout():
	var half = target_size * 0.5
	print()

	tl.position = Vector2(-half.x-padding,-half.y-padding)
	tr.position = Vector2( half.x+padding,-half.y-padding)
	bl.position = Vector2(-half.x-padding, half.y+padding)
	br.position = Vector2( half.x+padding, half.y+padding)
