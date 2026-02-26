extends Node

@export var unit_scene: Enemy
@export var respawn_interval := 5.0
@export var team_id := 1

# team_id -> Array[CapturePoint]
var owned_points := {
	1: [],
	2: []
}

@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = respawn_interval
	timer.timeout.connect(_on_respawn_timeout)
	timer.start()

	# connect semua capture point sekali di awal
	for point in get_tree().get_nodes_in_group("capture_point"):
		if !point.owner_changed.is_connected(_on_point_owner_changed):
			point.owner_changed.connect(_on_point_owner_changed)

		# sync state awal
		if point.owner_team in owned_points:
			if point.owner_team != 0:
				owned_points[point.owner_team].append(point)

func _on_point_owner_changed(point, old_team: int, new_team: int):
	if old_team in owned_points:
		owned_points[old_team].erase(point)

	if new_team in owned_points and new_team != 0:
		if point not in owned_points[new_team]:
			owned_points[new_team].append(point)

func _on_respawn_timeout():
	var points: Array = owned_points.get(team_id, [])
	if points.is_empty():
		return

	var spawn_point = points.pick_random()
	if spawn_point == null:
		return

	var unit = unit_scene.instantiate()
	get_tree().current_scene.add_child(unit)

	unit.global_position = spawn_point.global_position
