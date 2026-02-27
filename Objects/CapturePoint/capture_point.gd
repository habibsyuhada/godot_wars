class_name CapturePoint
extends Area2D

signal owner_changed(point: CapturePoint, old_team: int, new_team: int)

@export var capture_time := 3.0
@export var PointConnectList: Array[CapturePoint] = []
@export var owner_team: int = 0
@export var target_point: CapturePoint = null

@onready var timer: Timer = $Timer

# team_id -> jumlah unit di area
var _team_counts: Dictionary = {}
var _capturing_team: int = 0

func _ready() -> void:
	add_to_group("capture_point")

	# pastikan timer one_shot dan connect sekali
	timer.one_shot = true
	timer.timeout.connect(_on_capture_timeout)

	# connect sinyal area
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func set_owner_team(new_team: int) -> void:
	if owner_team == new_team:
		return
	var old_team := owner_team
	owner_team = new_team
	
	for body in get_overlapping_bodies():
		if body == null:
			continue
		# kalau unit langsung punya source_point
		if body.is_in_group("unit"):
			if body.team == new_team:
				body.source_point = self
	
	owner_changed.emit(self, old_team, new_team)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("unit"):
		return
	var team : int = _get_team_id(body)
	if team == null:
		return

	_team_counts[team] = int(_team_counts.get(team, 0)) + 1
	_evaluate_capture_state()
	
	if team == owner_team:
		body.source_point = self

func _on_body_exited(body: Node) -> void:
	var team : int = _get_team_id(body)
	if team == null:
		return

	var new_count := int(_team_counts.get(team, 0)) - 1
	if new_count <= 0:
		_team_counts.erase(team)
	else:
		_team_counts[team] = new_count

	_evaluate_capture_state()

func _evaluate_capture_state() -> void:
	# ambil team yang punya unit > 0
	var present_teams: Array[int] = []
	for k in _team_counts.keys():
		if int(_team_counts[k]) > 0:
			present_teams.append(int(k))

	# kalau kosong -> stop capture
	if present_teams.is_empty():
		_stop_capture()
		return

	# kalau ada 2+ team -> contested -> stop/reset capture
	if present_teams.size() >= 2:
		_stop_capture()
		return

	# hanya 1 team di area
	var sole_team := present_teams[0]

	# kalau team itu sudah owner -> tidak perlu capture
	if sole_team == owner_team:
		_stop_capture()
		return

	# mulai capture untuk team ini
	_start_capture(sole_team)

func _start_capture(team: int) -> void:
	# kalau sudah capturing team yang sama dan timer masih jalan, biarkan
	if _capturing_team == team and not timer.is_stopped():
		return

	_capturing_team = team
	timer.stop()
	timer.wait_time = capture_time
	timer.start()

func _stop_capture() -> void:
	_capturing_team = 0
	timer.stop()

func _on_capture_timeout() -> void:
	# sebelum ganti owner, cek lagi: masih valid (hanya 1 team dan dia masih ada)
	if _capturing_team == 0:
		return
	if int(_team_counts.get(_capturing_team, 0)) <= 0:
		_stop_capture()
		return

	# pastikan tidak ada team lain tiba-tiba muncul
	var teams_present := 0
	for k in _team_counts.keys():
		if int(_team_counts[k]) > 0:
			teams_present += 1
	if teams_present != 1:
		_stop_capture()
		return

	set_owner_team(_capturing_team)
	_stop_capture()

func _get_team_id(body: Node) -> Variant:
	# sesuaikan dengan script unit kamu:
	# - kalau unit pakai `team_id`, aman
	# - kalau pakai `team`, tinggal ganti
	if body == null:
		return null
	if body.is_in_group("unit"):
		return int(body.team)

	return null

func is_capturing() -> bool:
	# capture progress sedang berjalan
	return _capturing_team != 0 and not timer.is_stopped()

func is_contested() -> bool:
	# ada lebih dari 1 team di area (contoh: 2 team berbeda)
	var teams_present := 0
	for k in _team_counts.keys():
		if int(_team_counts[k]) > 0:
			teams_present += 1
	return teams_present >= 2

func can_respawn_here(team: int) -> bool:
	# respawn hanya kalau owner = team dan tidak sedang capture/contested
	if owner_team != team:
		return false
	if is_capturing():
		return false
	if is_contested():
		return false
	return true
