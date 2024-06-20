extends Control

@onready var high_score = $HighScore


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.highScore > Global.score:
		high_score.text = "HIGH SCORE: %d" % Global.highScore
	else:
		high_score.text = "HIGH SCORE: %d" % Global.score
