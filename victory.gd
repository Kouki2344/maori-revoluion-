extends CanvasLayer

@onready var victory_label = $Label
@onready var restart_button = $RestartButton

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# 连接到GameManager的胜利信号
	GameManager.all_enemies_defeated.connect(show_victory)

func show_victory():
	print("显示胜利界面！")
	visible = true
	get_tree().paused = true
	
	# 简单的淡入效果

	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1.0)

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().paused = false
	# 切换到主菜单场景
	# get_tree().change_scene_to_file("res://main_menu.tscn")
	get_tree().reload_current_scene()  # 临时回退
