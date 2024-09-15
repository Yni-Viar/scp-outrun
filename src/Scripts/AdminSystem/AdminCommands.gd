extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	#GDsh.add_command("admin_grant", admin_grant, "Grant admin privilegies")
	GDsh.add_command("admin_ban", admin_ban, "Bans a player (admin access required)")
	GDsh.add_command("admin_kick", admin_kick, "Kicks a player (admin access required)")
	GDsh.add_command("get_peers", get_peers, "Gets all peers")
	GDsh.add_command("invites_list", invites_list, "See all incoming invites")
	GDsh.add_command("accept_invite", accept_invite, "Accepts invite. First argument - index of invite, second - 0 if moderator, 1 - if admin (admin access required)")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func admin_grant(args: Array):
	#if args[0].is_empty():
		#return "Provide a password!"
	#else:
		##
		#return "Processing your request..."

func admin_ban(args: Array):
	if check_if_admin():
		if args[0].is_empty():
			return "Provide a peer's id! You can find it in get_player_peers command..."
		if args[0] == "1":
			return "You cannot ban the server"
		get_parent().ban(int(args[0]))
		return "Successfully banned!"
	else:
		return "You are not granted to do this action!"

func admin_kick(args: Array):
	if check_if_admin():
		if args[0].is_empty():
			return "Provide a peer's id! You can find it in get_player_peers command..."
		if args[0] == "1":
			return "You cannot kick the server"
		get_tree().root.get_node("Main").rpc_id(int(args[0]), "kick")
		return "Successfully kicked!"
	else:
		return "You are not granted to do this action!"

func get_peers(args: Array):
	var s: String = ""
	for peer in get_parent().get_children():
		if peer is PlayerScript:
			s += peer.name + " - " + peer.player_name
	return s

func check_if_admin() -> bool:
	for admins in get_parent().admin_list.admin_list:
		if admins.contains(str(hash(get_tree().root.get_node("Main").get_peer(multiplayer.get_remote_sender_id())))):
			return true
	return false
#@rpc("any_peer")
#func ask_for_admin(peer_id: int, password: String):
	#if hash(password) == hash(get_parent().admin_password):
		#get_parent().rpc_id(peer_id, "grant_admin_privilegies", peer_id)
#
#func ask_for_admin_connector(password: String):
	#rpc_id(1, "ask_for_admin", multiplayer.get_unique_id(), password)
#
#@rpc("any_peer")
#func ask_for_moderator(peer_id: int, password: String):
	#if hash(password) == hash(get_parent().moderator_password):
		#get_parent().rpc_id(peer_id, "grant_admin_privilegies", peer_id)
## GDSh command. Gets list of invites
func invites_list(args: Array) -> String:
	var s: String = ""
	var counter: int = 0
	for pending in get_parent().admin_list.pending_list:
		s += "[" + str(counter) + "] " + pending
		counter += 1
	return s

## GDSh command. Accepts invites.
func accept_invite(args: Array):
	if check_if_admin():
		if args[0].is_empty() || args[1].empty():
			return "Provide invite list index and a role for continuing. You can see it by calling invites_list command between [ and ]"
		else:
			match int(args[1]):
				0:
					get_parent().admin_list.moderator_list.append(get_parent().admin_list.pending_list[int(args[0])])
					get_parent().admin_list.pending_list.remove_at(int(args[0]))
					return "This person became a moderator!"
				1:
					get_parent().admin_list.admin_list.append(get_parent().admin_list.pending_list[int(args[0])])
					get_parent().admin_list.pending_list.remove_at(int(args[0]))
					return "This person became an admin!"
				_:
					return "Error."
	else:
		return "You are not granted to do this action!"
