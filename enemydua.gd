extends CharacterBody2D

var SPEED = 55
var player_chase = false
var is_dying = false
var has_double_spawn = false
var pecahan = false
var can_shoot = true
@onready var softCollision = $softCollision2
@onready var anim_enemy_2 = $animEnemy2

signal enemy2Dead

func _physics_process(delta):
	if Global.alive and not is_dying:
		if player_chase:
			position += (Global.player.position - position) / SPEED
		if softCollision.is_colliding(): #ini implement softCollisionnya biar enemy ngga nge stack di satu tempat
			position += softCollision.get_push_vector() * delta * 25


func _on_enemy_2_dead():
	if not has_double_spawn:
		call_deferred("_spawn_double_enemies")
	
func _spawn_double_enemies():

	var enemy_scene = preload("res://enemydua.tscn")  # Preload the scene once
	var enemy_instance_double1 = enemy_scene.instantiate()
	enemy_instance_double1.position = position + Vector2(0, 20)
	enemy_instance_double1.has_double_spawn = true
	enemy_instance_double1.scale = Vector2(0.7, 0.7)
	enemy_instance_double1.SPEED = 40
	get_parent().add_child(enemy_instance_double1)  # Add to scene tree
	enemy_instance_double1.pecahan = true
	

	var enemy_instance_double2 = enemy_scene.instantiate()
	enemy_instance_double2.position = position - Vector2(0, 20)
	enemy_instance_double2.has_double_spawn = true
	enemy_instance_double2.scale = Vector2(0.7, 0.7)
	enemy_instance_double2.SPEED = 40
	get_parent().add_child(enemy_instance_double2)  # Add to scene tree
	enemy_instance_double2.pecahan = true
	
	has_double_spawn = true  # Set the flag to prevent further doubling


func _on_player_detect_body_entered(body):
	player_chase = true
	if body.name == "playerCharacter": 
		Global.player = body


func _on_bullet_detect_area_entered(area):
	if area.name == "Bullet" or area.name.begins_with("@Area2D@"):
		if not is_dying:
			Global.score += 1
			is_dying = true

			area.queue_free()
			if self.pecahan:
				anim_enemy_2.play("Mati")
				await(anim_enemy_2.animation_finished)
				queue_free()
			else:
				if can_shoot:
					can_shoot = false
					anim_enemy_2.play("Misah")
					await(anim_enemy_2.animation_finished)
					queue_free()
					emit_signal("enemy2Dead")
