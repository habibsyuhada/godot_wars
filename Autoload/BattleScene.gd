extends Node

func _ready():
	if GameState.predicted_winner_team == 0:
		get_tree().change_scene_to_file("res://scenes/TeamSelectMenu.tscn")
		return
