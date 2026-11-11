extends CharacterBody2D
class_name EnemyFighter

@export var max_health: int = 60
var current_health: int
@export var speed: float = 90.0

@onready var visuals: Node2D = $Visuals

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health

func _physics_process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var target = players[0]
		var diff = target.global_position - global_position
		if diff.length() > 60.0:
			var move_dir = diff.normalized()
			velocity = move_dir * speed
		else:
			velocity = Vector2.ZERO
	move_and_slide()

func take_hit(amount: int, hit_dir: float) -> void:
	current_health -= amount
	velocity.x = hit_dir * 250.0
	if current_health <= 0:
		queue_free()
