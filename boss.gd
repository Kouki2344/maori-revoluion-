#This code was made by Jason
extends CharacterBody2D

@export var speed: float = 150.0
@export var max_health: int = 500
var health: int = max_health
@export var attack_damage: int = 30
@export var attack_range: float = 80.0
@export var attack_cooldown: float = 2.0
@export var detection_range: float = 200.0

# Enemy specific data
@export var enemy_scene: PackedScene  
@export var spawn_count: int = 3
@export var spawn_interval: float = 30.0
@export var spawn_radius: float = 150.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var detection_area: Area2D = $DetectionRange
@onready var hitbox: Area2D = $Hitbox

var player_ref: Node = null
var can_attack: bool = true
var is_attacking: bool = false
var is_chasing: bool = false
var is_active: bool = false  

enum State {IDLE, CHASING, ATTACKING}
var current_state: State = State.IDLE

func _ready():
	health = max_health
	add_to_group("enemies")
	add_to_group("boss")
	
	# Configure detection area
	if detection_area:
		var collision_shape = detection_area.get_node("CollisionShape2D")
		if collision_shape and collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = detection_range
	
	# Connect signals
	if detection_area:
		if not detection_area.body_entered.is_connected(_on_detection_range_body_entered):
			detection_area.body_entered.connect(_on_detection_range_body_entered)
	
	if hitbox:
		if not hitbox.area_entered.is_connected(_on_hitbox_area_entered):
			hitbox.area_entered.connect(_on_hitbox_area_entered)
	
	if attack_timer:
		if not attack_timer.timeout.is_connected(_on_attack_cooldown_timeout):
			attack_timer.timeout.connect(_on_attack_cooldown_timeout)

	deactivate_boss()

func _physics_process(delta):
	#Only process boss if active
	if !is_active or !player_ref or is_attacking:
		return
	
	match current_state:
		State.IDLE:
			handle_idle()
		State.CHASING:
			handle_chasing(delta)
		State.ATTACKING:
			velocity = Vector2.ZERO
	
	move_and_slide()

# Activate boss function 
func activate_boss():
	if is_active:
		return
	
	print("Boss activated!")
	is_active = true
	
	# Setup spawn timer 
	if spawn_timer:
		spawn_timer.wait_time = spawn_interval
		if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
			spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		spawn_timer.start()
	
	# Start in idle state
	change_state(State.IDLE)

# Deactivate boss function 
func deactivate_boss():
	is_active = false
	player_ref = null
	
	# Reset to idle state
	velocity = Vector2.ZERO
	if animation_player.has_animation("idle"):
		animation_player.play("idle")

func handle_idle():
	if animation_player.current_animation != "idle":
		animation_player.play("idle")
	
	# Check if player is in detection range
	if player_ref and global_position.distance_to(player_ref.global_position) < detection_range:
		change_state(State.CHASING)

func handle_chasing(delta):
	if animation_player.current_animation != "walk":
		animation_player.play("walk")
	
	var direction = (player_ref.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player_ref.global_position)
	
	velocity = direction * speed
	sprite.flip_h = direction.x < 0
	
	# Check attack range
	if distance_to_player <= attack_range and can_attack:
		change_state(State.ATTACKING)

func change_state(new_state: State):
	if current_state == new_state:
		return
	
	current_state = new_state
	
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			if animation_player.has_animation("idle"):
				animation_player.play("idle")
		State.CHASING:
			if animation_player.has_animation("walk"):
				animation_player.play("walk")
		State.ATTACKING:
			attack()

func attack():
	if not can_attack:
		change_state(State.CHASING)
		return
	
	can_attack = false
	is_attacking = true
	velocity = Vector2.ZERO
	
	if animation_player.has_animation("attack"):
		animation_player.play("attack")
		await animation_player.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	# Apply damage if player is still in range
	if player_ref and is_instance_valid(player_ref) and global_position.distance_to(player_ref.global_position) <= attack_range * 1.2:
		if player_ref.has_method("take_damage"):
			player_ref.take_damage(attack_damage)
	
	if attack_timer:
		attack_timer.start(attack_cooldown)
	else:
		await get_tree().create_timer(attack_cooldown).timeout
	
	is_attacking = false
	change_state(State.CHASING)

# Enemy Spawning Function
func spawn_enemies():
	if not enemy_scene or not is_active:
		return
	
	print("Boss spawning ", spawn_count, " enemies!")
	
	for i in range(spawn_count):
		var enemy = enemy_scene.instantiate()
		get_parent().add_child(enemy)
		
		# Calculate spawn position around boss
		var angle = randf() * 2 * PI
		var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
		enemy.global_position = global_position + offset
		
		# Optional: Make spawned enemies stronger
		if enemy.has_method("set_enhanced_stats"):
			enemy.set_enhanced_stats(1.5)  # 50% stronger

func take_damage(damage: int):
	# Only take damage if active
	if not is_active:
		return
	
	health -= damage
	health = max(0, health)
	
	# Visual effect
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	
	print("Boss took ", damage, " damage! Health: ", health, "/", max_health)
	
	if health <= 0:
		die()

func die():
	print("Boss defeated!")
	is_active = false
	
	# Stop spawning enemies
	if spawn_timer:
		spawn_timer.stop()
	
	# Disable collisions
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	if hitbox:
		hitbox.monitoring = false
	
	# Death effect
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	queue_free()

func _on_attack_cooldown_timeout():
	can_attack = true

func _on_spawn_timer_timeout():
	if is_active:
		spawn_enemies()
		if spawn_timer:
			spawn_timer.start()

func _on_detection_range_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body
		if not is_active:  
			activate_boss()
		else:
			change_state(State.CHASING)

func _on_hitbox_area_entered(area):
	if area.is_in_group("player_weapon") and is_active:
		var damage = area.damage if "damage" in area else 15
		take_damage(damage)
