extends Sprite2D

@export var amplitude: float = 6.0    #How high it moves
@export var frequency: float = 1.0     #How fast it moves
@export var vertical_offset: float = 0.0  #Base position 
@export var disappear_distance: float = 200.0 #Disappear distance

var player_node: Node2D
var original_y: float
var time: float = 0.0

func _ready():
	#Keeping the original position
	original_y = position.y
	player_node = get_node("../Player") 

func _process(delta):
	time += delta
	
	#Move up and down 
	position.y = original_y + sin(time * frequency * TAU) * amplitude + vertical_offset
	
	#Check if player is close and disappear
	if player_node:
		var distance = global_position.distance_to(player_node.global_position)
		visible = distance > disappear_distance
