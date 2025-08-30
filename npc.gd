extends CharacterBody2D

@export var npc_name: String = "Villager"
@export_multiline var dialogue_text: String = "Hello there, traveler!"

@onready var interaction_indicator = $InteractionIndicator
@onready var dialogue_box = $DialogueBox

var player_in_range: bool = false
var is_interacting: bool = false

func _ready():
	# Hide interaction indicator initially
	if interaction_indicator:
		interaction_indicator.visible = false
	
	# Hide dialogue box initially
	if dialogue_box:
		dialogue_box.visible = false
	
	print(npc_name + " is ready for interaction")

func _process(delta):
	# Show/hide interaction indicator based on player proximity
	if interaction_indicator:
		interaction_indicator.visible = player_in_range and not is_interacting

func _input(event):
	if event.is_action_pressed("ui_accept") and player_in_range and not is_interacting:
		start_interaction()

func start_interaction():
	is_interacting = true
	print("Interacting with " + npc_name)
	
	# Show dialogue box
	if dialogue_box:
		dialogue_box.show_dialogue(npc_name, dialogue_text)
	
	# Disable player movement during interaction (optional)
	get_tree().call_group("player", "set_interaction_mode", true)

func end_interaction():
	is_interacting = false
	print("Ended interaction with " + npc_name)
	
	# Hide dialogue box
	if dialogue_box:
		dialogue_box.hide()
	
	# Re-enable player movement
	get_tree().call_group("player", "set_interaction_mode", false)

# Player detection
func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		print("Player entered interaction range")

func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		print("Player left interaction range")
		if is_interacting:
			end_interaction()
		
