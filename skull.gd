extends Sprite2D

@export var amplitude: float = 7.0    #How high it moves
@export var frequency: float = 1.0     #How fast it moves
@export var vertical_offset: float = 0.0  #Base position 

var original_y: float
var time: float = 0.0

func _ready():
	#Keeping the original Y position
	original_y = position.y

func _process(delta):
	time += delta
	#Move up and down 
	position.y = original_y + sin(time * frequency * TAU) * amplitude + vertical_offset
