extends CanvasLayer

@onready var restart_button = $RestartButton
@onready var quit_button = $QuitButton

func _ready():
	#Start hidden
	visible = false
	
	#Process even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	#Connect buttons to functions
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func show_menu():
	#Pause game and show menu
	get_tree().paused = true
	visible = true

	#Make sure buttons can process well
	if restart_button:
		restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
		restart_button.grab_focus()
	elif quit_button:
		quit_button.process_mode = Node.PROCESS_MODE_ALWAYS
		quit_button.grab_focus()

func _on_restart_pressed() -> void:
	#Unpause before changing scene
	get_tree().paused = false
	get_tree().reload_current_scene()
		
func _on_quit_pressed() -> void:
	#Unpause before changing scene
	get_tree().paused = false
	get_tree().change_scene_to_file("res://level_menu.tscn")
