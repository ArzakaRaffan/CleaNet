extends CharacterBody2D

var SPEED = 40
var player_chase = false
var is_dying = false
@onready var softCollision = $SoftCollision
@onready var animation_enemy = $animationEnemy
@onready var enemy_dead = $enemyDead
signal score_changed

func _physics_process(delta):
	if Global.score > 20 and Global.score <= 40:
		SPEED = 35
	elif Global.score > 40 and Global.score <= 60:
		SPEED = 32.5
	elif Global.score >60 and Global.score <= 100:
		SPEED = 30
	elif Global.score > 100 and Global.score <=150:
		SPEED = 27.5
	elif Global.score > 150 and Global.score <= 250:
		SPEED = 23.75
	elif Global.score > 250:
		SPEED = 20.00
	if Global.alive and not is_dying:
		if player_chase:
			position += (Global.player.position - position) / SPEED
		if softCollision.is_colliding(): #ini implement softCollisionnya biar enemy ngga nge stack di satu tempat
			position += softCollision.get_push_vector() * delta * 75

func _on_player_detection_body_entered(body):
	player_chase = true
	if body.name == "playerCharacter": 
		Global.player = body

func _on_bullet_detection_area_entered(area): #ini buat ngilangin bullet dan enemy kalau kena
	if area.name == "Bullet" or area.name.begins_with("@Area2D@"):
		if not is_dying:
			Global.score += 1
			animation_enemy.play("Dead")
			is_dying = true
			area.queue_free()
			await animation_enemy.animation_finished
			queue_free()

