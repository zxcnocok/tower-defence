extends CharacterBody2D

var target
var Speed = 10
var pathName = ""
var arrowDamage

func _physics_process(_delta):
	var pathSpawnerNode = get_tree().get_root().get_node("Node2D2/Node2D2")
	
	for i in pathSpawnerNode.get_child_count():
		if pathSpawnerNode.get_child(1).name == pathName:
			target = pathSpawnerNode.get_child(1).get_child(0).get_child(0).global_position
			
	
	velocity = global_position.direction_to(target) *Speed
	
	look_at(target)
	
	move_and_slide()
func _on_area_2d_body_entered(body):
	if "CharacterBody2D" in body.name:
			body.max_health -= arrowDamage
			queue_free()
