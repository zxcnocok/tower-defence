extends Panel

@onready var tower = preload("res://idle2.tscn")
var dragTower = null
var isDragging = false
var dragOffset = Vector2.ZERO

func _ready():
	# Включаем обработку ввода
	mouse_filter = MOUSE_FILTER_PASS

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Начало перетаскивания
				_on_mouse_down(event)
			else:
				# Завершение перетаскивания
				_on_mouse_up(event)
	
	elif event is InputEventMouseMotion and isDragging:
		# Перемещение башни
		_on_mouse_move(event)

func _on_mouse_down(event):
	if dragTower == null:
		# Создаем новую башню для перетаскивания
		dragTower = tower.instantiate()
		add_child(dragTower)
		
		# Устанавливаем начальную позицию
		dragTower.position = get_local_mouse_position() - dragTower.size / 2
		dragTower.scale = Vector2(0.32, 0.32)
		
		# Сохраняем смещение курсора от центра башни
		dragOffset = dragTower.position - get_local_mouse_position()
		
		isDragging = true
		
		# Отключаем физику во время перетаскивания
		dragTower.process_mode = Node.PROCESS_MODE_DISABLED
		print("Начато перетаскивание")

func _on_mouse_move(event):
	if isDragging and dragTower:
		# Обновляем позицию башни
		dragTower.position = get_local_mouse_position() + dragOffset

func _on_mouse_up(event):
	if isDragging and dragTower:
		var dropPosition = get_global_mouse_position()
		
		# Проверяем, можно ли разместить здесь башню
		if _can_place_tower(dropPosition):
			# Размещаем башню на игровом поле
			var path = get_tree().root.get_node("Node2D2/Towers")
			if path:
				# Удаляем из панели
				remove_child(dragTower)
				
				# Добавляем на игровое поле
				path.add_child(dragTower)
				dragTower.global_position = dropPosition
				
				# Включаем обработку
				dragTower.process_mode = Node.PROCESS_MODE_INHERIT
				
				print("Башня размещена в позиции: ", dropPosition)
			else:
				print("Ошибка: нод для размещения не найден")
				dragTower.queue_free()
		else:
			# Нельзя разместить - удаляем
			dragTower.queue_free()
			print("Нельзя разместить здесь")
		
		# Сбрасываем состояние
		dragTower = null
		isDragging = false

func _can_place_tower(position):
	# Проверка на размещение
	# 1. Не выходит за границы игровой области
	if position.x < 510:  # Примерная граница
		return true
	return false

# Альтернативная версия с использованием Area2D для проверки коллизий
func _can_place_tower_v2(position):
	var spaceState = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, position, 1)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = []
	
	var result = spaceState.intersect_ray(query)
	
	# Если есть столкновение, нельзя разместить
	if result:
		print("Столкновение с: ", result.collider.name)
		return false
	
	return true
