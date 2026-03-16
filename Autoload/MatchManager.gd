extends Node

var capture_points: Array = []

func _ready():
	if GameState.predicted_winner_team == 0:
		get_tree().change_scene_to_file("res://scenes/TeamSelectMenu.tscn")
		return
		
	capture_points = get_tree().get_nodes_in_group("capture_point")

	for point in capture_points:
		if point.owner_changed.is_connected(_on_point_owner_changed) == false:
			point.owner_changed.connect(_on_point_owner_changed)

	check_victory()

func _on_point_owner_changed(_point, _old_team: int, _new_team: int):
	check_victory()

func check_victory():
	if GameState.game_finished:
		return

	if capture_points.is_empty():
		return

	var owner_team : int = capture_points[0].owner_team

	if owner_team == 0:
		return

	for point in capture_points:
		if point.owner_team != owner_team:
			return

	GameState.game_finished = true
	GameState.winner_team = owner_team
	end_game(owner_team)

func end_game(team_id: int):
	print("Winner team: ", team_id)
	get_tree().change_scene_to_file("res://scenes/GameOverMenu.tscn")
