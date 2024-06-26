extends Area2D

func _process(delta): #ini bullet yang dipake, yang fire_bulllet cuma buat coba coba hehe
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * 900 * delta
