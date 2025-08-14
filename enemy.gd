extends CharacterBody2D

@export var speed: float = 150.0
@export var max_health: int = 100
var health: int = max_health
var hit_count: int = 0  
@export var death_threshold_range: Vector2i = Vector2i(3, 5)
var death_threshold: int
@export var attack_damage: int = 10
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 1.0
@export var detection_range: float = 200.0

var player_ref: Node = null
var can_attack: bool = true

func _ready():
	# Initialize random death threshold when enemy spawns
	death_threshold = randi_range(death_threshold_range.x, death_threshold_range.y)
	print("Enemy spawned! Will die after ", death_threshold, " hits")

func _physics_process(delta):
	if player_ref and is_instance_valid(player_ref):
		var direction = (player_ref.global_position - global_position).normalized()
		var distance_to_player = global_position.distance_to(player_ref.global_position)
		
		if distance_to_player < detection_range:
			if distance_to_player > attack_range:
				velocity = direction * speed
			else:
				velocity = Vector2.ZERO
				if can_attack:
					attack()
			
			move_and_slide()
			
			if direction.x != 0:
				$Sprite2D.flip_h = direction.x > 0

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
	$Sprite2D.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()

func attack():
	if !can_attack or !player_ref or !is_instance_valid(player_ref):
		return
	
	can_attack = false
	$AttackCooldown.start(attack_cooldown)
	
	if global_position.distance_to(player_ref.global_position) <= attack_range:
		player_ref.take_damage(attack_damage)

func _on_detection_range_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_ref = body

func _on_detection_range_body_exited(body):
	if body == player_ref:
		player_ref = null

func _on_attack_cooldown_timeout():
	can_attack = true
