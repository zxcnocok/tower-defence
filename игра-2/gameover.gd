extends CanvasLayer



func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.restart_game()
	queue_free()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_inmenu_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.go_to_menu()
	queue_free()
