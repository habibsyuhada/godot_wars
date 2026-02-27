extends Node2D

@export var layers_root_path: NodePath   # parent node yang berisi TileMapLayer
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.5
@export var zoom_step: float = 0.1
@export var zoom_speed: float = 0.015
@export var drag_sensitivity: float = 1.0

@onready var cam: Camera2D = $Camera2D
@onready var layers_root: Node = get_node(layers_root_path)

# ===== Touch tracking =====
var _dragging: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO

var _touches: Dictionary = {} # int -> Vector2
var _pinching: bool = false
var _pinch_start_dist: float = 0.0
var _pinch_start_zoom: Vector2 = Vector2.ONE
var _pinch_center: Vector2 = Vector2.ZERO

# ===== Map bounds (global coords) =====
var _map_min: Vector2 = Vector2.ZERO
var _map_max: Vector2 = Vector2.ZERO
var _has_bounds: bool = false

func _ready() -> void:
	cam.zoom = _clamp_zoom(cam.zoom)
	_recompute_layers_bounds()
	_clamp_to_bounds()

func _process(_delta: float) -> void:
	_clamp_to_bounds()

func _unhandled_input(event: InputEvent) -> void:
	# ===== Mouse =====
	if event is InputEventMouseButton:
		var e: InputEventMouseButton = event

		if e.button_index == MOUSE_BUTTON_WHEEL_UP and e.pressed:
			_zoom_at_screen_pos(-zoom_step, e.position)
			return
		if e.button_index == MOUSE_BUTTON_WHEEL_DOWN and e.pressed:
			_zoom_at_screen_pos(+zoom_step, e.position)
			return

		if (e.button_index == MOUSE_BUTTON_MIDDLE or e.button_index == MOUSE_BUTTON_RIGHT):
			_dragging = e.pressed
			_last_mouse_pos = e.position
			return

	if event is InputEventMouseMotion and _dragging and not _pinching:
		var m: InputEventMouseMotion = event
		_pan_by_screen_delta(m.position - _last_mouse_pos)
		_last_mouse_pos = m.position
		return

	# ===== Touch =====
	if event is InputEventScreenTouch:
		var t: InputEventScreenTouch = event
		if t.pressed:
			_touches[t.index] = t.position
		else:
			_touches.erase(t.index)
		_update_pinch_state()
		return

	if event is InputEventScreenDrag:
		var d: InputEventScreenDrag = event
		_touches[d.index] = d.position

		if _touches.size() == 1 and not _pinching:
			_pan_by_screen_delta(d.relative)
			return
		if _touches.size() >= 2:
			_handle_pinch()
			return

# =====================
# Pan & Zoom
# =====================

func _pan_by_screen_delta(delta: Vector2) -> void:
	var world_delta: Vector2 = delta * drag_sensitivity * (1.0 / cam.zoom.x)
	global_position -= world_delta

func _zoom_at_screen_pos(step: float, screen_pos: Vector2) -> void:
	var target: Vector2 = cam.zoom + Vector2(step, step)
	target = _clamp_zoom(target)
	_set_zoom_at_screen_pos(target, screen_pos)

func _set_zoom_at_screen_pos(target_zoom: Vector2, screen_pos: Vector2) -> void:
	var before: Vector2 = _screen_to_world(screen_pos)
	cam.zoom = target_zoom
	var after: Vector2 = _screen_to_world(screen_pos)
	global_position += (before - after)

func _screen_to_world(screen_pos: Vector2) -> Vector2:
	# Konversi koordinat layar (viewport) -> koordinat world (global)
	# get_canvas_transform(): world->screen, jadi kita invert untuk screen->world
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	
func _clamp_zoom(z: Vector2) -> Vector2:
	var v: float = clamp(z.x, min_zoom, max_zoom)
	return Vector2(v, v)

# =====================
# Touch pinch
# =====================

