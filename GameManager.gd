extends Node

#Signal enemy
signal all_enemies_defeated()

var enemy_count: int = 0

func _ready():
	add_to_group("game_manager")
	await get_tree().process_frame
	find_all_enemies()

func find_all_enemies():
	enemy_count = get_tree().get_nodes_in_group("enemies").size()
	
	if enemy_count == 0:
		# Emit signal if no enemies found
		all_enemies_defeated.emit()

func register_enemy(enemy):
	enemy_count += 1
	
	if enemy.has_signal("enemy_died"):
		if not enemy.enemy_died.is_connected(_on_enemy_died):
			enemy.enemy_died.connect(_on_enemy_died)
	
func _on_enemy_died():
	enemy_count -= 1
	
	if enemy_count <= 0:
		all_enemies_defeated.emit()
