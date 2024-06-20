extends Node

var health
var player
var score
var alive
var highScore
var can_score
const HIGHSCORE_FILE = "user://savehighscore.save"


func _ready():
	alive = true
	score = 0
	can_score = true
	load_score()

func _process(delta):
	load_score()

func load_score():
	var file = FileAccess.open(HIGHSCORE_FILE, FileAccess.READ)
	if file:
		Global.highScore = file.get_32()
	else:
		file = FileAccess.open(HIGHSCORE_FILE, FileAccess.WRITE)
		file.store_32(0)  # Set the initial high score to 0
		file.close()
		Global.highScore = 0
