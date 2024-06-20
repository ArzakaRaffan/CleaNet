extends Node

const enem = preload("res://enemy1.tscn")
const enem2 = preload("res://enemydua.tscn")
@onready var enemydeath = $enemydeath

# Define the boundaries of the arena
const MIN_X = 15
const MAX_X = 560
const MIN_Y = 20
const MAX_Y = 320

var previous_score = 0  # Variable to store the previous score

func _ready():
	Global.alive = true
	previous_score = Global.score  # Initialize the previous score

func _process(delta):
	# Check if the score has changed
	if Global.score != previous_score:
		enemydeath.play()
		previous_score = Global.score  # Update the previous score

func _on_arena_limit_area_entered(area):
	if area.name == "Bullet" or area.name.begins_with("@Area2D@"):
		var bullet_position = area.global_position
		var randomY = randf_range(0, 130)
		area.queue_free()
		
		if bullet_position.y < 180:
			bullet_position += Vector2(0, randomY)
		elif bullet_position.y > 180:
			bullet_position -= Vector2(0, randomY)
		
		bullet_position = clamp_position(bullet_position)
		call_deferred("_spawn_enemy", bullet_position)

func _on_arena_limit_atas_bawah_area_entered(area):
	if area.name == "Bullet" or area.name.begins_with("@Area2D@"):
		var bullet_position = area.global_position
		var randomX = randf_range(0, 250)
		area.queue_free()
		
		if bullet_position.x < 285:
			bullet_position += Vector2(randomX, 0)
		elif bullet_position.x > 285:
			bullet_position -= Vector2(randomX, 0)
			
		bullet_position = clamp_position(bullet_position)
		call_deferred("_spawn_enemy", bullet_position)

func _spawn_enemy(position):
	var enemy_instance = null
	if randf_range(0, 1) < 0.5:
		enemy_instance = enem.instantiate()
	else:
		enemy_instance = enem2.instantiate()
	
	enemy_instance.global_position = position
	get_parent().add_child(enemy_instance)

func clamp_position(position):
	position.x = clamp(position.x, MIN_X, MAX_X)
	position.y = clamp(position.y, MIN_Y, MAX_Y)
	return position
	
func pause():
	get_tree().paused = true
	for child in get_children():
		if child.name == "Bullet":
			remove_child(child)
	$pausedMenu.show()
	$"User Interface/ScoreUI".hide()
	$"User Interface/PauseUI".hide()
	$"User Interface/HighScore".hide()
	
func unpause():
	$pausedMenu.hide()
	$"User Interface/ScoreUI".show()
	$"User Interface/PauseUI".show()
	$"User Interface/HighScore".show()
	get_tree().paused = false

func _on_quit_button_pressed():
	get_tree().quit()

func _on_player_character_player_dead():
	var parent = get_parent()
	if parent != null:
		for child in parent.get_children():
			if child.name == "enemy1" or child.name == "enemydua" or child.name.begins_with("@CharacterBody2D@"):
				parent.remove_child(child)
