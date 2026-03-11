extends Node

var predicted_winner_team: int = 0
var game_started: bool = false
var game_finished: bool = false
var winner_team: int = 0

func reset_game():
	predicted_winner_team = 0
	game_started = false
	game_finished = false
	winner_team = 0
