extends Node2D

const secrets = preload("res://secrets.gd")

@onready var search_request: HTTPRequest = $SearchRequest
@onready var image_request: HTTPRequest = $ImageRequest


signal image_ready(texture: ImageTexture)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	search_request.request_completed.connect(_on_search_completed)
	image_request.request_completed.connect(_on_image_completed)
	
func search_and_load(query: String) -> void:
	var encoded_query: String = query.uri_encode()
	var url: String = "https://pixabay.com/api/?key=%s&q=%s&image_type=photo&per_page=20" % [secrets.PIXABAY_API_KEY, encoded_query]
	search_request.request(url)
	
func _on_search_completed(result: int, response_code: int, headers:PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		push_error("pixabay search failed with code: " + str(response_code))
		return
	var json_string: String = body.get_string_from_utf8()
	var parsed = JSON.parse_string(json_string)
	
	if parsed == null or not parsed.has("hits") or parsed["hits"].is_empty():
		push_warning("No pixabay results for that search.")
		return
	var hits: Array = parsed["hits"]
	var chosen = hits[randi() % hits.size()]
	
	var image_url: String = chosen["webformatURL"]
	
	image_request.request(image_url)
	
func _on_image_completed(result:int, response_code:int, headers: PackedStringArray, body: PackedByteArray):
	if response_code != 200:
		push_error("Image failed to download with code: " + str(response_code))
		return
	
	var image:Image = Image.new()
	var error: int = image.load_jpg_from_buffer(body)
	
	if error != OK:
		push_warning("Failed to decode downloaded image.")
		return
		
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	image_ready.emit(texture)
		
