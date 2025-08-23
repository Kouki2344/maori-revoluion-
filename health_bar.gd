extends TextureProgressBar

@export var smooth_transition: bool = true
@export var transition_speed: float = 5.0

var actual_value: float

func _ready():
	actual_value = value

func _process(delta):
	if smooth_transition and abs(value - actual_value) > 0.1:
		value = lerp(value, actual_value, delta * transition_speed)
	else:
		value = actual_value
		
	# Change color based on health percentage
	update_health_color()

func update_health_color():
	var health_percent = float(value) / float(max_value)
	
	# Change progress texture modulation based on health
	if health_percent > 0.7:
		self_modulate = Color.GREEN
	elif health_percent > 0.3:
		self_modulate = Color.YELLOW
	else:
		self_modulate = Color.RED
