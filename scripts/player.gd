extends KinematicBody2D

var speed := 150.0
var dir   := Vector2.ZERO
var vel   := Vector2.ZERO
var slave_position := Vector2.ZERO
var id=0
var master_player:= false

func init(_id:int, _name:String, _pos:Vector2, is_slave:bool):
	id = _id
	print("player name:", id)
	position=_pos
	$lbl_name.text = _name
	$Sprite.frame = 0 if not is_slave else 3

func _process(_delta: float) -> void:
#	if master_player:
	if id == get_tree().get_network_unique_id():
		dir = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
		).normalized()
		vel = dir * speed
		vel = move_and_slide(vel, Vector2.UP)
		rset_unreliable("update_position",position)
	else:
		position = slave_position
		
remote func update_position(pos):
	slave_position = pos
