extends InteractableStaticBody

@export var completed: bool = false

func interact(player: Node3D):
	if player is PlayerScript && !completed:
		if player.unique_type_id >= 0:
			get_tree().root.get_node("Main/Game/PlayerUI/TextureProgressBar").visible = true
			#get_tree().root.get_node("Main/Game/PlayerUI/TextureProgressBar").speed = 20.0
			get_tree().root.get_node("Main/Game/PlayerUI/TextureProgressBar").connect("completed", _on_completed)

func _on_completed():
	get_tree().root.get_node("Main/Game/PlayerUI/TextureProgressBar").disconnect("completed", _on_completed)
	get_tree().root.get_node("Main/Game/RoundStats").rpc_id(1, "task_updater", 1, 1.0)
	rpc("complete")

@rpc("any_peer", "call_local")
func complete():
	$AnimationPlayer.play("open")
	$power_box_01_box.mesh.surface_get_material(0).next_pass = null
	completed = true
