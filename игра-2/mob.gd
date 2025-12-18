extends CharacterBody2D

# Характеристики
var max_health := 100.0
var speed := 50.0
var reward := 10

# Параметры роста
var wave_number := 1
var health_growth_per_wave := 20.0
var reward_growth_per_wave := 2

@onready var path_follow = get_parent() as PathFollow2D
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $healthbar  # Добавляем ссылку на HealthBar
@onready var health_bar_container = $healthbar/healthcontainer  # Контейнер прогресс-бара
@onready var health_bar_fill = $healthbar/healthcontainer/healthfill  # Заполнение HP

var current_health: float
var last_position: Vector2

func _ready() -> void:
	# Получаем номер волны из GameManager (если есть)
	get_wave_number_from_manager()
	
	# Рассчитываем характеристики для текущей волны
	calculate_stats_for_wave()
	
	current_health = max_health
	last_position = global_position
	
	# Инициализируем HP-бар
	initialize_health_bar()
	
	# Начинаем с анимации покоя
	if sprite:
		sprite.play("idle")

# Инициализация HP-бара
func initialize_health_bar() -> void:
	if health_bar and health_bar_fill:
		# Скрываем HP-бар если здоровье полное
		health_bar.visible = false
		
		# Настраиваем размер прогресс-бара
		health_bar_fill.size.x = 10  # Ширина полоски (можно настроить)
		
		# Обновляем отображение здоровья
		update_health_bar()

# Обновление HP-бара
func update_health_bar() -> void:
	if health_bar and health_bar_fill:
		var health_percentage = current_health / max_health
		
		# Показываем HP-бар только если здоровье не полное
		health_bar.visible = health_percentage < 1.0
		
		# Обновляем размер заполнения
		health_bar_fill.size.x = 10 * health_percentage
		
		# Меняем цвет в зависимости от здоровья
		if health_percentage > 0.7:
			health_bar_fill.color = Color.GREEN
		elif health_percentage > 0.3:
			health_bar_fill.color = Color.YELLOW
		else:
			health_bar_fill.color = Color.RED

# Получаем номер волны из GameManager
func get_wave_number_from_manager():
	if has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		if gm.has_method("get_current_wave"):
			wave_number = gm.get_current_wave()
		elif gm.has_property("current_wave"):
			wave_number = gm.current_wave
	print("Моб создан для волны: ", wave_number)

# Функция расчета характеристик
func calculate_stats_for_wave():
	max_health = 100.0 + (wave_number - 1) * health_growth_per_wave
	reward = 10 + (wave_number - 1) * reward_growth_per_wave
	speed = 50.0  # Постоянная
	
	print("Характеристики моба:")
	print("  Здоровье: ", max_health)
	print("  Награда: ", reward)
	print("  Скорость: ", speed)

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
	if sprite:
		update_animation(move_dir)
	
	# 5. Проверяем конец пути
	if path_follow.progress_ratio >= 1.0:
		reach_end()

func update_animation(movement: Vector2) -> void:
	# Если спрайт не найден - выходим
	if not sprite:
		return
	
	# Если почти не двигаемся - показываем покой
	if movement.length() < 0.1:
		sprite.play("idle")
		return
	
	# Смотрим, движение больше по горизонтали или вертикали
	if abs(movement.x) > abs(movement.y):
		# Движение вправо-влево
		if movement.x > 0:
			sprite.play("dwalk")
			sprite.flip_h = false
		else:
			sprite.play("dwalk")
			sprite.flip_h = true
	else:
		# Движение вверх-вниз
		if movement.y > 0:
			sprite.play("uwalk")
		else:
			sprite.play("swalk")

func take_damage(damage: float) -> void:
	current_health -= damage
	
	print("Моб получил урон: ", damage, " (Осталось HP: ", current_health, ")")
	
	# Обновляем HP-бар
	update_health_bar()
	
	if current_health <= 0:
		die()

func die() -> void:
	# 1. Воспроизводим анимацию смерти
	if sprite and sprite.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished  # Ждем окончания анимации
	
	# 2. Даем награду (уже с учетом волны)
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").add_gold(reward)
		print("Награда за моба: ", reward, " золота")
	
	# 3. Удаляем моба
	queue_free()

func reach_end() -> void:
	# Урон игроку
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").take_damage(1)
	
	queue_free()
	
