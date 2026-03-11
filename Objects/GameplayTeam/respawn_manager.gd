extends Node

@onready var gameplayteam := get_owner()
@onready var timer: Timer = $Timer
@onready var enemies_node = get_tree().current_scene.get_node_or_null("Enemies")

var unit_scene: PackedScene
var respawn_interval: float
var team_id: int
var race: String
var units_per_point: int
var base_max_units: int

var owned_points: Array = []

func _ready():
	unit_scene = gameplayteam.unit_scene
	respawn_interval = gameplayteam.respawn_interval
	team_id = gameplayteam.team_id
	race = gameplayteam.race
	units_per_point = gameplayteam.units_per_point
	base_max_units = gameplayteam.base_max_units

	timer.wait_time = respawn_interval
	timer.timeout.connect(_on_respawn_timeout)
	timer.start()

	for point in get_tree().get_nodes_in_group("capture_point"):
		if not point.owner_changed.is_connected(_on_point_owner_changed):
			point.owner_changed.connect(_on_point_owner_changed)

		if point.owner_team == team_id and point.owner_team != 0:
			owned_points.append(point)

func _on_point_owner_changed(point, old_team: int, new_team: int):
	if old_team == team_id:
		owned_points.erase(point)

	if new_team == team_id and new_team != 0:
		if point not in owned_points:
			owned_points.append(point)

func calc_target_point_list(point):
	var candidates: Array = point.PointConnectList.filter(
		func(p): return p != null and p.owner_team != team_id
	)

	point.TargetPointList = candidates

func get_current_unit_count() -> int:
	var count := 0
	for unit in get_tree().get_nodes_in_group("unit"):
		if unit.get_parent() == enemies_node and unit.team == team_id:
			count += 1
	return count

func get_max_unit_count() -> int:
	return base_max_units + (owned_points.size() * units_per_point)

func _on_respawn_timeout():
	if owned_points.is_empty():
		return

	var current_units := get_current_unit_count()
	var max_units := get_max_unit_count()

	if current_units >= max_units:
		return

	var candidates: Array = owned_points.filter(
		func(p):
			return p != null and p.can_respawn_here(team_id)
	)

	if candidates.is_empty():
		return

	var spawn_point: CapturePoint = candidates.pick_random()
	if spawn_point == null:
		return

	if unit_scene == null:
		push_error("unit_scene belum di-set (PackedScene kosong).")
		return

	if enemies_node == null:
		push_error("Node 'Enemies' tidak ditemukan.")
		return

	var unit := unit_scene.instantiate()
	unit.team = team_id
	unit.race = race
	unit.source_point = spawn_point
	unit.target_point = spawn_point

	enemies_node.add_child(unit)
	unit.global_position = spawn_point.global_position
