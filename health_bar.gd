extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar

@export var max_health: int = 200
var current_health: int = max_health
var health_per_hit: int = 10

func _ready():
	#Initialize health bar
	health_bar.max_value = max_health
	health_bar.value = max_health
	update_health_color()

func init_health(player_max_health: int, player_health_per_hit: int):
	max_health = player_max_health
	health_per_hit = player_health_per_hit
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health
	update_health_color()

func update_health(new_health: int):
	current_health = new_health
	health_bar.value = current_health
	update_health_color()

func update_health_color():
	var health_percent = float(current_health) / float(max_health)




	
	
