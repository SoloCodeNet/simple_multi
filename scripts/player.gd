extends KinematicBody2D
onready var _bomb = preload("res://prefabs/bomb.tscn")
var speed := 300.0
var dir   := Vector2.ZERO
var vel   := Vector2.ZERO
var id=0
var pl_name : =""
var action  :=false

func init(_id:int, _name:String, _pos:Vector2):
	id = _id
	print("player name:", id)
	position=_pos
	pl_name = _name
	$lbl_name.text = pl_name
	#If id == selfid should put player skin
	$Sprite.frame = 0 if not id == get_tree().get_network_unique_id() else 3

func _process(_delta: float) -> void:
	if id == get_tree().get_network_unique_id():
		dir = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
		).normalized()
		if Input.is_action_just_pressed("ui_accept"):
			rpc("setup_bomb", "toto", position, id)
		vel = dir * speed
		vel = move_and_slide(vel, Vector2.UP)
		rpc("update_position",position)
		#rset_unreliable("update_position",position)
		
remote func update_position(pos):
	position = pos
	
sync func setup_bomb(bomb_name, pos, by_who)->void:
	var b = _bomb.instance()
	b.set_name(bomb_name)
	get_parent().add_child(b)
	b.position = pos
	b.from_player = by_who
	
	pass
