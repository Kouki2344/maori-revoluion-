extends CharacterBody2D

@export var speed: float = 150.0
@export var max_health: int = 100
var health: int = max_health
var hit_count: int = 0  
@export var death_threshold_range: Vector2i = Vector2i(3, 5)
var death_threshold: int
@export var attack_damage: int = 10
@export var attack_range: float = 50
@export var attack_cooldown: float = 1.0
@export var detection_range: float = 250.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var attack_range_area: Area2D = $AttackRange
@onready var detection_area: Area2D = $DetectionRange
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D if has_node("NavigationAgent2D") else null

var player_ref: Node = null
var can_attack: bool = true
var is_attacking: bool = false
var is_chasing: bool = false

func _ready():
	death_threshold = randi_range(death_threshold_range.x, death_threshold_range.y)
	print("Enemy spawned! Will die after ", death_threshold, " hits")
	
	# Configure collision shapes
	if attack_range_area:
		attack_range_area.get_node("CollisionShape2D").shape.radius = attack_range
	if detection_area:
		detection_area.get_node("CollisionShape2D").shape.radius = detection_range
	
	# Connect signals if not done in editor
	if attack_range_area and not attack_range_area.body_entered.is_connected(_on_attack_range_body_entered):
		attack_range_area.body_entered.connect(_on_attack_range_body_entered)
	if detection_area and not detection_area.body_entered.is_connected(_on_detection_range_body_entered):
		detection_area.body_entered.connect(_on_detection_range_body_entered)

func _physics_process(delta):
	if !player_ref or is_attacking:
		return
	
	var direction: Vector2
	var distance_to_player: float
	
	if nav_agent:
		# Pathfinding movement
		nav_agent.target_position = player_ref.global_position
		direction = (nav_agent.get_next_path_position() - global_position).normalized()
		distance_to_player = global_position.distance_to(player_ref.global_position)
	else:
		# Simple movement
		direction = (player_ref.global_position - global_position).normalized()
		distance_to_player = global_position.distance_to(player_ref.global_position)
	
	if distance_to_player < detection_range:
		if distance_to_player > attack_range + 10:  # Small buffer to prevent jitter
			is_chasing = true
			velocity = direction * speed
			
			if animation_player and animation_player.has_animation("walk"):
				animation_player.play("walk")
		else:
			is_chasing = false
			velocity = Vector2.ZERO
			if animation_player and animation_player.has_animation("idle"):
				animation_player.play("idle")
			
			if can_attack:
				attack()
		
		move_and_slide()
		
		# Face movement direction (only flip horizontally)
		if direction.x != 0:
			$Sprite2D.flip_h = direction.x > 0

func attack():
	if !can_attack or !player_ref or !is_instance_valid(player_ref):
		return
	
	can_attack = false
	is_attacking = true
	
	# Play attack animation based on direction
	var attack_dir = (player_ref.global_position - global_position).normalized()
	var attack_anim = "attack_side"  # Default
	
	if abs(attack_dir.y) > abs(attack_dir.x):  # Vertical attack
		attack_anim = "attack_down" if attack_dir.y > 0 else "attack_up"
	
	if animation_player and animation_player.has_animation(attack_anim):
		animation_player.play(attack_anim)
		await animation_player.animation_finished
	
	# Deal damage if still in range
	if player_ref and is_instance_valid(player_ref):
		var current_distance = global_position.distance_to(player_ref.global_position)
		if current_distance <= attack_range * 1.2:  # Slightly larger range for player movement
			player_ref.take_damage(attack_damage)
	
	$AttackCooldown.start(attack_cooldown)
	is_attacking = false

func take_damage(damage):
	hit_count += 1
	health -= damage
	
	# Visual feedback
	$Sprite2D.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color.WHITE
	
	print("Enemy hit! (", hit_count, "/", death_threshold, ")")
	
	if hit_count >= death_threshold:
		die()

func die():
	# Play death animation if available
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")
		await animation_player.animation_finished
	else:
		# Fallback death effect
		$Sprite2D.modulate = Color.RED
		var tween = create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.5)
		await tween.finished
	
	queue_free()

func _on_detection_range_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_ref = body
		print("Player detected!")

func _on_detection_range_body_exited(body):
	if body == player_ref:
		player_ref = null
		print("Player lost")

func _on_attack_range_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		if can_attack and not is_attacking:
			attack()

func _on_attack_cooldown_timeout():
	can_attack = true
