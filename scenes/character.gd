extends CharacterBody2D

enum States { IDLE, MOVE }

@export var speed := 100.0
@export var acceleration := 1000.0
@export var decceleration := 1000.0
@export var aim_deadzone := 0.2

@export var roll_speed := 200.0


var _direction := Vector2.DOWN
var _input_direction := Vector2.ZERO

var _current_anim := "Idle"
var _treshhold := 0.01

@onready var _anim_tree : AnimationTree = $AnimationTree
@onready var _state_machine : AnimationNodeStateMachinePlayback = _anim_tree.get("parameters/playback")


func _unhandled_input(event) -> void :
	if event.is_action_pressed("attack"):
		if _state_machine.is_playing() && _current_anim == "Slash":
			_play_animation("Slash2")
		elif _state_machine.is_playing() && _current_anim == "Slash2":
			_play_animation("Slash3")
		else:
			_play_animation("Slash")
		
		_set_blend(_direction)
	
	if event.is_action_pressed("dodge"):
		_play_animation("Roll")
		_set_blend(_direction)


func _physics_process(delta: float) -> void:
	_current_anim = _state_machine.get_current_node()
	
	if _current_anim.begins_with("Slash"):
		return
	
	_input_direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).limit_length(1.0)
	
	if _current_anim == "Roll":
		_roll(delta, _input_direction)
		return
	
	if _input_direction:
		velocity += _input_direction * acceleration * delta
		velocity = velocity.limit_length(speed * _input_direction.length())
		if _input_direction.length() > aim_deadzone:
			_direction = _input_direction.normalized()
		_play_animation("Move")
		_set_blend(_input_direction, _input_direction.length())
	else:
		velocity = velocity.move_toward(Vector2.ZERO, decceleration * delta)
		_play_animation("Idle")
		_set_blend(_direction)
	
	move_and_slide()


func _roll(delta: float, direction) -> void:
	velocity += direction * acceleration * delta
	velocity = velocity.limit_length(roll_speed * direction.length())
	move_and_slide()


func _play_animation(animation: String) -> void:
	if animation == _current_anim:
		return
	
	_current_anim = animation
	_state_machine.travel(_current_anim)


func _set_blend(direction: Vector2, anim_speed = 1.0) -> void:
	if direction.length() > _treshhold:
		_anim_tree.set("parameters/" + _current_anim + "/blend_position", direction)

