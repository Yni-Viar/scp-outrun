extends Node
class_name MapObjectManager
##Item manager is used for managing items in world.
## 
## Created by Xandromeda, ported to GDscript by Yni


## 0 is object, 1 is npc, 2 is item
@export var object_type: int
## Server-side list to keep track of world items
var world_objects: Array[Array]
## Server-side method to add a new item
func add_object(id: int, pos: Vector3):
	if !object_existance_check(id):
		return
	world_objects.append([id, pos, object_type])
	# Notify clients about the new item
	rpc("client_add_object", object_type, id, pos)
## Check, does item exists? (item type is determined by objectType of the node)
func object_existance_check(id: int) -> bool:
	match object_type:
		0:
			if id >= get_tree().root.get_node("Main/Game/").game_data.map_objects.size() || id < 0:
				printerr("Could not spawn an object")
				return false
		1:
			if id >= get_tree().root.get_node("Main/Game/").game_data.npcs.size() || id < 0:
				printerr("Could not spawn an object")
				return false
		2:
			if id >= get_tree().root.get_node("Main/Game/").game_data.items.size() || id < 0:
				printerr("Could not spawn an object")
				return false
		_:
			printerr("Could not parse type of object. Please, use correct parameters")
			return false
	return true
## Server-side method to remove all items
func remove_item():
	for i in range(world_objects.size() - 1):
		world_objects.erase(i)
	rpc("client_remove_object")
## Remote Method to add an item on clients
@rpc("authority", "call_local")
func client_add_object(type: int, id: int, pos: Vector3):
	match type:
		0:
			var obj: InteractableRigidBody = get_tree().root.get_node("Main/Game/").game_data.map_objects[id].instantiate()
			obj.position = pos
			add_child(obj, true)
		1:
			var npc: Node3D = get_tree().root.get_node("Main/Game/").game_data.npcs[id].instantiate()
			add_child(npc, true)
		2:
			var pickable: ItemPickable = load(get_tree().root.get_node("Main/Game/").game_data.items[id].pickable_path).instantiate()
			pickable.position = pos
			add_child(pickable, true)
## Remote Method to remove all items on clients
@rpc("authority", "call_local")
func client_remove_object():
	for node in get_children():
		node.queue_free()
## Server-side method to get the current list of items
@rpc("authority")
func get_world_items():
	return world_objects
## Calls methods on server
@rpc("any_peer", "call_local")
func call_add_or_remove_item(creation: bool, id: int, pos: String):
	if creation:
		add_object(id, get_node(pos).global_position)
	else:
		remove_item()
