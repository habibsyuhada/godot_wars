extends EnemyState


var idle_timer : Timer
var find_point_timer : Timer


# Upon moving to this state, initialize the 
# timer with a random duration.
func enter():
	enemy.state = "IDLE"
	enemy.velocity = Vector2.ZERO
	#print(enemy.race.to_lower() + "_idle")
	animation_player.play(enemy.race.to_lower() + "_idle")
	
	idle_timer = Timer.new()
	idle_timer.wait_time = randi_range(0, 3)
	idle_timer.timeout.connect(on_timeout)
	idle_timer.autostart = true
	add_child(idle_timer)
	
	if enemy.source_point == enemy.target_point:
		enemy.target_point = null
		find_point_timer = Timer.new()
		find_point_timer.wait_time = randi_range(5, 10)
		find_point_timer.timeout.connect(find_point_timer_on_timeout)
		find_point_timer.autostart = true
		add_child(find_point_timer)


func on_timeout():
	transitioned.emit(self, "wandering")
	
func find_point_timer_on_timeout():
	var candidates: Array = enemy.source_point.PointConnectList.filter(
		func(p): return p != null and p.owner_team != enemy.team
	)
	enemy.target_point = candidates.pick_random() if not candidates.is_empty() else enemy.source_point.PointConnectList.pick_random()

func _physics_process(delta: float) -> void:
	try_chase()
	pass


# When leaving this state (for any reason), stop timer,
# disconnect signals, and free timer
# Technically, just queue_free() would be required, but
# I like showcasing all of the options
func exit():
	idle_timer.stop()
	idle_timer.timeout.disconnect(on_timeout)
	idle_timer.queue_free()
	idle_timer = null
