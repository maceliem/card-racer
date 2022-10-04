extends Node

const defaultPort = 28960
const maxClients = 8

var server = null
var client = null

var ipAddress = "127.0.0.1"


func _ready():
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")


func createServer():
	print("creating server")

	server = NetworkedMultiplayerENet.new()
	server.create_server(defaultPort, maxClients)
	get_tree().set_network_peer(server)
	Global.hostID = get_tree().get_network_unique_id()


func joinServer():
	print("joining server")

	client = NetworkedMultiplayerENet.new()
	client.create_client(ipAddress, defaultPort)
	get_tree().set_network_peer(client)


func _connected_to_server():
	print("connected_to_server")


func _server_disconnected():
	print("server_disconnected")


func _connection_failed():
	print("connection_failed")
	reset_network_connection()


func _network_peer_connected(id):
	print("network_peer_connected " + str(id))
	Global.hostID = id


func reset_network_connection():
	if get_tree().has_network_peer():
		get_tree().network_peer = null
