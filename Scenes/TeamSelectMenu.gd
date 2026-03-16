extends Control

func _ready():
	$VBoxContainer/HBoxContainer/Team1Button.pressed.connect(_on_team_1_pressed)
	$VBoxContainer/HBoxContainer/Team2Button.pressed.connect(_on_team_2_pressed)
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_team_1_pressed():
	_start_game_with_prediction(1)

func _on_team_2_pressed():
	_start_game_with_prediction(2)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _start_game_with_prediction(team_id: int):
	GameState.predicted_winner_team = team_id
	GameState.game_started = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")
