extends Node

@export var bgmPath = "res://Sound/bgm.wav"
var bgm = null

func _ready():
	bgm = AudioStreamPlayer.new()
	bgm.stream = load(bgmPath)
	add_child(bgm)
	bgm.volume_db =-5
	bgm.play()

func revolume(volume):
	bgm.volume_db = volume
