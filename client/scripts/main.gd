extends Node3D

var remote_players = {}
var player_scene = preload("res://scenes/player.tscn")
var remote_player_scene = preload("res://scenes/remote_player.tscn")

@onready var network = get_node("/root/NetworkManager")
@onready var login_ui = $CanvasLayer/LoginUI
@onready var hud = $CanvasLayer/HUD
@onready var chat_container = $CanvasLayer/HUD/ChatContainer
@onready var chat_log = $CanvasLayer/HUD/ChatContainer/ChatLog
@onready var chat_input = $CanvasLayer/HUD/ChatContainer/ChatInput
@onready var username_input = $CanvasLayer/LoginUI/VBoxContainer/UsernameInput
@onready var connect_button = $CanvasLayer/LoginUI/VBoxContainer/ConnectButton
@onready var status_label = $CanvasLayer/LoginUI/VBoxContainer/StatusLabel

var local_player = null

func _ready():
	# Connecter les signaux réseau
	network.connected_to_server.connect(_on_connected_to_server)
	network.player_joined.connect(_on_player_joined)
	network.player_left.connect(_on_player_left)
	network.player_moved.connect(_on_player_moved)
	network.chat_message.connect(_on_chat_message)

	# Connecter les signaux UI
	connect_button.pressed.connect(_on_connect_button_pressed)
	chat_input.text_submitted.connect(_on_chat_submitted)

	# Afficher le menu de connexion
	login_ui.visible = true
	hud.visible = false
	chat_input.visible = false

func _on_connect_button_pressed():
	var username = username_input.text.strip_edges()

	if username.is_empty():
		status_label.text = "Entrez un nom d'utilisateur"
		return

	status_label.text = "Connexion..."
	connect_button.disabled = true

	var success = await network.connect_to_server(username)

	if not success:
		status_label.text = "Échec de la connexion"
		connect_button.disabled = false

func _on_connected_to_server():
	print("Connecté! Création du joueur...")

	# Cacher le menu de connexion
	login_ui.visible = false
	hud.visible = true

	# Créer le joueur local
	local_player = player_scene.instantiate()
	add_child(local_player)
	local_player.global_position = Vector3(0, 1, 0)
	local_player.set_player_name(username_input.text)

	add_chat_message("Système", "Bienvenue dans le monde médiéval!")

func _on_player_joined(player_data):
	var player_id = player_data.playerId
	var username = player_data.username
	var pos = player_data.position
	var rot = player_data.rotation

	print("Joueur rejoint: ", username, " (ID: ", player_id, ")")

	# Créer le joueur distant
	var remote = remote_player_scene.instantiate()
	add_child(remote)
	remote.global_position = Vector3(pos.x, pos.y, pos.z)
	remote.rotation.y = rot
	remote.set_player_name(username)

	# Assigner une couleur aléatoire
	var color = Color(randf(), randf(), randf())
	remote.set_color(color)

	remote_players[player_id] = remote

	add_chat_message("Système", username + " a rejoint le jeu")

func _on_player_left(player_id):
	if player_id in remote_players:
		var remote = remote_players[player_id]
		remote.queue_free()
		remote_players.erase(player_id)
		print("Joueur parti: ID ", player_id)

func _on_player_moved(player_id, position, rotation):
	if player_id in remote_players:
		remote_players[player_id].update_transform(position, rotation)

func _on_chat_message(username, text):
	add_chat_message(username, text)

func _on_chat_submitted(text: String):
	if text.strip_edges().is_empty():
		return

	network.send_chat(text)
	chat_input.text = ""
	chat_input.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func add_chat_message(username: String, text: String):
	chat_log.text += "[" + username + "] " + text + "\n"

	# Limiter le nombre de lignes
	var lines = chat_log.text.split("\n")
	if lines.size() > 50:
		lines = lines.slice(-50)
		chat_log.text = "\n".join(lines)

func _input(event):
	# Ouvrir le chat avec Enter
	if event.is_action_pressed("ui_accept") and not chat_input.visible:
		chat_input.visible = true
		chat_input.grab_focus()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()

	# Fermer le chat avec Echap
	elif event.is_action_pressed("ui_cancel") and chat_input.visible:
		chat_input.visible = false
		chat_input.text = ""
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
