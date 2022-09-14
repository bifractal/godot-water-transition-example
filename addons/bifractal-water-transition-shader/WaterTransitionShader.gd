# MIT License
# Copyright (c) 2022 BIFRACTAL - Florian Roth

extends Spatial

onready var viewport : Viewport = $Viewport
onready var camera : Camera = $Viewport/Camera
onready var render_mesh : MeshInstance = $Viewport/Camera/RenderMesh
onready var overlay : Panel = $PostProcessOverlay

# General Settings
export var water_level : float = 0.0
export var water_level_cam_threshold : float = 1.0

# Shader Settings (Defaults from post-processing shader!)
export var water_line_color : Color = Color("#1a4066")
export var underwater_color : Color = Color("#004040")
export var underwater_blur_lod : int = 2

var _main_camera : Camera = null
var _skip : bool = false

# Process
func _process(_delta):
	_skip = _main_camera.global_translation.y >= water_level_cam_threshold
	
	_apply_render_pass()
	
	if (_skip):
		hide()
		return
	
	show()
	
	# Apply Shader Params
	var shader_material = overlay.material as ShaderMaterial
	shader_material.set_shader_param("water_line_color", water_line_color)
	shader_material.set_shader_param("underwater_color", underwater_color)
	shader_material.set_shader_param("underwater_blur_lod", underwater_blur_lod)
	shader_material.set_shader_param("water_transition_mask", viewport.get_texture())

# Update Main Camera
func update_main_camera(main_camera: Camera):
	_main_camera = main_camera

# Apply Render Pass
func _apply_render_pass():
	
	# Update
	if (!_skip):
		
		# Water Transition Pass
		camera.visible = true
		render_mesh.visible = true
		viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
		viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
		
		_apply_water_transition_pass();
		
	# Skip
	else:
		
		# Water Transition Pass
		camera.visible = false
		render_mesh.visible = false
		viewport.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
		viewport.render_target_update_mode = Viewport.UPDATE_DISABLED

# Apply Water Transition Pass
func _apply_water_transition_pass():
	viewport.size = _main_camera.get_viewport().size
	
	camera.fov = _main_camera.fov
	camera.near = _main_camera.near
	camera.far = camera.near + 0.01
	camera.global_transform = _main_camera.global_transform
	
	render_mesh.translation.z = -(_main_camera.near + 0.001)
	
	var camera_position = _main_camera.global_translation
	var camera_direction_vector = -_main_camera.global_transform.basis.z
	
	var water_pp_mat = render_mesh.get_active_material(0)
	water_pp_mat.set_shader_param("water_level", water_level)
	water_pp_mat.set_shader_param("camera_near", _main_camera.near)
	water_pp_mat.set_shader_param("camera_position", camera_position)
	water_pp_mat.set_shader_param("camera_direction_vector", camera_direction_vector)
