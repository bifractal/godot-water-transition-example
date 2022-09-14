# MIT License
# Copyright (c) 2022 BIFRACTAL - Florian Roth

extends KinematicBody

onready var camera : Camera	= $Camera

export var water_level					= 0.0
export var water_level_cam_threshold	= 1.0
export var mouse_sensitivity			= 0.15
export var walk_speed					= 600.0
export var gravity						= 19.62

var movement_velocity = Vector3(0.0, 0.0, 0.0)

# Ready
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Input
func _input(event):
	
	# Mouse Motion Event
	if (event is InputEventMouseMotion):
		var mouse_motion_event = event as InputEventMouseMotion
		
		var relative = mouse_motion_event.get_relative();
		var rot_x = -deg2rad(relative.y * mouse_sensitivity);
		var rot_y = -deg2rad(relative.x * mouse_sensitivity);
		
		camera.rotate_x(rot_x)
		rotate_y(rot_y)
		
		# Clamp camera's vertical rotation.
		var cam_rot = camera.get_rotation_degrees();
		cam_rot.x = clamp(cam_rot.x, -90.0, 90.0);
		camera.set_rotation_degrees(cam_rot);

# Physics Process
func _physics_process(delta):
	_apply_movement(delta)

# Apply Movement
func _apply_movement(delta):
	var forward_vec = -transform.basis.z
	var left_vec = -transform.basis.x
	
	var forward_accel = 0.0
	var left_accel = 0.0
	
	movement_velocity = Vector3(0.0, movement_velocity.y, 0.0)
	
	if (Input.is_action_pressed("player_walk_forward")):
		forward_accel = walk_speed * delta
	
	if (Input.is_action_pressed("player_walk_backwards")):
		forward_accel = -walk_speed * delta
	
	if (Input.is_action_pressed("player_walk_left")):
		left_accel = walk_speed * delta
	
	if (Input.is_action_pressed("player_walk_right")):
		left_accel = -walk_speed * delta
		
	movement_velocity += forward_vec * forward_accel
	movement_velocity += left_vec * left_accel
		
	var vel = move_and_slide_with_snap(movement_velocity, Vector3.UP, Vector3.UP, true, 64, deg2rad(65.0), true)
	var vel_y = vel.y
	
	if (!is_on_floor()):
		movement_velocity.y += -gravity * delta
	else:
		movement_velocity.y = vel_y
