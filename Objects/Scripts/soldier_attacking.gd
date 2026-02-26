extends EnemyState


# Upon moving to this state, initialize the 
# timer with a random duration.
func enter():
	if not enemy.can_attack:
		transitioned.emit(self, "idle")
		return
	
	#print("ENTER ATTACKING")
	enemy.state = "ATTACKING"
	enemy.can_attack = false
	enemy.velocity = Vector2.ZERO
	animation_player.play(enemy.race.to_lower() + "_attack")
	await animation_player.animation_finished
	if animation_player.current_animation != enemy.race.to_lower() + "_attack":
		deal_damage()
		transitioned.emit(self, "idle")
		
		#await get_tree().create_timer(enemy.attack_speed).timeout
		await get_tree().create_timer(0.8).timeout
		enemy.can_attack = true

func on_timeout():
	pass


func _physics_process(delta: float) -> void:
	pass


# When leaving this state (for any reason), stop timer,
# disconnect signals, and free timer
# Technically, just queue_free() would be required, but
# I like showcasing all of the options
func exit():
	pass
