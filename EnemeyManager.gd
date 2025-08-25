extends Node

signal all_enemies_defeated()

var enemy_count: int = 0

func _ready():
	add_to_group("enemy_manager")
	print("EnemyManager ready - Parent: ", get_parent().name)
	
	await get_tree().process_frame
	find_all_enemies()

func find_all_enemies():
	enemy_count = 0
	
	# Find all enemies in the scene
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemy_count = enemies.size()
	
	print("Found ", enemy_count, " enemies")
	
	if enemy_count == 0:
		all_enemies_defeated.emit()
		return
	
	for enemy in enemies:
		if enemy.has_signal("enemy_died"):
			if not enemy.enemy_died.is_connected(_on_enemy_died):
				enemy.enemy_died.connect(_on_enemy_died)
		else:
			if not enemy.tree_exiting.is_connected(_on_enemy_died.bind()):
				enemy.tree_exiting.connect(_on_enemy_died.bind())

func register_enemy(enemy):
	enemy_count += 1
	print("New enemy registered. Total enemies: ", enemy_count)
	
	if enemy.has_signal("enemy_died"):
		if not enemy.enemy_died.is_connected(_on_enemy_died):
			enemy.enemy_died.connect(_on_enemy_died)
	else:
		if not enemy.tree_exiting.is_connected(_on_enemy_died.bind()):
			enemy.tree_exiting.connect(_on_enemy_died.bind())

func _on_enemy_died():
	enemy_count -= 1
	print("Enemy defeated! Remaining: ", enemy_count)
	
	if enemy_count <= 0:
		print("All enemies defeated! Victory!")
		all_enemies_defeated.emit()
