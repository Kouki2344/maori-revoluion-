extends CharacterBody2D

@export var speed: float = 150.0
@export var max_health: int = 1000
@export var melee_damage: int = 30
@export var melee_range: float = 80.0
@export var attack_cooldown: float = 2.0
@export var detection_range: float = 500.0

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var attack_timer = $AttackTimer if has_node("AttackTimer") else null
@onready var hitbox = $Hitbox  # ADD THIS - for player to attack boss
@onready var detection_area = $DetectionRange  # ADD THIS - to detect player

var health: int
var player: Node
var can_melee_attack: bool = true
