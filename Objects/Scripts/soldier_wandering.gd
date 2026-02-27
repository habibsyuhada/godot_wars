extends EnemyState

@export var min_wander_time := 2.5
@export var max_wander_time := 10.0
@export var wander_speed := 50.0

@export var wander_radius := 200.0      # jarak roam dari source_point
@export var arrive_distance := 12.0     # dianggap "sampai" kalau jarak <= ini
@export var repick_on_arrive := true    # kalau true: sampai target -> pilih target baru (tanpa nunggu timer)

var wander_target: Vector2
var wander_timer: Timer

func enter():
	enemy.state = "WANDERING"

	_pick_new_target()

	wander_timer = Timer.new()
	wander_timer.wait_time = randf_range(min_wander_time, max_wander_time)
	wander_timer.one_shot = true
	wander_timer.timeout.connect(_on_timer_finished)
	add_child(wander_timer)
	wander_timer.start()

func physics_process_state(delta: float):
	# kalau source_point belum ada, fallback ke idle biar aman
	if enemy.source_point == null:
		transitioned.emit(self, "idle")
		return

	var to_target: Vector2 = wander_target - enemy.global_position
	var dist := to_target.length()

	# kalau sudah dekat target
	if dist <= arrive_distance:
		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()

		if repick_on_arrive:
			_pick_new_target()
			# timer tetap jalan; kalau kamu mau reset timer tiap arrive, uncomment:
			# _restart_timer()
		else:
			animation_player.play(enemy.race.to_lower() + "_idle")
	else:
		var dir := to_target / dist # normalized tanpa panggil normalized() dua kali
		enemy.velocity = dir * wander_speed
		enemy.move_and_slide()
		animation_player.play(enemy.race.to_lower() + "_walk")

	try_chase()

func _pick_new_target() -> void:
	# pusat roam = posisi source_point
	var center: Vector2 = enemy.source_point.global_position
	if enemy.target_point != null :
		center = enemy.target_point.global_position
	

	# random titik dalam lingkaran radius wander_radius
	# (pakai sqrt agar distribusi merata di area, bukan numpuk di tengah)
	var angle := randf_range(0.0, TAU)
	var r := sqrt(randf()) * wander_radius
	var offset := Vector2(cos(angle), sin(angle)) * r

	wander_target = center + offset

func _restart_timer() -> void:
	if wander_timer == null:
		return
	wander_timer.stop()
	wander_timer.wait_time = randf_range(min_wander_time, max_wander_time)
	wander_timer.start()

func _on_timer_finished() -> void:
	# opsi A: habis timer -> balik idle (sesuai script awal)
	transitioned.emit(self, "idle")

	# opsi B (kalau kamu mau terus roam tanpa idle):
	# _pick_new_target()
	# _restart_timer()

func exit():
	if wander_timer != null:
		wander_timer.stop()
		if wander_timer.timeout.is_connected(_on_timer_finished):
			wander_timer.timeout.disconnect(_on_timer_finished)
		wander_timer.queue_free()
		wander_timer = null
