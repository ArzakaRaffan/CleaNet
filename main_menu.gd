extends Node2D


@onready var verif_code = $inputCodeMenu/verifCode
@onready var input_code_menu = $inputCodeMenu
@onready var verif_button = $inputCodeMenu/verifButton
@onready var start_game_button = $inputCodeMenu/startGameButton
@onready var credit_menu = $creditMenu
@onready var info_menu = $infoMenu
var credMenuOpen = false
var infoMenuOpen = false

@onready var error_label = $inputCodeMenu/errorLabel


func _ready() -> void:
	GlobalGameCodeVerifier.request_failed.connect(
		func(error_message: String) -> void:
			error_label.show()
			error_label.text = "Failed to send request: %s" % error_message
			verif_button.disabled = false
	)
	
	GlobalGameCodeVerifier.game_code_succeed.connect(
		func(response_messages: String) -> void:
			error_label.show()
			error_label.text = "SUCCESS"
			start_game_button.disabled = false
	)
	
	GlobalGameCodeVerifier.game_code_failed.connect(
		func(error_message: String) -> void:
			error_label.show()
			error_label.text = "INVALID CODE"
			verif_code.clear()
			verif_button.disabled = false
	)

func _process(delta):
	if input_code_menu.visible == true:
		if Input.is_action_just_pressed("Enter"):
			_on_verif_button_pressed()

func _on_info_button_pressed():
	if not infoMenuOpen:
		credMenuOpen = true
		credit_menu.show()

func _on_htp_button_pressed():
	if not credMenuOpen:
		infoMenuOpen = true
		info_menu.show()

func _on_credit_close_pressed():
	credMenuOpen = false
	credit_menu.hide()

func _on_info_close_button_pressed():
	infoMenuOpen = false
	info_menu.hide()

func _on_start_button_pressed():
	input_code_menu.show()

func _on_input_close_button_pressed():
	error_label.hide()
	input_code_menu.hide()

func _on_verif_button_pressed():
	if verif_code.text == "":
		error_label.show()
		error_label.text = "EMPTY CODE"
	else:
		verif_button.disabled = true
		error_label.show()
		error_label.text = "CONNECTING..."
		GlobalGameCodeVerifier.verify_game_code(verif_code.text)

func _on_start_game_button_pressed():
	error_label.hide()
	verif_code.clear()
	BgmManager.revolume(-15)
	get_tree().change_scene_to_file("res://main_scene.tscn")
