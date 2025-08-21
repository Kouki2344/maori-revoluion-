extends CharacterBody2D

@export var speed = 220
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

# Combat variables
@export var max_health: int = 100
var health: int = max_health
var hit_count: int = 0
const PLAYER_DEATH_THRESHOLD: int = 10  # Die after 10 hits
@export var attack_damage: int = 20
@export var attack_range: float = 100.0
@export var attack_cooldown: float = 0.5  

@onready var attack_cooldown_timer = $AttackCooldown
var can_attack: bool = true
var nearby_enemies: Array = []

func _physics_process(delta):
	# Movement (always allowed, even while attacking)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		velocity = input_dir * speed
		if input_dir.x != 0:
			sprite.flip_h = input_dir.x < 0
		if not animation_player.current_animation == "Attack":  # Only play Walk if not attacking
			animation_player.play("Walk")
	else:
		velocity = Vector2.ZERO
		if not animation_player.current_animation == "Attack":  # Only play Idle if not attacking
			animation_player.play("Idle")
	move_and_slide()

	# Attack on E key press or left mouse click
	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

func attack():
	if not can_attack:
		return
	
	can_attack = false
	animation_player.play("Attack")  # Play attack animation
	await animation_player.animation_finished  # Wait for full animation
	
	# Apply damage after animation
	for enemy in nearby_enemies:
		if global_position.distance_to(enemy.global_position) <= attack_range:
			enemy.take_damage(attack_damage)
	
	# Attack cooldown
	attack_cooldown_timer.start(attack_cooldown)

func _on_attack_cooldown_timeout():
	can_attack = true

# Enemy detection 
func _on_attack_range_body_entered(body):
	if body.is_in_group("enemies"):
		nearby_enemies.append(body)

func _on_attack_range_body_exited(body):
	if body.is_in_group("enemies"):
		nearby_enemies.erase(body)

# Damage & Death 
func take_damage(damage):
	hit_count += 1
	health -= damage
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	print("Player hit! (", hit_count, "/", PLAYER_DEATH_THRESHOLD, ")")
	if hit_count >= PLAYER_DEATH_THRESHOLD:
		die()

func die():
	sprite.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()
