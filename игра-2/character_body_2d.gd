extends CharacterBody2D

func _physics_process(delta):
	get_parent().progress += 100 * delta
