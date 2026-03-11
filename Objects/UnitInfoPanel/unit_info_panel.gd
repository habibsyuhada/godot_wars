extends CanvasLayer

@onready var race_label = $Control/NinePatchRect/MarginContainer/VBoxContainer/RaceLabel
@onready var level_label = $Control/NinePatchRect/MarginContainer/VBoxContainer/LevelLabel
@onready var hp_label = $Control/NinePatchRect/MarginContainer/VBoxContainer/HPLabel
@onready var attack_label = $Control/NinePatchRect/MarginContainer/VBoxContainer/AttackLabel

@onready var close_btn = $CloseButton

var current_unit = null

func _ready() -> void:
	visible = false
	close_btn.pressed.connect(_on_close_pressed)

func _process(_delta: float) -> void:
	if current_unit == null:
		return

	if not is_instance_valid(current_unit):
		hide_panel()
		return

	update_unit_info()

func show_unit_info(unit) -> void:
	current_unit = unit
	update_unit_info()
	visible = true

func update_unit_info() -> void:
	if current_unit == null:
		return

	race_label.text = "Race: " + str(current_unit.race)
	level_label.text = "Level: " + str(current_unit.level)
	hp_label.text = "HP: " + str(current_unit.hp)
	attack_label.text = "ATK: " + str(current_unit.attack_damage)

func hide_panel() -> void:
	current_unit = null
	visible = false
	
func _on_close_pressed():
	hide_panel()
