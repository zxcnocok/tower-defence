extends Node

# Текущий номер волны
var current_wave := 1
# Бонус за завершение волны
@export var wave_completion_bonus := 50
# Базовая статистика игрока
var player_gold := 100
var player_health := 1

# Ссылка на сцену Game Over
@export var game_over_scene: PackedScene

# Сигнал для обновления UI (опционально)
signal health_changed(new_health)
signal game_over_reached()

func _ready():
	print("GameManager загружен. Начальная волна: ", current_wave)
	print("Начальное здоровье игрока: ", player_health)
	
	# Если не установлена сцена в инспекторе, загружаем по пути
	if not game_over_scene:
		game_over_scene = load("res://gameover.tscn")

# === Основные методы для волн ===
func get_current_wave() -> int:
	return current_wave

func start_next_wave():
	current_wave += 1
	print("🌊 Начинается волна: ", current_wave)

# === Методы для управления ресурсами игрока ===
func add_gold(amount: int):
	player_gold += amount
	print("💰 +", amount, " золота. Всего: ", player_gold)

func take_damage(damage: int):
	player_health -= damage
	print("💔 Игрок получил урон: ", damage, ". Осталось здоровья: ", player_health)
	
	# Отправляем сигнал об изменении здоровья
	health_changed.emit(player_health)
	
	# Проверяем конец игры
	if player_health <= 0:
		game_over()

func game_over():
	print("💀 ИГРА ОКОНЧЕНА! Вы достигли волны ", current_wave)
	
	# Отправляем сигнал
	game_over_reached.emit()
	
	# Сразу переходим на сцену Game Over
	switch_to_game_over_scene()

func switch_to_game_over_scene():
	if game_over_scene:
		# 1. Паузим игру
		get_tree().paused = true
		
		# 2. Создаём экземпляр сцены
		var game_over_instance = game_over_scene.instantiate()
		
		# 3. Устанавливаем режим обработки для самой сцены
		game_over_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		
		# 4. Добавляем на самый верх
		get_tree().root.add_child(game_over_instance)
		
		# 5. Показываем курсор мыши
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		print("Переход на сцену Game Over выполнен")
	else:
		print("ОШИБКА: Сцена Game Over не загружена!")

# НОВАЯ ФУНКЦИЯ: Сброс состояния игры
func reset_game_state():
	print("=== СБРОС СОСТОЯНИЯ ИГРЫ ===")
	current_wave = 1
	player_gold = 100
	player_health = 1
	print("Состояние сброшено: Волна=", current_wave, 
		  ", Золото=", player_gold, ", Здоровье=", player_health)
