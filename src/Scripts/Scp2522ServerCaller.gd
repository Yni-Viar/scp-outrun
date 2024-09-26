extends InteractableStaticBody

func interact(player: Node3D):
	if player is PlayerScript:
		get_parent().get_node("27-inch-monitor-with-movable-mount9/SubViewport/Control/Panel").interact(player)
