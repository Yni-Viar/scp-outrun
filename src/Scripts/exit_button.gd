extends InteractableButton


func interact(player: Node3D):
	if player is PlayerScript:
		if get_tree().root.get_node("Main/Game/RoundStats").tasks < 0 && player.unique_type_id >= 0:
			enabled = true
		elif get_tree().root.get_node("Main/Game/RoundStats").tasks > 0 && player.unique_type_id == -1:
			enabled = true
	if enabled:
		super.interact(player)
