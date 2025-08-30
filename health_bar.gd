extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar

@export var max_health: int = 200
var current_health: int = max_health
var health_per_hit: int = 10

func _ready():
	# Initialize health bar
	health_bar.max_value = max_health
	health_bar.value = max_health
	update_health_color()
	print("HealthBarUI ready on CanvasLayer")

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
	
	# Flash effect when damaged
	if new_health < max_health:
		var tween = create_tween()
		tween.tween_property(health_bar, "modulate", Color.RED, 0.1)
		tween.tween_property(health_bar, "modulate", Color.WHITE, 0.2)

func update_health_color():
	var health_percent = float(current_health) / float(max_health)
	
	if health_percent > 0.7:
		health_bar.tint_progress = Color.GREEN
	elif health_percent > 0.4:
		health_bar.tint_progress = Color.YELLOW
	elif health_percent > 0.2:
		health_bar.tint_progress = Color.ORANGE
	else:
		health_bar.tint_progress = Color.RED

func get_remaining_hits() -> int:
	return int(current_health / health_per_hit)

func show_health_bar():
	visible = true

func hide_health_bar():
	visible = false

# Optional: Smooth health bar animation
func set_health_smooth(new_health: int, duration: float = 0.3):
	var tween = create_tween()
	tween.tween_method(_animate_health_bar, current_health, new_health, duration)
	current_health = new_health

func _animate_health_bar(value: float):
	health_bar.value = value
	update_health_color()
