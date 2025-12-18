extends Node2D


var arrow = preload("res://arrow.tscn")
var arrowDamage = 5
var pathName
var currTargets = []
var curr


func _process(delta):
	if is_instance_valid(curr):
		self.look_at(curr.global_position)
	else:
		for i in get_node("ArrowContainer").get_child_count():
			get_node("ArrowContainer").get_child(i).queue_free()


func _on_tower_body_entered(body):
	if "PathFollow2D2" in body.name:
		var tempArray = []
		currTargets = get_node("PathFollow2D2").get_overlapping_bod8ies()
		print(currTargets)
	
		for i in currTargets:
			if "Slime" in i.name:
				tempArray.append(i)
				
		var currTarget = null
		
		for i in tempArray:
			if currTarget == null:
				currTarget = i.get_node("../")
			else:
				if i.get_parrent().get_progress() > currTarget.get_progress():
					currTarget = i.get_node("../")
		
		curr = currTarget
		pathName = currTarget.get_parent().name
		
		var tempArrow  = arrow.instantiate()
		tempArrow.pathName = pathName
		tempArrow.arrowDamage = arrowDamage
		get_node("ArrowContainer").add_child(tempArrow)
		tempArrow.global_position = $Aim.global_position
		
		
func _on_tower_body_exited(_body):
	currTargets = get_node("Tower").get_overlapping_bodies()
