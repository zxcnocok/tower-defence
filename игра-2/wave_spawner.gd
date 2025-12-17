extends Node

@export var mob_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var mobs_per_wave: int = 5

var mobs_spawned: int = 0
var current_wave: int = 1
var is_spawning: bool = false

func _ready() -> void:
	print("✅ WaveSpawner запущен")
	
	# Ждём 2 секунды
	await get_tree().create_timer(2.0).timeout
	start_wave()

func start_wave() -> void:
	if is_spawning:
		return  # Уже спавним!
	
	is_spawning = true
	print("🌊 Волна ", current_wave, " началась")
	
	mobs_spawned = 0
	spawn_mob_sequence()

func spawn_mob_sequence() -> void:
	if mobs_spawned >= mobs_per_wave:
		# Волна закончена
		is_spawning = false
		current_wave += 1
		print("✅ Волна завершена")
		
		# Ждём 5 сек перед следующей волной
		await get_tree().create_timer(5.0).timeout
		start_wave()
		return
	
	# Спавним одного моба
	spawn_single_mob()
	mobs_spawned += 1
	
	# Ждём перед следующим мобом
	await get_tree().create_timer(spawn_interval).timeout
	spawn_mob_sequence()

func spawn_single_mob() -> void:
	if not mob_scene:
		print("❌ Сцена моба не выбрана!")
		return
	
	# Находим Path2D
	var path = get_parent().get_node("Path2D")
	if not path:
		print("❌ Path2D не найден!")
		return
	
	# Создаём НОВЫЙ PathFollow2D для каждого моба
	var new_path_follow = PathFollow2D.new()
	new_path_follow.name = "MobPath_%d_%d" % [current_wave, mobs_spawned]
	path.add_child(new_path_follow)
	
	# Создаём моба
	var mob = mob_scene.instantiate()
	new_path_follow.add_child(mob)
	
	print("👾 Моб создан: ", mobs_spawned + 1, "/", mobs_per_wave)
