extends CharacterBody2D

var max_health := 100.0
var speed := 500.0
var reward := 10

var wave_number := 1
var health_growth_per_wave := 20.0
var reward_growth_per_wave := 2

@onready var path_follow = get_parent() as PathFollow2D
var sprite: AnimatedSprite2D = null

var current_health: float
var last_position: Vector2
var reached_end := false

var health_sprite: Sprite2D = null

func _ready() -> void:

	if has_node("AnimatedSprite2D"):
		sprite = $AnimatedSprite2D
	
	health_sprite = Sprite2D.new()
	health_sprite.name = "HealthSprite"
	health_sprite.centered = false
	health_sprite.z_index = 11
	health_sprite.visible = false 
	health_sprite.position = Vector2(-15, -20) 
	add_child(health_sprite)
	
	get_wave_number_from_manager()
	calculate_stats_for_wave()
	
	current_health = max_health
	last_position = global_position

func get_wave_number_from_manager():
	if has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		if gm.has_method("get_current_wave"):
			wave_number = gm.get_current_wave()
		elif gm.has_property("current_wave"):
			wave_number = gm.current_wave
	print("Моб создан для волны: ", wave_number)
	
func calculate_stats_for_wave():
	max_health = 100.0 + (wave_number - 1) * health_growth_per_wave
	reward = 10 + (wave_number - 1) * reward_growth_per_wave
	speed = 50.0
	
	print("Характеристики моба:")
	print("  Здоровье: ", max_health)
	print("  Награда: ", reward)
	print("  Скорость: ", speed)

func _physics_process(delta: float) -> void:
	if not path_follow or reached_end:
		return
	
	var old_position = global_position
	path_follow.progress += speed * delta
	global_position = path_follow.global_position
	
	var move_dir = global_position - old_position
	
	if sprite:
		update_animation(move_dir)
	
	if path_follow.progress_ratio >= 0.99 and not reached_end:
		reached_end = true
		reach_end()

func update_animation(movement: Vector2) -> void:
	if not sprite:
		return
	
	if movement.length() < 0.1:
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
		return
	
	if abs(movement.x) > abs(movement.y):
		if movement.x > 0:
			play_animation_safe("dwalk")
			if sprite: sprite.flip_h = false
		else:
			play_animation_safe("dwalk")
			if sprite: sprite.flip_h = true
	else:
		if movement.y > 0:
			play_animation_safe("uwalk")
		else:
			play_animation_safe("swalk")

func play_animation_safe(anim_name: String):
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)

func take_damage(damage: float) -> void:
	current_health -= damage
	
	print("Моб получил урон: ", damage, " (Осталось HP: ", current_health, ")")
	
	if not health_sprite.visible:
		health_sprite.visible = true
	
	update_health_bar()
	
	if current_health <= 0:
		die()

func update_health_bar():
	if not health_sprite or not health_sprite.visible:
		return
	
	var health_percentage = current_health / max_health
	var width = max(1, int(30 * health_percentage)) 
	
	var color: Color
	if health_percentage > 0.6:
		color = Color.GREEN
	elif health_percentage > 0.3: 
		color = Color.ORANGE
	else: 
		color = Color.RED
	
	health_sprite.texture = create_rect_texture(width, 4, color)

func create_rect_texture(width: int, height: int, color: Color) -> ImageTexture:
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

func die() -> void:
	print("Моб умирает!")
	
	health_sprite.visible = false
	
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished
	else:
		await get_tree().create_timer(0.3).timeout
	
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").add_gold(reward)
		print("Награда за моба: ", reward, " золота")
	
	queue_free()

func reach_end() -> void:
	print("Моб достиг конца пути!")
	
	health_sprite.visible = false
	
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").take_damage(1)
		print("Игрок получил 1 урон от моба")
	
	queue_free()
