extends Node2D

var list_name= ["solo", "warrior", "coder", "yolo" ]
var player_name := ""
const PORT = 27015
const MAX_PLAYERS = 3
export var ip : String = "localhost"
var nb_pl:=0
onready var _player = preload("res://prefabs/player.tscn")




func _ready() -> void:
	pass
#	get_tree().connect("network_peer_connected",    self, "_on_peer_connected")
#	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
#	get_tree().connect("connected_to_server", self, "_on_connected_to_server")

func _on_host_pressed() -> void:
	if $netUI/vb/pl_name.text.length()> 3:
		player_name = $netUI/vb/pl_name.text
		create_server()
		create_player(1, false)
	else:
		$netUI/vb/pl_name.text=""
	
func _on_join_pressed() -> void:
	if $netUI/vb/pl_name.text.length()> 3:
		player_name = $netUI/vb/pl_name.text
		create_client()
	else:
		$netUI/vb/pl_name.text=""
		
func _on_peer_connected(id):
	create_player(id, true)
	

func create_server():
	get_tree().connect("network_peer_connected",    self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	var network = NetworkedMultiplayerENet.new()
	network.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	ui_net_show(false)
	
func create_client():
	get_tree().connect("network_peer_connected",    self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	var network = NetworkedMultiplayerENet.new()
	network.create_client(ip, PORT)
	get_tree().set_network_peer(network)
	ui_net_show(false)
	
func _on_connected_to_server():
	var id = get_tree().get_network_unique_id()
	create_player(id, false)
	$netUI/connected.text = "connected ! ID : " + str(id)
	
func ui_net_show(is_yes:bool)->void:
	$netUI/ColorRect.visible = is_yes
	$netUI/vb.visible = is_yes
	
func create_player(id, is_peer)->void:
	nb_pl+=1
	var p = _player.instance()
	p.name = str(id)
	p.master_player = id == 1
	$netUI/master.text = str(id == 1)
	$players.add_child(p)
	var pos = get_node("positions/pos"+str(nb_pl)).position
	p.init(id, player_name, pos, is_peer)
	
func _on_peer_disconnected(id):
	$players.get_node(str(id)).queue_free()