func _update_pinch_state() -> void:
	if _touches.size() >= 2:
		_pinching = true
		var keys: Array = _touches.keys()
		var idx0: int = int(keys[0])
		var idx1: int = int(keys[1])

		var a: Vector2 = _touches[idx0] as Vector2
		var b: Vector2 = _touches[idx1] as Vector2

		_pinch_start_dist = a.distance_to(b)
		_pinch_start_zoom = cam.zoom
		_pinch_center = (a + b) * 0.5
	else:
		_pinching = false

func _handle_pinch() -> void:
	if _touches.size() < 2:
		return

	var keys: Array = _touches.keys()
	var idx0: int = int(keys[0])
	var idx1: int = int(keys[1])

	var a: Vector2 = _touches[idx0] as Vector2
	var b: Vector2 = _touches[idx1] as Vector2
	var dist: float = a.distance_to(b)

	if _pinch_start_dist <= 0.0:
		_pinch_start_dist = dist

	var ratio: float = dist / _pinch_start_dist
	var target_zoom: Vector2 = _pinch_start_zoom * ratio
	target_zoom = _pinch_start_zoom.lerp(target_zoom, zoom_speed * 60.0)
	target_zoom = _clamp_zoom(target_zoom)

	_set_zoom_at_screen_pos(target_zoom, _pinch_center)

# =====================
# Bounds from TileMapLayer(s)
# =====================

func _recompute_layers_bounds() -> void:
	_has_bounds = false
	if layers_root == null:
		push_warning("CameraRig: layers_root_path belum di-set.")
		return

	var layers: Array[TileMapLayer] = []
	_collect_tilemap_layers(layers_root, layers)

	if layers.is_empty():
		push_warning("CameraRig: tidak menemukan TileMapLayer di bawah layers_root.")
		return

	var found_any: bool = false
	var gmin: Vector2 = Vector2.ZERO
	var gmax: Vector2 = Vector2.ZERO

	for layer in layers:
		var used: Rect2i = layer.get_used_rect()
		if used.size == Vector2i.ZERO:
			continue

		var tile_size: Vector2 = Vector2(64, 64)
		if layer.tile_set != null:
			tile_size = layer.tile_set.tile_size

		var local_min: Vector2 = layer.map_to_local(used.position)
		var local_max: Vector2 = layer.map_to_local(used.position + used.size) + tile_size

		var layer_gmin: Vector2 = layer.to_global(local_min)
		var layer_gmax: Vector2 = layer.to_global(local_max)

		if not found_any:
			found_any = true
			gmin = layer_gmin
			gmax = layer_gmax
		else:
			gmin.x = min(gmin.x, layer_gmin.x)
			gmin.y = min(gmin.y, layer_gmin.y)
			gmax.x = max(gmax.x, layer_gmax.x)-32
			gmax.y = max(gmax.y, layer_gmax.y)-32

	if not found_any:
		push_warning("CameraRig: semua TileMapLayer get_used_rect() kosong.")
		return

	_map_min = gmin
	_map_max = gmax
	_has_bounds = true

func _collect_tilemap_layers(root: Node, out_layers: Array[TileMapLayer]) -> void:
	for c in root.get_children():
		if c is TileMapLayer:
			out_layers.append(c as TileMapLayer)
		_collect_tilemap_layers(c, out_layers)
		
func _clamp_to_bounds() -> void:
	if not _has_bounds:
		return

	var vp_size: Vector2 = get_viewport_rect().size
	var half_view: Vector2 = (vp_size * 0.5) / cam.zoom.x

	var min_x: float = _map_min.x + half_view.x
	var max_x: float = _map_max.x - half_view.x
	var min_y: float = _map_min.y + half_view.y
	var max_y: float = _map_max.y - half_view.y

	var p: Vector2 = global_position

	# kalau map lebih kecil dari viewport, center
	if min_x > max_x:
		p.x = (_map_min.x + _map_max.x) * 0.5
	else:
		p.x = clamp(p.x, min_x, max_x)

	if min_y > max_y:
		p.y = (_map_min.y + _map_max.y) * 0.5
	else:
		p.y = clamp(p.y, min_y, max_y)

	global_position = p
