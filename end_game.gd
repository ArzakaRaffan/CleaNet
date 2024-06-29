extends Node2D
@onready var dead_sound = $deadSound
@onready var status_label = $statusLabel
@onready var end_score_2 = $endScore2
@onready var try_again_button = $tryAgainButton
@onready var exit_button = $exitButton

const HIGHSCORE_FILE = "user://savehighscore.save"

func _ready():
	dead_sound.play()
	try_again_button.disabled = true
	exit_button.disabled = true
	GlobalGamePointSender.send_point(Global.score)
	GlobalGamePointSender.request_failed.connect(
		func(error_message: String) -> void:
			status_label.text = "Failed to send request: %s" % error_message
			try_again_button.disabled = false
			exit_button.disabled = false
	)
	
	GlobalGamePointSender.send_point_succeed.connect(
		func(response_messages: String, added_point: int) -> void:
			status_label.text = "YOU GET %d PTS" % added_point
			try_again_button.disabled = false
			exit_button.disabled = false
	)
	
	GlobalGamePointSender.send_point_failed.connect(
		func(error_message: String) -> void:
			status_label.text = "ERROR"
			try_again_button.disabled = false
			exit_button.disabled = false
	)
	
func _process(_delta):
	end_score_2.text = "SCORE: %d" % Global.score

func _on_try_again_button_pressed():
	BgmManager.revolume(-5)
	get_tree().change_scene_to_file("res://main_menu.tscn")
	save_score()
	Global.score = 0

func _on_exit_button_pressed():
	save_score()
	Global.score = 0
	get_tree().quit()

func save_score():
	if Global.score > Global.highScore:
		var file = FileAccess.open(HIGHSCORE_FILE, FileAccess.WRITE_READ)
		file.store_32(Global.score)
	
