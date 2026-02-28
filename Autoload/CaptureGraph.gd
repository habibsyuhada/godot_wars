# CaptureGraph.gd
extends Node

var points: Array[CapturePoint] = []

# key: from_id -> { to_id: next_point }
var _next_hop: Dictionary = {}

func _ready() -> void:
	rebuild()

#Kalau koneksi bisa berubah (misal jembatan putus / link dinamis), 
#panggil CaptureGraph.rebuild() setelah perubahan.
func rebuild() -> void:
	points.clear()

	var raw_nodes := get_tree().get_nodes_in_group("capture_point")

	for n in raw_nodes:
		if n is CapturePoint:
			points.append(n)
	_next_hop.clear()

	for start in points:
		_next_hop[start.get_instance_id()] = _bfs_next_hop_from(start)

func get_next_point(from: CapturePoint, to: CapturePoint) -> CapturePoint:
	if from == null or to == null or from == to:
		return null

	var from_id := from.get_instance_id()
	var to_id := to.get_instance_id()

	if not _next_hop.has(from_id):
		rebuild()
		if not _next_hop.has(from_id):
			return null

	return _next_hop[from_id].get(to_id, null)

# RENAMED: jangan pakai get_path (bentrok dengan Node.get_path())
func build_point_path(from: CapturePoint, to: CapturePoint) -> Array[CapturePoint]:
	var path: Array[CapturePoint] = []
	var cur := from
	var guard := 0

	while cur != null and cur != to and guard < 512:
		var nxt := get_next_point(cur, to)
		if nxt == null:
			return []
		path.append(nxt)
		cur = nxt
		guard += 1

	return path

func _bfs_next_hop_from(start: CapturePoint) -> Dictionary:
	var result: Dictionary = {}           # to_id -> next_point
	var parent: Dictionary = {}           # node_id -> parent_point
	var q: Array[CapturePoint] = []
	var qi := 0

	q.append(start)
	parent[start.get_instance_id()] = null

	while qi < q.size():
		var u := q[qi]
		qi += 1

		for v in u.PointConnectList:
			if v == null:
				continue
			var vid := v.get_instance_id()
			if parent.has(vid):
				continue
			parent[vid] = u
			q.append(v)

	# next-hop dari start untuk semua node reachable
	for p in q:
		if p == start:
			continue

		var target_id := p.get_instance_id()
		var step := p

		while true:
			var par: CapturePoint = parent.get(step.get_instance_id(), null)
			if par == null:
				break
			if par == start:
				result[target_id] = step
				break
			step = par

	return result

func get_farthest_point(from: CapturePoint) -> CapturePoint:
	if from == null:
		return null
	var dist := _bfs_dist(from)

	var best: CapturePoint = null
	var best_dist := -1
	for p in dist.keys():
		var d: int = dist[p]
		if d > best_dist:
			best_dist = d
			best = p
	return best

func get_closest_enemy_point(from: CapturePoint, my_team: int) -> CapturePoint:
	if from == null:
		return null
	var dist := _bfs_dist(from)

	var best: CapturePoint = null
	var best_dist := 1_000_000
	for p in dist.keys():
		if p.owner_team != my_team:
			var d: int = dist[p]
			if d < best_dist:
				best_dist = d
				best = p
	return best

func _bfs_dist(start: CapturePoint) -> Dictionary:
	var dist: Dictionary = {} # CapturePoint -> int
	var q: Array[CapturePoint] = []
	var qi := 0

	dist[start] = 0
	q.append(start)

	while qi < q.size():
		var u := q[qi]
		qi += 1
		var du: int = dist[u]

		for v in u.PointConnectList:
			if v == null:
				continue
			if dist.has(v):
				continue
			dist[v] = du + 1
			q.append(v)

	return dist
