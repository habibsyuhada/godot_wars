extends EnemyState

@export var chase_speed := 75.0


# Upon moving to this state, initialize the 
# timer with a random duration.
func enter():
	print("ENTER CHASING")
	print(enemy.target)
	pass


func _physics_process(delta: float) -> void:
	if enemy.target == null:
		return
		
	var direction := enemy.target.global_position - enemy.global_position
	enemy.velocity = direction.normalized()*chase_speed
	
	if enemy.target_in_attack_range and enemy.can_attack:
		enemy.velocity = Vector2.ZERO
		transitioned.emit(self, "attacking")
		return
	elif animation_player.current_animation != enemy.race.to_lower() + "_attack":
		if enemy.target_in_attack_range: 
			enemy.velocity = Vector2.ZERO
			animation_player.play(enemy.race.to_lower() + "_idle")
		else:
			animation_player.play(enemy.race.to_lower() + "_walk")
	
	enemy.move_and_slide()


# When leaving this state (for any reason), stop timer,
# disconnect signals, and free timer
# Technically, just queue_free() would be required, but
# I like showcasing all of the options
func exit():
	pass
