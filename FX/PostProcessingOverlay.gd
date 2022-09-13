# MIT License
# Copyright (c) 2022 BIFRACTAL - Florian Roth

extends Panel

export var water_level : float = 0.0
export var water_level_cam_threshold : float = 1.0
export var player_path : NodePath = ""

var camera : Camera = null
var player : KinematicBody = null

# Ready
func _ready():
	camera = get_viewport().get_camera()
	player = get_node(player_path)

# Process
func _process(_delta):
	if (camera == null || player == null):
		return
	
	if (!player.is_near_water()):
		hide()
		return
	
	show()
	
	# Apply Shader Params
	var shader_material = material as ShaderMaterial
	shader_material.set_shader_param("water_transition_mask", player.get_water_transition_mask())
	shader_material.set_shader_param("water_depth_mask", player.get_water_depth_mask())
