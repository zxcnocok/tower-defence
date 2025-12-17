extends CharacterBody2D


@export var max_health := 100.0
@export var speed := 50.0
@export var speed_increase_per_wave := 5.0 
@export var speed_multiplier := 1.05    
@export var reward := 10

@onready var path_follow = get_parent() as PathFollow2D
@onready var anim_sprite = $AnimatedSprite2D  # Убедись, что у моба есть этот узел

var current_health: float
var last_position: Vector2

func _ready() -> void:
	current_health = max_health
	last_position = global_position
	
	# Начинаем с анимации покоя
	if anim_sprite:
		anim_sprite.play("idle")

func _physics_process(delta: float) -> void:
	if not path_follow:
		return
	
	# 1. Запоминаем где были
	var old_position = global_position
	
	# 2. Двигаемся по пути
	path_follow.progress += speed * delta
	global_position = path_follow.global_position
	
	# 3. Смотрим куда двигаемся
	var move_dir = global_position - old_position
	
	# 4. Меняем анимацию по направлению
	if anim_sprite:
		update_animation(move_dir)
	
	# 5. Проверяем конец пути
	if path_follow.progress_ratio >= 1.0:
		reach_end()

func update_animation(movement: Vector2) -> void:
	# Если почти не двигаемся - показываем покой
	if movement.length() < 0.1:
		anim_sprite.play("idle")
		return
	
	# Смотрим, движение больше по горизонтали или вертикали
	if abs(movement.x) > abs(movement.y):
		# Движение вправо-влево
		if movement.x > 0:
			anim_sprite.play("dwalk")
			anim_sprite.flip_h = false
		else:
			anim_sprite.play("dwalk")
			anim_sprite.flip_h = true
	else:
		# Движение вверх-вниз
		if movement.y > 0:
			anim_sprite.play("uwalk")
		else:
			anim_sprite.play("swalk")

func take_damage(damage: float) -> void:
	current_health -= damage
	
	if current_health <= 0:
		die()

func die() -> void:
	# 1. Воспроизводим анимацию смерти
	if anim_sprite and anim_sprite.has_animation("death"):
		anim_sprite.play("death")
		await anim_sprite.animation_finished  # Ждем окончания анимации
	
	# 2. Даем награду
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").add_gold(reward)
	
	# 3. Удаляем моба
	queue_free()

func reach_end() -> void:
	# Урон игроку
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").take_damage(1)
	
	queue_free()
