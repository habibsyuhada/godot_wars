extends EnemyState

@export var chase_speed := 75.0


# Upon moving to this state, initialize the 
# timer with a random duration.
func enter():
	print("enter to chasing")
	print(enemy.target)
	pass


func _physics_process(delta: float) -> void:
	pass
	#var direction := enemy.target.global_position - enemy.global_position
	#
	#var distance = direction.length()
	#if distance > enemy.chase_radius:
		#transitioned.emit(self, "wander")
		#return
	#
	#enemy.velocity = direction.normalized()*chase_speed
	#
	#if distance <= enemy.follow_radius:
		#enemy.velocity = Vector2.ZERO
	#
	#enemy.move_and_slide()


# When leaving this state (for any reason), stop timer,
# disconnect signals, and free timer
# Technically, just queue_free() would be required, but
# I like showcasing all of the options
func exit():
	pass
