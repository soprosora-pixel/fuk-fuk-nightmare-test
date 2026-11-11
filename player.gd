extends CharacterBody2D
class_name PlayerFighter

@export var walk_speed_x: float = 240.0
@export var walk_speed_y: float = 140.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 980.0

@onready var visuals: Node2D = $Visuals
@onready var attack_area: Area2D = $Visuals/AttackArea

enum State { IDLE, MOVE, ATTACK, JUMP, HURT }
var current_state: State = State.IDLE

var pseudo_z_pos: float = 0.0
var pseudo_z_vel: float = 0.0
var is_airborne: bool = false
var combo_index: int = 0

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE, State.MOVE:
			handle_ground_movement(delta)
			handle_jump_input()
			handle_attack_input()
		State.JUMP:
			handle_air_movement(delta)
			handle_attack_input()
		State.ATTACK:
			velocity = velocity.move_toward(Vector2.ZERO, 800 * delta)

	if is_airborne:
		pseudo_z_vel += gravity * delta
		pseudo_z_pos += pseudo_z_vel * delta
		if pseudo_z_pos >= 0.0:
			pseudo_z_pos = 0.0
			pseudo_z_vel = 0.0
			is_airborne = false
			if current_state == State.JUMP:
				current_state = State.IDLE
		visuals.position.y = pseudo_z_pos

	move_and_slide()

func handle_ground_movement(delta: float) -> void:
	var dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	if dir != Vector2.ZERO:
		velocity.x = dir.x * walk_speed_x
		velocity.y = dir.y * walk_speed_y
		current_state = State.MOVE
		if dir.x != 0:
			visuals.scale.x = 1.0 if dir.x > 0 else -1.0
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed_x * 8 * delta)
		velocity.y = move_toward(velocity.y, 0, walk_speed_y * 8 * delta)
		current_state = State.IDLE

func handle_jump_input() -> void:
	if Input.is_action_just_pressed("ui_accept") and not is_airborne:
		is_airborne = true
		pseudo_z_vel = jump_velocity
		current_state = State.JUMP

func handle_air_movement(_delta: float) -> void:
	var dir_x := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = dir_x * (walk_speed_x * 0.8)

func handle_attack_input() -> void:
	if Input.is_action_just_pressed("attack"):
		current_state = State.ATTACK
		combo_index = (combo_index % 3) + 1
		if attack_area:
			attack_area.monitoring = true
		await get_tree().create_timer(0.2).timeout
		if attack_area:
			attack_area.monitoring = false
		current_state = State.IDLE
