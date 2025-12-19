extends Node

@export var mob_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var mobs_per_wave: int = 5

var mobs_spawned: int = 0
var current_wave: int = 1
var is_spawning: bool = false

func _ready() -> void:
	print("✅ WaveSpawner запущен")
	
	await get_tree().create_timer(2.0).timeout
	start_wave()

func start_wave() -> void:
	if is_spawning:
		return 
	
	is_spawning = true
	print("🌊 Волна ", current_wave, " началась")
	
	mobs_spawned = 0
	spawn_mob_sequence()

func spawn_mob_sequence() -> void:
	if mobs_spawned >= mobs_per_wave:
		
		is_spawning = false
		current_wave += 1
		print("✅ Волна завершена")
		
		
		await get_tree().create_timer(5.0).timeout
		start_wave()
		return
	

	spawn_single_mob()
	mobs_spawned += 1
	

	await get_tree().create_timer(spawn_interval).timeout
	spawn_mob_sequence()

func spawn_single_mob() -> void:
	if not mob_scene:
		print("❌ Сцена моба не выбрана!")
		return
	

	var path = get_parent().get_node("Path2D")
	if not path:
		print("❌ Path2D не найден!")
		return
	
	var new_path_follow = PathFollow2D.new()
	new_path_follow.name = "MobPath_%d_%d" % [current_wave, mobs_spawned]
	path.add_child(new_path_follow)
	
	var mob = mob_scene.instantiate()
	new_path_follow.add_child(mob)
	
	print("👾 Моб создан: ", mobs_spawned + 1, "/", mobs_per_wave)
