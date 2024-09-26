extends InteractableRigidBody
class_name ItemPickable

@export var item: Item

func _ready() -> void:
	if !freeze:
		if get_node_or_null("Mesh") != null:
			$Mesh.mesh.surface_get_material(0).next_pass = load("res://Shaders/Presets/ItemOutline.tres")

func interact(player: Node3D):
	if !freeze:
		rpc_id(1, "add_to_inventory")

@rpc("any_peer", "call_local")
func add_to_inventory():
	get_tree().root.get_node("Main/Game/" + str(multiplayer.get_unique_id()) + "/InventoryUI/Inventory").rpc_id(multiplayer.get_unique_id(), "add_item", item.id)
	rpc("clear_world_item")

@rpc("any_peer", "call_local")
func clear_world_item():
	queue_free()
