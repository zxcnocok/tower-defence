extends CanvasLayer



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://node_2d.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_setting_pressed() -> void:
	get_tree().change_scene_to_file("res://options.tscn")


func _on_minigame_pressed() -> void:
	get_tree().change_scene_to_file("res://minigame.tscn")
