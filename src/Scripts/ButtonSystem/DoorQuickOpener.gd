extends InteractableNode


func interact(player: Node3D):
	if !enabled:
		super.interact(player)
	get_parent().get_parent().rpc("door_control", player.get_path(), -1)
