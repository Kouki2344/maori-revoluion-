extends CanvasLayer

@onready var panel = $Panel
@onready var label = $Panel/Label

func _ready():
	#Popup at random position on the screen
	var viewport_size = get_viewport().get_visible_rect().size
	panel.position = Vector2(
		randf_range(50, viewport_size.x - panel.size.x - 50),
		randf_range(50, viewport_size.y - panel.size.y - 50)
	)
	
	#Auto remove after 5 seconds
	await get_tree().create_timer(5.0).timeout
	queue_free()
