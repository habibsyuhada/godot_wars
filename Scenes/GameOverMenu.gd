extends Control

func _ready():
	var winner = GameState.winner_team
	var predicted = GameState.predicted_winner_team

	$VBoxContainer/WinnerLabel.text = "Winner Team: " + str(winner)

	if winner == predicted:
		$VBoxContainer/PredictionLabel.text = "Your prediction was correct!"
	else:
		$VBoxContainer/PredictionLabel.text = "Your prediction was wrong."

	$VBoxContainer/HBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$VBoxContainer/HBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)

func _on_restart_pressed():
	GameState.game_finished = false
	GameState.winner_team = 0
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_main_menu_pressed():
	GameState.reset_game()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
