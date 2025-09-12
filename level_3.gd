extends Node2D  

@export var rest_notification_scene: PackedScene
var rest_timer: Timer

func _ready():
	setup_rest_notifier()

#Popup every 10 mins
func setup_rest_notifier():
	rest_timer = Timer.new()
	rest_timer.wait_time = 600
	rest_timer.autostart = true
	rest_timer.timeout.connect(_show_rest_notification)
	add_child(rest_timer)

func _show_rest_notification():
	if rest_notification_scene:
		var notification = rest_notification_scene.instantiate()
		get_tree().root.add_child(notification)
