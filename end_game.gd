extends Node2D
@onready var dead_sound = $deadSound

const HIGHSCORE_FILE = "user://savehighscore.save"
# Called when the node enters the scene tree for the first time.
func _ready():
	dead_sound.play()
	
@onready var end_score_2 = $endScore2


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	
