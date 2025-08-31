extends Sprite2D

@export var shake_intensity: float = 2.0
@export var shake_speed: float = 3.0

var original_position: Vector2
var time: float = 0.0

func _ready():
	original_position = position
	
func _process(delta):
	time += delta * shake_speed
	
	#Shake animation
	position.y = original_position.y + sin(time) * shake_intensity
	position.x = original_position.x + cos(time * 0.8) * shake_intensity * 0.5
