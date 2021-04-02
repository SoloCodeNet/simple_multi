extends Area2D

var from_player=null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()

func _on_Timer_timeout() -> void:
	queue_free()
