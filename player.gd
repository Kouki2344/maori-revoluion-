extends CharacterBody2D

@export var speed = 220
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
var defeat_menu: Node

#Player variables
@export var max_health: int = 200
var health: int = max_health
var hit_count: int = 0
const PLAYER_DEATH_THRESHOLD: int = 20
@export var attack_damage: int = 20
@export var attack_range: float = 100.0
@export var attack_cooldown: float = 0.5  

@onready var attack_cooldown_timer = $AttackCooldown
var can_attack: bool = true
var nearby_enemies: Array = []

#Health bar reference 
var health_bar: TextureProgressBar
var damage_per_hit: int

func _ready():
	#Calculate damage per hit
	damage_per_hit = max_health / PLAYER_DEATH_THRESHOLD
	defeat_menu = get_node("../DefeatMenu")
	
	#Initialize health
	health = max_health
	
	find_health_bar()
	
	#Setup health bar if found
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	#Add to player group
	add_to_group("player")
	
	connect_to_enemy_manager()

func connect_to_enemy_manager():
	var enemy_manager = get_tree().get_first_node_in_group("enemy_manager")
	if enemy_manager:
		if enemy_manager.has_signal("health_gain_triggered"):
			enemy_manager.health_gain_triggered.connect(gain_health_from_kills)

#Make sure healing doesen't go over maximum value
func gain_health_from_kills(amount: int):
	health += amount
	health = min(health, max_health)  
	
	#Update health bar
	if health_bar:
		health_bar.value = health

	show_health_gain_effect()

func show_health_gain_effect():
	#Healing green flash effect 
	sprite.modulate = Color.GREEN
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.5)

func find_health_bar():
	health_bar = get_node_or_null("HealthBar")
	if health_bar:
		return true

func create_fallback_health_bar():
	#Health bar path
	health_bar = TextureProgressBar.new()
	health_bar.name = "HealthBar"
	add_child(health_bar)

func _physics_process(delta):
	#Player movement and animation
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		velocity = input_dir * speed
		if input_dir.x != 0:
			sprite.flip_h = input_dir.x < 0
		if not animation_player.current_animation == "Attack":
			animation_player.play("Walk")
	else:
		velocity = Vector2.ZERO
		if not animation_player.current_animation == "Attack":
			animation_player.play("Idle")
	move_and_slide()

	#Attack input
	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

func attack():
	if not can_attack:
		return
	
	#Attack animation
	can_attack = false
	animation_player.play("Attack")
	await animation_player.animation_finished
	
	#Apply damage to nearby enemies
	for enemy in nearby_enemies:
		if global_position.distance_to(enemy.global_position) <= attack_range:
			enemy.take_damage(attack_damage)
	
	attack_cooldown_timer.start(attack_cooldown)

func _on_attack_cooldown_timeout():
	can_attack = true

#Enemy detection 
func _on_attack_range_body_entered(body):
	if body.is_in_group("enemies"):
		nearby_enemies.append(body)

func _on_attack_range_body_exited(body):
	if body.is_in_group("enemies"):
		nearby_enemies.erase(body)

#Damage function
func take_damage(damage_amount: int = 0):
	hit_count += 1
	health -= damage_per_hit
	health = max(0, health)
	
	#Health bar blood reduction
	if health_bar:
		health_bar.value = health
	
	#Flash effect
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	
	#Output message 
	print("Player hit! Health: ", health)
	
	if health <= 0:
		die()

#Death effect
func die():
	print("Player died!")
	sprite.modulate = Color.RED
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	
	if health_bar:
		tween.parallel().tween_property(health_bar, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	
	#Show defeat menu
	if defeat_menu:
		defeat_menu.show_menu()
	
	queue_free()
