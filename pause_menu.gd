extends Control

func _ready():
	$AnimationPlayer.play("RESET")
	hide()
	
#Remove blur effect
func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()

#Blur effect when paused
func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	show()
	
func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused ==true:
		resume()
	
func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	#Unpause before changing scene
	get_tree().paused = false
	get_tree().change_scene_to_file("res://level_menu.tscn")

#ESC to pause
func _process(delta):
	testEsc()
