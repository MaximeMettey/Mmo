extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_rotation = Vector2.ZERO
var last_position = Vector3.ZERO
var last_rotation = 0.0
var update_timer = 0.0
var update_interval = 0.05  # Envoyer la position toutes les 50ms

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var network = get_node("/root/NetworkManager")
@onready var name_label = $NameLabel3D

func _ready():
	# Capturer la souris
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Positionner la caméra
	camera_pivot.rotation.x = -0.5

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotation horizontale (Y axis)
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Rotation verticale (X axis) - limitée
		camera_rotation.y -= event.relative.y * mouse_sensitivity
		camera_rotation.y = clamp(camera_rotation.y, -1.4, 1.4)
		camera_pivot.rotation.x = camera_rotation.y

	# Libérer/capturer la souris avec Echap
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Gravité
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Saut
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Mouvement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	# Envoyer la position au serveur
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0

		# Vérifier si la position ou rotation a changé
		var current_rotation = rotation.y
		if global_position.distance_to(last_position) > 0.01 or abs(current_rotation - last_rotation) > 0.01:
			if network.is_connected:
				network.send_move(global_position, current_rotation)
			last_position = global_position
			last_rotation = current_rotation

func set_player_name(player_name: String):
	if name_label:
		name_label.text = player_name
