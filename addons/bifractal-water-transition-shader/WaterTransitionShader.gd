# MIT License
# Copyright (c) 2022 BIFRACTAL - Florian Roth

extends Spatial
class_name WaterTransitionShader

# General Settings
export var water_level					: float = 0.0
export var water_level_cam_threshold	: float = 1.0

# Shader Settings (Defaults from post-processing shader!)
export var water_line_color		: Color = Color("#1a4066")
export var underwater_color		: Color = Color("#004040")
export var underwater_blur_lod	: int	= 2

var scene_inst = null

# Ready
func _ready():
	var scene = load("res://addons/bifractal-water-transition-shader/WaterTransitionShader.tscn")
	scene_inst = scene.instance()
	
	if (scene_inst == null):
		push_warning("Could not instantiate water transition shader scene.")
	
	# Forward Script Settings
	scene_inst.water_level = water_level
	scene_inst.water_level_cam_threshold = water_level_cam_threshold
	scene_inst.water_line_color = water_line_color
	scene_inst.underwater_color = underwater_color
	scene_inst.underwater_blur_lod = underwater_blur_lod
	
	call_deferred("replace_by", scene_inst)

# Update Main Camera
func update_main_camera(main_camera: Camera):
	if (scene_inst != null):
		scene_inst.update_main_camera(main_camera)
