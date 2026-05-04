extends Node

signal request_failed(error_message: String)
signal game_code_succeed(attempt_id: String, username: String)
signal game_code_failed(error_message: String)

const ARCADE_CODE := ""  # TODO: Replace with your actual arcade code
const SIGNATURE_SECRET := ""  # TODO: Replace with your actual secret key
const BASE_URL := ""  # TODO: Change based on environment
const ENDPOINT := "/v1/token"

var _http_request: HTTPRequest

func _ready():
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

func verify_game_code(token: String):
	var request_body := '{"token":"%s","arcadeCode":"%s"}' % [token, ARCADE_CODE]
	
	var timestamp := _get_timestamp()
	print("=== VERIFY GAME CODE ===")
	print("Request Body: ", request_body)
	print("Timestamp: ", timestamp)
	
	var signature := await _generate_signature(request_body.to_utf8_buffer(), timestamp)
	print("Signature: ", signature)
	
	if signature.is_empty():
		request_failed.emit("Failed to generate signature")
		return
	
	var headers := [
		"Content-Type: application/json",
		"X-Timestamp: " + timestamp,
		"X-Signature: " + signature,
	]
	
	var error := _http_request.request(BASE_URL + ENDPOINT, headers, HTTPClient.METHOD_POST, request_body)
	if error != OK:
		request_failed.emit("Failed to dispatch request: %d" % error)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var raw := body.get_string_from_utf8()
	print("=== RESPONSE ===")
	print("Response Code: ", response_code)
	print("Raw Body: ", raw)
	
	var response: Dictionary = JSON.parse_string(raw)
	if response == null:
		request_failed.emit("Failed to parse response")
		return
	
	if response_code == 200 and response.get("success", false):
		var data: Dictionary = response.get("data", {})
		game_code_succeed.emit(data.get("attemptId", ""), data.get("username", ""))
	else:
		game_code_failed.emit(response.get("message", "HTTP %d" % response_code))

func _generate_signature(body_raw: PackedByteArray, timestamp: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(body_raw)
	var hex_hash := ctx.finish().hex_encode()
	
	var base_string := "POST:%s:%s:%s" % [ENDPOINT, hex_hash, timestamp]
	print("Base string: ", base_string)  # cek base string benar
	
	var result = await SHA512.hmac_sha512_base64(SIGNATURE_SECRET, base_string)
	print("Signature result: ", result)  # cek apakah ini pernah tercapai
	return result

func _get_timestamp() -> String:
	var now := Time.get_datetime_dict_from_system(true)  # true = UTC
	return "%d-%02d-%02dT%02d:%02d:%02d.000Z" % [
		now.year, now.month, now.day,
		now.hour, now.minute, now.second
	]
