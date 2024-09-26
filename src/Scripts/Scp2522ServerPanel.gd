extends Panel

@export var ongoing: bool:
	set(val):
		if val:
			show()
		else:
			hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		if visible:
			if $ProgressBar.value < 100.0:
				$ProgressBar.value += 0.01
			else:
				recontain()
				set_physics_process(false)
		elif $ProgressBar.value > 0.0:
			$ProgressBar.value -= 0.005


func interact(player: PlayerScript):
	if player.unique_type_id >= 0 && visible:
		ongoing = false
		visible = false
		rpc("eject", false)
		return
	var path = str(player.get_path()) + "/InventoryUI/Inventory"
	if get_node_or_null(path) == null:
		return
	rpc("activate", path)
	ongoing = true

func recontain():
	get_tree().root.get_node("Main/Game/RoundStats").rpc_id(1, "task_updater", 0, 1.0)
	rpc("eject", true)

@rpc("any_peer", "call_local")
func eject(completed: bool):
	if completed:
		$WorkingOnDiagnosticsLabel.text = "Server optimized!"
		$Info.text = "1 threat removed."
	else:
		ongoing = false
	get_tree().root.get_node("Main/Game/Items").rpc_id(1, "call_add_or_remove_item", true, 1, "/root/Main/Game/FacilityGenerator/LC_room2_servers/itemspawn")

@rpc("any_peer", "call_local")
func activate(path):
	get_node(path).rpc("remove_item_by_index", 1, false)
	ongoing = true
