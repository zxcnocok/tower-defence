extends Node



var current_wave := 1
@export var wave_completion_bonus := 50
var player_gold := 100
var player_health := 1

@export var game_over_scene: PackedScene
@export var menu_scene: PackedScene

signal health_changed(new_health)
signal game_over_reached()

func _ready():
	print("GameManager загружен. Начальная волна: ", current_wave)
	print("Начальное здоровье игрока: ", player_health)
	
	if not game_over_scene:
		game_over_scene = load("res://gameover.tscn")
	
	if not menu_scene:
		menu_scene = load("res://menu.tscn")

func get_current_wave() -> int:
	return current_wave

func start_next_wave():
	current_wave += 1
	print("🌊 Начинается волна: ", current_wave)

func add_gold(amount: int):
	player_gold += amount
	print("💰 +", amount, " золота. Всего: ", player_gold)

func take_damage(damage: int):
	player_health -= damage
	print("💔 Игрок получил урон: ", damage, ". Осталось здоровья: ", player_health)
	
	health_changed.emit(player_health)
	
	if player_health <= 0:
		game_over()

func game_over():
	print("💀 ИГРА ОКОНЧЕНА! Вы достигли волны ", current_wave)
	
	game_over_reached.emit()
	
	switch_to_game_over_scene()

func switch_to_game_over_scene():
	if game_over_scene:
		get_tree().paused = true
		
		var game_over_instance = game_over_scene.instantiate()
		
		game_over_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		
		get_tree().root.add_child(game_over_instance)
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		print("Переход на сцену Game Over выполнен")
	else:
		print("ОШИБКА: Сцена Game Over не загружена!")

func reset_game_state():
	print("=== СБРОС СОСТОЯНИЯ ИГРЫ ===")
	
	unpause_game()
	
	current_wave = 1
	player_gold = 100
	player_health = 1
	
	print("Состояние сброшено: Волна=", current_wave, 
		  ", Золото=", player_gold, ", Здоровье=", player_health)

func restart_game():
	print("=== ПЕРЕЗАПУСК ИГРЫ ===")
	
	unpause_game()
	
	reset_game_state()
	
	get_tree().reload_current_scene()

func go_to_menu():
	print("=== ВЫХОД В МЕНЮ ===")
	
	unpause_game()
	
	reset_game_state()
	
	if menu_scene:
		get_tree().change_scene_to_packed(menu_scene)
	else:
		get_tree().change_scene_to_file("res://menu.tscn")

func unpause_game():
	if get_tree().paused:
		get_tree().paused = false
		print("Пауза снята")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
