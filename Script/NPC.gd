extends Area2D

#Dialogue content
var dialogue_text = [
	"Tāne (head of village): 
		Hello there young man!",
	"Tāne: 
		My village got invaded.", 
	"Tāne: 
		All the villagers and your 
		family got captured by 
		Whiro (God of darkness).",
	"You: 
		Oh no!",
	"Tāne: 
		Can you help me to save them 
		and bring peace back to 
			this village?",
	"You: 
		YES, I will try my best
		to help.",
	"Tāne: 
		Thank you so much young man!",
	"Tāne: 
		But be very careful, there 
		are enemies everywhere.",
	"Tāne:
		Press E or click to attack!",
	"You:
		 Got it!",
	"Tāne: 
		Waimarie! (good luck)"
]

var current_line = 0
var dialogue_active = false
var player_in_range = false
var player_ref: Node2D = null

@onready var label = $Label
@onready var panel = $Panel
@onready var collision_shape = $CollisionShape2D

func _ready():
	hide_dialogue()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	#Set radius to 40
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = 40
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		if dialogue_active:
			hide_dialogue()

func show_dialogue():
	dialogue_active = true
	panel.visible = true
	label.visible = true
	current_line = 0
	show_next_line()

func hide_dialogue():
	dialogue_active = false
	panel.visible = false
	label.visible = false

func show_next_line():
	if current_line < dialogue_text.size():
		label.text = dialogue_text[current_line]
		current_line += 1
	else:
		hide_dialogue()

#Space to interact
func _input(event):
	if event.is_action_pressed("interact"):
		if player_in_range and not dialogue_active:
			show_dialogue()
		elif dialogue_active:
			show_next_line()
