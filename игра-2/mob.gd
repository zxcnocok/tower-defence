extends CharacterBody2D

@export var max_health := 100.0
@export var speed := 50.0
@export var reward := 10

@onready var path_follow = get_parent() as PathFollow2D
var current_health: float

func _ready() -> void:
	current_health = max_health
	
	# ТОЛЬКО проверка, НИКАКОГО спавна!
	if not path_follow:
		print("❌ Моб не в PathFollow2D!")
		queue_free()
		return

func _physics_process(delta: float) -> void:
	if not path_follow:
		return
	
	# Только движение
	path_follow.progress += speed * delta
	global_position = path_follow.global_position
	
	if path_follow.progress_ratio >= 1.0:
		reach_end()

func take_damage(damage: float) -> void:
	current_health -= damage
	
	if current_health <= 0:
		die()

func die() -> void:
	# Только награда и удаление
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").add_gold(reward)
	
	queue_free()

func reach_end() -> void:
	# Только урон и удаление
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").take_damage(1)
	
	queue_free()
