extends CharacterBody3D

var target_position = Vector3.ZERO
var target_rotation = 0.0
var interpolation_speed = 10.0

@onready var name_label = $NameLabel3D
@onready var mesh = $MeshInstance3D

func _ready():
	target_position = global_position
	target_rotation = rotation.y

func _physics_process(delta):
	# Interpoler la position
	global_position = global_position.lerp(target_position, interpolation_speed * delta)

	# Interpoler la rotation
	rotation.y = lerp_angle(rotation.y, target_rotation, interpolation_speed * delta)

func update_transform(pos: Vector3, rot: float):
	target_position = pos
	target_rotation = rot

func set_player_name(player_name: String):
	if name_label:
		name_label.text = player_name

func set_color(color: Color):
	if mesh and mesh.get_surface_override_material_count() > 0:
		var mat = mesh.get_surface_override_material(0)
		if mat:
			mat.albedo_color = color
