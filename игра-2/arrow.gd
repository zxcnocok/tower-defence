extends CharacterBody2D

var target = null  # Конкретный враг для преследования
var speed = 300.0  # Скорость стрелы
var damage = 5
var alive_time = 3.0  # Время жизни стрелы (автоудаление)
var current_time = 0.0

func _ready():
	# Автоматическое удаление через N секунд если не попала
	set_physics_process(false)  # Ждем пока зададут цель

func _physics_process(delta):
	current_time += delta
	
	# Удаляем если стрела слишком долго летит
	if current_time >= alive_time:
		queue_free()
		return
	
	# Если цель уничтожена - удаляем стрелу
	if target and not is_instance_valid(target):
		queue_free()
		return
	
	# Летим к цели
	if target and is_instance_valid(target):
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * speed
		
		look_at(target.global_position)
	else:
		# Если нет цели - летим прямо
		velocity = transform.x * speed
	
	move_and_slide()
	
	# Проверяем столкновения
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		_check_collision(collision.get_collider())

func setup(new_target, new_damage):
	# Инициализация стрелы
	target = new_target
	damage = new_damage
	set_physics_process(true)
	look_at(target.global_position)

func _check_collision(body):
	# Проверяем столкновение с врагом
	if body and body.is_in_group("enemies"):
		print("Стрела попала в: ", body.name)
		
		# Наносим урон
		if body.has_method("take_damage"):
			body.take_damage(damage)
		elif body.has_method("hit"):
			body.hit(damage)
		elif "health" in body:
			body.health -= damage
		
		# Удаляем стрелу
		queue_free()

# Альтернативно, можно использовать Area2D для обнаружения
func _on_hitbox_body_entered(body):
	_check_collision(body)
