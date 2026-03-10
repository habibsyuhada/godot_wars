extends Node

var race_list = {
	"Goblin": {
		"hp": 45,
		"attack_damage": 8,
		"strength": 10,
		"agility": 12,
		"luck": 6,
		"wander_speed": 55.0,
		"chase_speed": 80.0
	},
	"Skeleton": {
		"hp": 55,
		"attack_damage": 9,
		"strength": 11,
		"agility": 7,
		"luck": 4,
		"wander_speed": 45.0,
		"chase_speed": 65.0
	},
	"Human": {
		"hp": 60,
		"attack_damage": 10,
		"strength": 9,
		"agility": 9,
		"luck": 8,
		"wander_speed": 50.0,
		"chase_speed": 75.0
	}
}

func get_race_stats(race_name: String) -> Dictionary:
	return race_list.get(race_name, {})
