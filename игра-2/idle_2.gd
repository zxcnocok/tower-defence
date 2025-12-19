extends Node2D

var arrow = preload("res://arrow.tscn")
var arrowDamage = 5
var currTarget = null
var attackCooldown = 1.0
var timeSinceLastShot = 0.0

func _ready():
	print("Башня инициализирована")

func _process(delta):
	if currTarget and is_instance_valid(currTarget):
		timeSinceLastShot += delta
		look_at(currTarget.global_position)
		
		if timeSinceLastShot >= attackCooldown:
			_shoot_arrow()
			timeSinceLastShot = 0.0
	elif $ArrowContainer.get_child_count() > 0:
		# Очистка старых стрел
		for arrow in $ArrowContainer.get_children():
			arrow.queue_free()

func _on_tower_body_entered(body):
	# Лучшая проверка врага
	if body.is_in_group("enemies"):
		print("Враг вошел: ", body.name)
		if currTarget == null or not is_instance_valid(currTarget):
			currTarget = body

func _on_tower_body_exited(body):
	if body == currTarget:
		print("Враг вышел: ", body.name)
		currTarget = null
		
		# Ищем нового врага
		var bodies = $Tower.get_overlapping_bodies()
		for b in bodies:
			if b.is_in_group("enemies"):
				currTarget = b
				break

func _shoot_arrow():
	if currTarget and is_instance_valid(currTarget):
		var newArrow = arrow.instantiate()
		
		# Передаем цель и урон
		if newArrow.has_method("setup"):
			newArrow.setup(currTarget, arrowDamage)
		else:
			# Для обратной совместимости
			newArrow.target = currTarget
			newArrow.damage = arrowDamage
		
		$ArrowContainer.add_child(newArrow)
		newArrow.global_position = $Aim.global_position
		
		print("Выстрел по ", currTarget.name)
