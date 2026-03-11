extends Control

func _ready():
	var winner = GameState.winner_team
	var predicted = GameState.predicted_winner_team

	$WinnerLabel.text = "Winner Team: " + str(winner)

	if winner == predicted:
		$PredictionLabel.text = "Your prediction was correct!"
	else:
		$PredictionLabel.text = "Your prediction was wrong."

	$RestartButton.pressed.connect(_on_restart_pressed)
	$MainMenuButton.pressed.connect(_on_main_menu_pressed)

func _on_restart_pressed():
	GameState.game_finished = false
	GameState.winner_team = 0
	get_tree().change_scene_to_file("res://scenes/BattleScene.tscn")

func _on_main_menu_pressed():
	GameState.reset_game()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
