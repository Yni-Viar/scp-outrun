extends DoorBase


func door_controller(keycard: int):
	super.door_controller(keycard)
	if is_opened && !get_node("AnimationPlayer").is_playing():
		door_close()
		is_opened = false
	elif !get_node("AnimationPlayer").is_playing():
		door_open()
		is_opened = true

func interact(player):
	rpc("door_control", player.get_path(), 0)
