# MIT License
# Copyright (c) 2022 BIFRACTAL - Florian Roth

extends KinematicBody

onready var camera : Camera = $Camera

onready var water_tp_viewport : Viewport = $WaterTransitionPass_Viewport
onready var water_tp_camera : Camera = $WaterTransitionPass_Viewport/WaterTransitionPass_Camera
onready var water_tp_rt : MeshInstance = $WaterTransitionPass_Viewport/WaterTransitionPass_Camera/WaterTransitionPass_RT

onready var water_dp_viewport : Viewport = $WaterDepthPass_Viewport
onready var water_dp_camera : Camera = $WaterDepthPass_Viewport/WaterDepthPass_Camera
onready var water_dp_rt : MeshInstance = $WaterDepthPass_Viewport/WaterDepthPass_Camera/WaterDepthPass_RT

export var water_level = 0.0
export var water_level_cam_threshold = 1.0
export var mouse_sensitivity = 0.15
export var walk_speed = 600.0
export var gravity = 19.62

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

# Process
func _process(_delta):
	_apply_render_passes()

# Physics Process
func _physics_process(delta):
	_apply_movement(delta)

# Is Near Water?
func is_near_water():
	return global_translation.y < water_level + water_level_cam_threshold

# Get Water Transition Mask
func get_water_transition_mask():
	return water_tp_viewport.get_texture()

# Get Water Depth Mask
func get_water_depth_mask():
	var t = water_dp_viewport.get_texture()
	t.flags = Texture.FLAG_FILTER | Texture.FLAG_MIPMAPS
	return t

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

# Apply Render Passes
func _apply_render_passes():
	
	# Update
	if (is_near_water()):
		
		# Water Transition Pass
		water_tp_camera.visible = true
		water_tp_rt.visible = true
		
		_apply_water_transition_pass()
	
		# Water Depth Pass
		water_dp_camera.visible = true
		water_dp_rt.visible = true
		
		_apply_water_depth_pass()
	
	# Skip
	else:
		
		# Water Transition Pass
		water_tp_camera.visible = false
		water_tp_rt.visible = false
		
		# Water Depth Pass
		water_dp_camera.visible = false
		water_dp_rt.visible = false

# Apply Water Transition Pass
func _apply_water_transition_pass():
	water_tp_viewport.size = camera.get_viewport().size
	
	water_tp_camera.fov = camera.fov
	water_tp_camera.near = camera.near
	water_tp_camera.far = water_tp_camera.near + 0.01
	water_tp_camera.global_transform = camera.global_transform
	
	water_tp_rt.translation.z = -(camera.near + 0.001)
	
	var camera_position = camera.global_translation
	var camera_direction_vector = -camera.global_transform.basis.z
	
	var water_pp_mat = water_tp_rt.get_active_material(0)
	water_pp_mat.set_shader_param("camera_near", camera.near)
	water_pp_mat.set_shader_param("camera_position", camera_position)
	water_pp_mat.set_shader_param("camera_direction_vector", camera_direction_vector)

# Apply Water Depth Pass
func _apply_water_depth_pass():
	water_dp_viewport.size = camera.get_viewport().size * 0.125 # LOD 3 ?
	
	water_dp_camera.fov = camera.fov
	water_dp_camera.near = camera.near
	water_dp_camera.far = camera.far
	water_dp_camera.global_transform = camera.global_transform
	
	water_dp_rt.translation.z = -(camera.near + 0.001)
