extends Control

func _ready():
	$StartButton.pressed.connect(_on_start_pressed)
	$QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	GameState.reset_game()
	get_tree().change_scene_to_file("res://scenes/TeamSelectMenu.tscn")

func _on_quit_pressed():
	get_tree().quit()
