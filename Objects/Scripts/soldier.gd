class_name Enemy
extends CharacterBody2D

@export var team := 1
@export var race := "Goblin"
@export var level := 1
@export var state: String

@export var hp: int = 50
@export var attack_damage: int = 10

@export var strength: int = 10
@export var agility: int = 8
@export var luck: int = 5

@export var hit_chance: float = 0.8
@export var crit_chance: float = 0.15
@export var crit_multiplier: float = 1.7
@export var damage_variance: float = 0.1

@export var wander_speed := 50.0
@export var chase_speed := 75.0

var target: Enemy
var target_list := {}
var target_in_attack_range := false
var can_attack := true
var target_point: CapturePoint = null
var source_point: CapturePoint = null


func _ready():
	randomize()
	add_to_group("unit")
	apply_race_stats()


func apply_race_stats():
	var race_stats: Dictionary = GlobalData.get_race_stats(race)

	if race_stats.is_empty():
		push_warning("Race '%s' tidak ditemukan di GlobalData.race_list" % race)
		return

	level = randi_range(1, 5)

	hp = max(1, race_stats.get("hp", 50) + randi_range(-2, 2) + (level * 5))
	attack_damage = max(1, race_stats.get("attack_damage", 10) + randi_range(-2, 2) + level)
	strength = max(1, race_stats.get("strength", 10) + randi_range(-2, 2) + level)
	agility = max(1, race_stats.get("agility", 8) + randi_range(-2, 2) + level)
	luck = max(1, race_stats.get("luck", 5) + randi_range(-2, 2))

	wander_speed = max(1.0, race_stats.get("wander_speed", 50.0) + randf_range(-2.0, 2.0) + (level * 0.5))
	chase_speed = max(wander_speed, race_stats.get("chase_speed", 75.0) + randf_range(-2.0, 2.0) + (level * 0.75))

	hit_chance = clamp(0.7 + (agility * 0.01), 0.7, 0.95)
	crit_chance = clamp(0.05 + (luck * 0.01), 0.05, 0.35)


func perform_attack(victim: Enemy) -> void:
	if victim == null or not is_instance_valid(victim):
		return

	if randf() > hit_chance:
		return

	var dmg := attack_damage + strength

	var is_crit := randf() < crit_chance
	if is_crit:
		dmg = int(dmg * crit_multiplier)

	var min_mul := 1.0 - damage_variance
	var max_mul := 1.0 + damage_variance
	dmg = max(1, int(round(dmg * randf_range(min_mul, max_mul))))

	victim.take_damage(dmg, is_crit)


func take_damage(dmg: int, crit: bool = false) -> void:
	hp -= dmg

	if hp <= 0:
		die()


func die():
	queue_free()
