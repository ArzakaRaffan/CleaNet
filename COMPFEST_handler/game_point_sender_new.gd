extends Node

signal request_failed(error_message: String)
signal send_point_succeed(response_messages: String, added_point: int)
signal send_point_failed(error_message: String)

const GAME_CODE = "ARCADE_5"
const SIGNATURE_SECRET = "oqtZiTK6y1S8IwmbBMWHtw=="
const URL := "https://quantum-games-dev.fly.dev/point"


func sha256(data: PackedByteArray) -> PackedByteArray:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(data)
	return ctx.finish()


func send_point(score: int):
	var now := Time.get_datetime_dict_from_system()
	var timestamp := "%d-%02d-%02dT%02d:%02d:%02dZ" % [now.year, now.month, now.day, now.hour, now.minute, now.second]
	
	# JSON.stringify bikin urutan keysnya berantakan
	#var request_dict := {
		#"userPlaygroundId": GlobalGameCodeVerifier.user_playground_id,
		#"attemptId": GlobalGameCodeVerifier.attempt_id,
		#"score": score
	#}
	#var request_body := JSON.stringify(request_dict)
	
	var request_string := '{"userPlaygroundId":"%s","attemptId":"%s","score":%d}' % [GlobalGameCodeVerifier.user_playground_id, GlobalGameCodeVerifier.attempt_id, score]
	var body_raw := request_string.to_utf8_buffer()
	var signature := await generate_signature(body_raw, timestamp)
	
	var headers := [
		"Content-Type: application/json",
		"X-Gamecode: " + GAME_CODE,
		"X-Timestamp: " + timestamp,
		"X-Signature: " + signature
	]
	
	#print("URL: ", URL)
	#print("Timestamp: ", timestamp)
	#print("Request Body: ", request_body)
	#print("Body Hash: ", sha256(body_raw).hex_encode())
	#print("Signature Base: ", "POST:/point:%s:%s" % [sha256(body_raw).hex_encode(), timestamp])
	#print("Signature: ", signature)
	#for header in headers:
		#print("Header: ", header)
	
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	var error := http_request.request(URL, headers, HTTPClient.METHOD_POST, request_string)
	if error != OK:
		request_failed.emit(error)


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var result_body := body.get_string_from_utf8()
	print("Result Body: ", result_body)
	
	if response_code == 200:
		var response: Dictionary = JSON.parse_string(result_body)
		GlobalGameCodeVerifier.user_playground_id = ""
		GlobalGameCodeVerifier.attempt_id = ""
		send_point_succeed.emit(response.responseMessages, response.addedPoint)
	else:
		var error: Dictionary = JSON.parse_string(result_body)
		send_point_failed.emit(error.message)


func generate_signature(body: PackedByteArray, timestamp: String) -> String:
	var hash_body := sha256(body)
	var hex_hash := hash_body.hex_encode().to_lower()
	var base_signature := "POST:/point:%s:%s" % [hex_hash, timestamp]
	
	var payload := {
		"inputString" : base_signature,
		"secretKey" : SIGNATURE_SECRET,
		"algo" : "SHA-512",
		"outputFormat" : "Base64"
	}
	
	# TODO: SHA512 failed handling
	return await SHA512.sha512_base64(payload)
