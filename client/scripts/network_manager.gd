extends Node

signal connected_to_server
signal disconnected_from_server
signal player_joined(player_data)
signal player_left(player_id)
signal player_moved(player_id, position, rotation)
signal chat_message(username, text)

var socket: WebSocketPeer
var server_url = "ws://localhost:8080"
var is_connected = false
var player_id = -1

func _ready():
	socket = WebSocketPeer.new()

func connect_to_server(username: String):
	print("Connexion au serveur: ", server_url)
	var err = socket.connect_to_url(server_url)
	if err != OK:
		print("Erreur de connexion: ", err)
		return false

	# Attendre la connexion
	await get_tree().create_timer(0.5).timeout

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		print("Connecté au serveur!")
		is_connected = true

		# Envoyer le message de join
		send_message({
			"type": "join",
			"username": username
		})

		connected_to_server.emit()
		return true
	else:
		print("Échec de la connexion")
		return false

func _process(_delta):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.poll()

		# Recevoir les messages
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet()
			var json_str = packet.get_string_from_utf8()
			var json = JSON.new()
			var error = json.parse(json_str)

			if error == OK:
				var message = json.data
				handle_message(message)
			else:
				print("Erreur parsing JSON: ", error)

	elif socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		if is_connected:
			is_connected = false
			disconnected_from_server.emit()
			print("Déconnecté du serveur")

func handle_message(message: Dictionary):
	match message.get("type"):
		"joined":
			player_id = message.get("playerId")
			print("Vous avez rejoint le jeu! ID: ", player_id)

		"players_list":
			var players = message.get("players", [])
			for player in players:
				player_joined.emit(player)

		"player_joined":
			print("Nouveau joueur: ", message.get("username"))
			player_joined.emit(message)

		"player_left":
			player_left.emit(message.get("playerId"))

		"player_moved":
			var pos = message.get("position")
			var rot = message.get("rotation")
			player_moved.emit(
				message.get("playerId"),
				Vector3(pos.x, pos.y, pos.z),
				rot
			)

		"chat_message":
			chat_message.emit(message.get("username"), message.get("text"))

func send_message(message: Dictionary):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var json_str = JSON.stringify(message)
		socket.send_text(json_str)

func send_move(position: Vector3, rotation_y: float):
	send_message({
		"type": "move",
		"position": {
			"x": position.x,
			"y": position.y,
			"z": position.z
		},
		"rotation": rotation_y
	})

func send_chat(text: String):
	send_message({
		"type": "chat",
		"text": text
	})

func disconnect_from_server():
	socket.close()
	is_connected = false
