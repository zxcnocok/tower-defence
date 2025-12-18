extends Node2D


var arrow = preload("res://arrow.tscn")
var arrowDamage = 5
var pathName
var currTargets = []
var curr


func _on_tower_body_entered(body):
	if "PathFollow2D2" in body.name:
		currTargets = get_node("/root/Node2D2/Node2D/Path2D/PathFollow2D2/slime").get_overlapping_bodies()
		print(currTargets)
		
