extends Node

static var instance: GameManager

var gold: int = 200
var lives: int = 20

func _ready() -> void:
	instance = self
	print("✅ GameManager загружен")

func add_gold(amount: int) -> void:
	gold += amount
	print("💰 Золото: ", gold)

func take_damage(amount: int) -> void:
	lives -= amount
	print("💔 Жизни: ", lives)
	
	if lives <= 0:
		game_over()

func game_over() -> void:
	print("☠️ Game Over")
	get_tree().paused = true
