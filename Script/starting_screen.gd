extends Button

#Transfer to each scenes
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/level_menu.tscn")
	
func _on_help_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/help.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_helpback_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/starting_screen.tscn") 
