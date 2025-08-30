extends Button

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://level_menu.tscn") 
	
func _on_helpbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://help.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level1.tscn")

func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level2.tscn") 

func _on_level_3_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level3.tscn")

func _on_level_4_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level4.tscn") 

func _on_level_5_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level5.tscn") 


func _on_helpback_pressed() -> void:
	get_tree().change_scene_to_file("res://starting_screen.tscn") 
