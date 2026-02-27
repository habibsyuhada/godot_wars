class_name Enemy
extends CharacterBody2D

@export var team := 1
@export var race := "Goblin"
@export var level := 1
@export var state: String

@export var hp: int = 50
@export var attack_damage: int = 10

# RPG stats sederhana
@export var strength: int = 10
@export var agility: int = 8
@export var luck: int = 5

# Combat tuning
@export var hit_chance: float = 0.8      # 80% kena
@export var crit_chance: float = 0.15    # 15% crit
@export var crit_multiplier: float = 1.7
@export var damage_variance: float = 0.1 # ±10%

# Runtime
var target: Enemy
var target_list := {}
var target_in_attack_range := false
var can_attack := true
var target_point : CapturePoint = null
var source_point : CapturePoint = null


func _ready():
	randomize()
	add_to_group("unit")


# ========== COMBAT ==========
func perform_attack(victim: Enemy) -> void:
	if victim == null or not is_instance_valid(victim):
		return

	# MISS
	if randf() > hit_chance:
		#print(name, "MISS ->", victim.name)
		return

	# BASE DAMAGE
	var dmg := attack_damage + strength

	# CRIT
	var is_crit := randf() < crit_chance
	if is_crit:
		dmg = int(dmg * crit_multiplier)

	# RANDOM VARIANCE
	var min_mul := 1.0 - damage_variance
	var max_mul := 1.0 + damage_variance
	dmg = max(1, int(round(dmg * randf_range(min_mul, max_mul))))

	victim.take_damage(dmg, is_crit)


func take_damage(dmg: int, crit: bool = false) -> void:
	hp -= dmg
	#print(
		#name,
		#"took",
		#dmg,
		#"damage",
		#"(CRIT)" if crit else ""
	#)

	if hp <= 0:
		die()


func die():
	queue_free()
