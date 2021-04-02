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
		#better to use unique id
		create_player(get_tree().get_network_unique_id())
	else:
		$netUI/vb/pl_name.text=""
	
func _on_join_pressed() -> void:
	if $netUI/vb/pl_name.text.length()> 3:
		player_name = $netUI/vb/pl_name.text
		create_client()
	else:
		$netUI/vb/pl_name.text=""
		
func _on_peer_connected(id):
	#send his player to new player to sync the game
	rpc_id(id,"create_player",get_tree().get_network_unique_id(),player_name)
	

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
	#Don't create user directly, ask master to be registered
	var id = get_tree().get_network_unique_id()
	register_player(id, player_name)
	$netUI/connected.text = "connected ! ID : " + str(id)
	
func ui_net_show(is_yes:bool)->void:
	$netUI/ColorRect.visible = is_yes
	$netUI/vb.visible = is_yes

master func register_player(id:int, new_player_name:String):
	print("okkkkkkkkk")
	if id in get_tree().get_network_connected_peers():
		rpc("create_player",id,new_player_name)

#don't need to know if it's peer or not but need player name
remotesync func create_player(id:int, new_player_name:String = player_name)->void:
	nb_pl+=1
	var p = _player.instance()
	p.name = str(id)
	$netUI/master.text = str(is_network_master())
	$players.add_child(p)
	var pos = get_node("positions/pos"+str(nb_pl)).position
	p.init(id, player_name, pos)
	
func _on_peer_disconnected(id):
	if $players.has_node(str(id)):
		$players.get_node(str(id)).queue_free()
