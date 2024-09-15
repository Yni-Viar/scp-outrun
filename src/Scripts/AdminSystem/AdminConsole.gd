extends Panel

enum Access {NO_ACCESS, MODERATOR, ADMIN}
var admin_access: Access = Access.NO_ACCESS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_btn_pressed() -> void:
	if multiplayer.is_server():
		get_tree().get_node("/root/GDsh").show()
		self.hide()
	else:
		rpc_id(1, "check_if_moderator")


func _on_send_invite_btn_pressed() -> void:
	for id in get_tree().root.get_node("Main/Game").players_list:
		if get_tree().root.get_node("Main/Game").admin_list != null:
			if get_tree().root.get_node("Main/Game").admin_list.admin_list.has(hash(get_tree().root.get_node("Main").get_peer(id))):
				rpc_id(id, "send_invite")


## Sends moderator/admin invite to server admins
@rpc("any_peer")
func send_invite():
	get_tree().root.get_node("Main/Game").admin_list.pending_list.append(str(hash(get_tree().root.get_node("Main").get_peer(multiplayer.get_remote_sender_id()))) + " | " + get_tree().root.get_node("Main/Game/"+ str(multiplayer.get_remote_sender_id())).player_name)


@rpc("any_peer", "call_local")
func check_if_moderator():
	#if get_tree().root.get_node("Main/").get_peer(multiplayer.get_unique_id()))..is_admin || get_tree().root.get_node("Main/Game/" + multiplayer.get_unique_id()).is_moderator:
		#get_tree().get_node("/root/GDsh").show()
		#self.hide()
	if get_tree().root.get_node("Main/Game").admin_list.admin_list.has(str(hash(get_tree().root.get_node("Main").get_peer(multiplayer.get_remote_sender_id())))) || get_tree().root.get_node("Main/Game").admin_list.moderator_list.has(get_tree().root.get_node("Main/Game/"+ str(multiplayer.get_remote_sender_id())).player_name) || get_tree().root.get_node("Main/Game").moderator_list.has(str(hash(get_tree().root.get_node("Main").get_peer(multiplayer.get_remote_sender_id())))) || get_tree().root.get_node("Main/Game").moderator_list.has(get_tree().root.get_node("Main/Game/" + str(multiplayer.get_remote_sender_id())).player_name):
		rpc_id(multiplayer.get_remote_sender_id(), "open_sesame", true)
	else:
		rpc_id(multiplayer.get_remote_sender_id(), "open_sesame", false)
@rpc("any_peer", "call_local")
func open_sesame(access: Access):
	if access:
		get_tree().get_node("/root/GDsh").show()
		self.hide()
	else:
		$Label3.show()
