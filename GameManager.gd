# GameManager.gd - Complete version
extends Node

# SIGNAL DEFINITION - MUST BE AT THE TOP
signal all_enemies_defeated()

var enemy_count: int = 0

func _ready():
	add_to_group("game_manager")
	print("GameManager ready")
	await get_tree().process_frame
	find_all_enemies()

func find_all_enemies():
	enemy_count = get_tree().get_nodes_in_group("enemies").size()
	print("Found ", enemy_count, " enemies")
	
	if enemy_count == 0:
		# Emit signal if no enemies found
		all_enemies_defeated.emit()

func register_enemy(enemy):
	enemy_count += 1
	print("Enemy registered. Total: ", enemy_count)
	
	if enemy.has_signal("enemy_died"):
		if not enemy.enemy_died.is_connected(_on_enemy_died):
			enemy.enemy_died.connect(_on_enemy_died)
	else:
		print("Enemy doesn't have enemy_died signal")

func _on_enemy_died():
	enemy_count -= 1
	print("Enemy died. Remaining: ", enemy_count)
	
	if enemy_count <= 0:
		print("ALL ENEMIES DEFEATED! Emitting victory signal...")
		all_enemies_defeated.emit()
