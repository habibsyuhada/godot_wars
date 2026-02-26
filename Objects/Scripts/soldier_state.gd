class_name EnemyState
extends Node


#####################################
# This is the base enemy state
# Each state will inherit from this
#####################################

signal transitioned(state: EnemyState, new_state_name: String)

@onready var enemy : Enemy = get_owner()
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
#var player : Player


func _ready():
	pass
	#player = get_tree().get_first_node_in_group("player")
	#enemy.damaged.connect(on_damaged)


# This is called directly when transitioning to this state
# Useful for setting up the state to be used
# In Idle, we use this function to decide how long we will idle for
func enter():
	pass


# When the state is active, this is essentially the _process() function
func process_state(delta: float):
	pass


# When the state is active, this is essentially the _physics_process() function
func physics_process_state(delta: float):
	pass


# Useful for cleaning up the state
# For example, clearing any timers, disconnecting any signals, etc.
func exit():
	pass


###############################################
# Non FSM-specific methods. These are utility 
# methods that may be used by multiple states. 
###############################################

# Attempts to switch to chase state if it detects the player
#func try_chase() -> bool:
	#if get_distance_to_player() <= enemy.detection_radius:
		#transitioned.emit(self, "chase")
		#return true
	#
	#return false

func try_chase()  -> bool:
	if enemy.target != null :
		transitioned.emit(self, "chasing")
		return true
	return false

#func deal_damage():
	#if enemy.target != null and is_instance_valid(enemy.target) and enemy.target_in_attack_range:
		#enemy.target.take_damage(enemy.attack_damage)

func deal_damage():
	if enemy.target == null or not is_instance_valid(enemy.target):
		return
	if not enemy.target_in_attack_range:
		return
	
	enemy.perform_attack(enemy.target)

func _find_nearest_target():
	var nearest: Enemy = null
	var nearest_dist_sq := INF
	var my_pos = enemy.global_position
	var invalid := []

	for body in enemy.target_list.keys():
		if !is_instance_valid(body):
			invalid.append(body)
			continue

		var dist_sq = my_pos.distance_squared_to(body.global_position)
		if dist_sq < nearest_dist_sq:
			nearest_dist_sq = dist_sq
			nearest = body

	for body in invalid:
		enemy.target_list.erase(body)

	return nearest




# If you wanted to replace this functionality in a state you can either:
# 1. Disconnect the signal by doing enemy.damaged.disconnect(on_damaged)
# 2. Override the on_damaged() function to do nothing
# 3. Override the _ready() function
# This is the order I would recommend personally
#func on_damaged(attack: Attack):
	#transitioned.emit(self, "stun")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not (body is Enemy):
		return
	if body == enemy:
		return
	if body.team == enemy.team:
		return
	if enemy.target == null:
		enemy.target = body
	enemy.target_list[body] = true
	
	var my_pos = enemy.global_position
	var new_dist = my_pos.distance_squared_to(body.global_position)
	var cur_dist = my_pos.distance_squared_to(enemy.target.global_position)
	if new_dist < cur_dist:
		enemy.target = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	enemy.target_list.erase(body)

	if enemy.target == body:
		enemy.target = _find_nearest_target()
		enemy.target_in_attack_range = false

func _on_attack_range_body_entered(body: Node2D) -> void:
	if enemy.target == body:
		enemy.target_in_attack_range = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	if enemy.target == body:
		enemy.target_in_attack_range = false
