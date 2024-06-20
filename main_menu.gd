extends Node2D

@onready var error_label = $inputCodeMenu/errorLabel
@onready var verif_code = $inputCodeMenu/verifCode
@onready var input_code_menu = $inputCodeMenu
@onready var credit_menu = $creditMenu
@onready var info_menu = $infoMenu
var credMenuOpen = false
var infoMenuOpen = false

func _ready():
	pass

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
	if verif_code.text == "12345":
		error_label.hide()
		verif_code.clear()
		BgmManager.revolume(-15)
		get_tree().change_scene_to_file("res://main_scene.tscn")
	else:
		verif_code.clear()
		error_label.show()


