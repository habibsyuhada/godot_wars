class_name Enemy
extends CharacterBody2D

@export var team := 1
@export var race := "Goblin"

@onready var target : Enemy 
@onready var target_in_attack_range := false
@export var attack_cooldown: float = 2
@export var hp: int = 50
@export var attack_damage: int = 10

var can_attack: bool = true

func take_damage(dmg: int) -> void:
	hp -= dmg
	if hp <= 0:
		queue_free()
