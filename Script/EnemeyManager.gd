extends Node

signal all_enemies_defeated()
signal enemy_defeated_count_updated(count)
signal health_gain_triggered(amount)

#Track total kills for health system
var enemy_count: int = 0
var total_enemies_defeated: int = 0  

#Health gain system
const HEALTH_GAIN_THRESHOLD: int = 5
const HEALTH_GAIN_AMOUNT: int = 80

func _ready():
	add_to_group("enemy_manager")
	
	await get_tree().process_frame
	find_all_enemies()

#Reset counter when level starts
func find_all_enemies():
	enemy_count = 0
	total_enemies_defeated = 0  
	
	#Find all enemies in the scene
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemy_count = enemies.size()
	
	if enemy_count == 0:
		all_enemies_defeated.emit()
		return
	
	for enemy in enemies:
		connect_to_enemy_signals(enemy)

func register_enemy(enemy):
	enemy_count += 1
	
	connect_to_enemy_signals(enemy)

func connect_to_enemy_signals(enemy):
	if enemy.has_signal("enemy_died"):
		if not enemy.enemy_died.is_connected(_on_enemy_died):
			enemy.enemy_died.connect(_on_enemy_died)
	else:
		if not enemy.tree_exiting.is_connected(_on_enemy_died.bind()):
			enemy.tree_exiting.connect(_on_enemy_died.bind())

#Check enemy count
func _on_enemy_died():
	enemy_count -= 1
	total_enemies_defeated += 1 
	
	print("Enemy defeated! Remaining: ", enemy_count, " | Total defeated: ", total_enemies_defeated)
	
	#Emit signal for UI updates 
	enemy_defeated_count_updated.emit(total_enemies_defeated)
	
	#Check for health gain 
	check_health_gain()
	
	if enemy_count <= 0:
		print("All enemies defeated! Victory!")
		all_enemies_defeated.emit()

func check_health_gain():
	#Gain 80 health every 5 kills
	if total_enemies_defeated % HEALTH_GAIN_THRESHOLD == 0:
		health_gain_triggered.emit(HEALTH_GAIN_AMOUNT)

func get_enemy_count() -> int:
	return enemy_count

func get_total_defeated() -> int:
	return total_enemies_defeated

func get_kills_until_next_health() -> int:
	return HEALTH_GAIN_THRESHOLD - (total_enemies_defeated % HEALTH_GAIN_THRESHOLD)

func reset_counters():
	enemy_count = 0
	total_enemies_defeated = 0
