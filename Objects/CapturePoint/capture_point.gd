extends Area2D

signal owner_changed(point, old_team, new_team)

@export var capture_time := 3.0

var owner_team: int = 0

@onready var timer: Timer = $Timer

func set_owner_team(new_team: int):
	if owner_team == new_team:
		return

	var old_team = owner_team
	owner_team = new_team
	owner_changed.emit(self, old_team, new_team)

func _ready():
	add_to_group("capture_point")
