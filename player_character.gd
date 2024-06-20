extends CharacterBody2D

# Speed of the character
const SPEED = 150.0

signal player_dead
# Speed of rotation smoothing
const ROTATION_SPEED = 5.5

@onready var anim_player = $animPlayer
@onready var shoot_sound = $shootSound

# Distance threshold to prevent fast rotation when mouse is too close
const MIN_ROTATION_DISTANCE = 10.0

# Preload the bullet scene
const bulletPre = preload("res://Bullet.tscn")

func _ready():
	anim_player.play("Idle")

func directionInput():
	var moveDirection = Input.get_vector("A", "D", "W", "S")
	velocity = moveDirection * SPEED
	
	if velocity:
		anim_player.play("Walk")
	else:
		anim_player.play("Idle")

func _physics_process(delta):
	if Input.is_action_just_pressed("Click"):
		shoot()
	
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	var distance_to_mouse = global_position.distance_to(mouse_pos)
	
	var target_rotation = direction.angle()

	if distance_to_mouse > MIN_ROTATION_DISTANCE:
		global_rotation = lerp_angle(global_rotation, target_rotation, ROTATION_SPEED * delta)
	
	directionInput()
	move_and_slide()

func shoot():
	shoot_sound.play()
	var bullet = bulletPre.instantiate()
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation
	get_parent().add_child(bullet)

func _on_enemydetect_body_entered(body):
	if body.name == "enemy1" or body.name == "enemydua" or body.name.begins_with("@CharacterBody2D@"):
		call_deferred("_remove_player_and_change_scene")

func _remove_player_and_change_scene():
	Global.player = null
	Global.alive = false
	emit_signal("player_dead")
	get_tree().change_scene_to_file("res://end_game.tscn")
