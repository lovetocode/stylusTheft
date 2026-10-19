extends Node2D

signal image_ready(texture: ImageTexture)

@onready var search_request: HTTPRequest = $SearchRequest
@onready var image_request: HTTPRequest = $ImageRequest

const CACHE_DIR := "user://pixabay_cache/"
const CACHE_TARGET_SIZE := 5

var cached_paths: Array[String] = []
var is_refilling: bool = false
var _pending_emit: bool = false   # true = this download should show immediately, not just get cached

func _ready() -> void:
	search_request.request_completed.connect(_on_search_completed)
	image_request.request_completed.connect(_on_image_completed)
	DirAccess.make_dir_recursive_absolute(CACHE_DIR)
	_load_existing_cache()

# On app start, pick up any images left over from last session instead of
# starting from zero every time.
func _load_existing_cache() -> void:
	var dir := DirAccess.open(CACHE_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".jpg"):
			cached_paths.append(CACHE_DIR + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func search_and_load(query: String) -> void:
	if cached_paths.size() > 0:
		# instant path — no network wait at all
		var path: String = cached_paths.pop_front()
		_emit_texture_from_path(path)
	else:
		# cache is empty (first run, or internet's been out a while) —
		# fall back to a live fetch so the user isn't stuck on a blank screen
		_pending_emit = true
		_fetch_one(query)
	_refill_cache(query)

func _emit_texture_from_path(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var bytes := file.get_buffer(file.get_length())
	file.close()
	var image := Image.new()
	if image.load_jpg_from_buffer(bytes) == OK:
		image_ready.emit(ImageTexture.create_from_image(image))
	DirAccess.remove_absolute(path)   # used it — don't show the same one twice

func _refill_cache(query: String) -> void:
	if is_refilling or cached_paths.size() >= CACHE_TARGET_SIZE:
		return
	is_refilling = true
	_pending_emit = false
	_fetch_one(query)

func _fetch_one(query: String) -> void:
	var url := "https://pixabay.com/api/?key=%s&q=%s&image_type=photo&per_page=20" % [SessionConfig.PIXABAY_API_KEY, query.uri_encode()]
	search_request.request(url)

func _on_search_completed(result, response_code, headers, body) -> void:
	if response_code == 429 or response_code != 200:
		is_refilling = false
		return
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		is_refilling = false
		return
	var hits: Array = json.get_data().get("hits", [])
	if hits.is_empty():
		is_refilling = false
		return
	var hit = hits[randi() % hits.size()]
	image_request.request(hit["webformatURL"])

func _on_image_completed(result, response_code, headers, body) -> void:
	if _pending_emit:
		var image := Image.new()
		if image.load_jpg_from_buffer(body) == OK:
			image_ready.emit(ImageTexture.create_from_image(image))
	else:
		var path := CACHE_DIR + "img_%d.jpg" % Time.get_ticks_msec()
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_buffer(body)
			file.close()
			cached_paths.append(path)
	is_refilling = false
	if cached_paths.size() < CACHE_TARGET_SIZE:
		_refill_cache(SessionConfig.pixabay_query)
