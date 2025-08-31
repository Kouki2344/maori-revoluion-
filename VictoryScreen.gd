extends CanvasLayer

@onready var continue_button = $ContinueButton
@onready var restart_button = $RestartButton
@onready var quit_button = $QuitButton

func _ready():
	visible = false
	
	#Make sure UI processes
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	#Check every if all enemies are dead
	set_process(true)
	
func _process(delta):
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		show_victory()
		set_process(false)

func show_victory():
	visible = true
	get_tree().paused = true
	
	#Grab focus to make buttons clickable
	if restart_button:
		restart_button.grab_focus()
	elif continue_button:
		continue_button.grab_focus()
	elif quit_button:
		quit_button.grab_focus()
	
func _on_continue_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://level2.tscn")

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://level_menu.tscn")
