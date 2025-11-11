extends EnemyState


# Upon moving to this state, initialize the 
# timer with a random duration.
func enter():
	pass


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
