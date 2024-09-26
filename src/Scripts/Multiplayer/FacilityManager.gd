extends Node3D
## Gameplay manager
## Made by Yni, licensed under MIT license.
class_name FacilityManager

## Nickname
var local_nickname: String
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var env: WorldEnvironment
## Path to world environment
@export var environment_path: String
## Level data (contains list of all classes, items, e.t.c)
@export var game_data: GameData
## Level main music
@export var music_to_play: Array[String] = []
## Max spawnable objects (set by NetworkManager)
@export var max_spawnable_objects: int = 12
## Round start check.
@export var is_round_started: bool
## List of the players
@export var players_list: Array[int] = []

var admin_list: AdminList
## Ambient file path, used by Music Changer function
var current_ambient: String

var all_scps: Array[int] = []
var used_scps: Array[int] = []

func _enter_tree() -> void:
	var ini: IniParser = IniParser.new()
	if !FileAccess.file_exists("user://bans.txt"):
		var txt: TxtParser = TxtParser.new()
		txt.save("user://bans.txt", "")
	if multiplayer.get_unique_id() != 1:
		rpc_id(1, "check_if_banned", multiplayer.get_unique_id())
	else:
		if !FileAccess.file_exists("user://granted.tres"):
			var admin_list: AdminList = AdminList.new()
			ResourceSaver.save(admin_list, "user://granted.tres")
		admin_list = load("user://granted.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.get_node("Main/LoadingScreen/").visible = false
	env = get_node("WorldEnvironment")
	## Load graphics
	if env.environment == null || environment_path.is_empty():
		env.environment = load("res://DefaultGraphics.tres")
	else:
		env.environment = load(environment_path)
	## Set user settings
	env.environment.sdfgi_enabled = Settings.setting_res.dynamic_gi
	env.environment.ssao_enabled = Settings.setting_res.ssao
	env.environment.ssil_enabled = Settings.setting_res.ssil
	env.environment.ssr_enabled = Settings.setting_res.ssr
	env.environment.glow_enabled = Settings.setting_res.glow
	## Set background music through music ID.
	if music_to_play.size() > 0:
		set_background_music(music_to_play[0])
	on_start()
	if multiplayer.is_server():
		## Server methods
		check_available_scps()
		max_spawnable_objects = get_parent().max_objects
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(remove_player)
		## Add players
		for id in multiplayer.get_peers():
			add_player(id)
		add_player(1)
		
		on_server_start()

func check_available_scps():
	var counter = 0
	for player_class in game_data.classes:
		if player_class.unique_type_id >= 0:
			all_scps.append(counter)
		counter += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	on_update(delta)

func on_start():
	$PlayerUI/PreRoundStartPanel.show()

func on_server_start():
	wait_for_beginning()

func on_update(delta: float):
	if !is_round_started:
		$PlayerUI/PreRoundStartPanel/PreRoundStart/Amount.text = str(players_list.size()) 

func wait_for_beginning():
	await get_tree().create_timer(15.0).timeout
	if !is_round_started:
		begin_game()
	if get_parent().spawn_npcs:
		if rng.randi_range(0, 3) <= 2: # && players_list.size() > 1:
			var key: int = rng.randi_range(0, game_data.npcs.size() - 1)
			$NPCs.rpc_id(1, "call_add_or_remove_item", true, key, get_path())

## Implementation of round start.
func begin_game():
	var players: Array[Node] = get_tree().get_nodes_in_group("Players")
	var i: int = 1
	for player in players:
		if player is PlayerScript:
			randomize_class(i, player)
			i += 1
	is_round_started = true
	if get_node_or_null("RoundStats") != null:
		await get_tree().create_timer(720.0).timeout
		get_node("RoundStats").end_game_server()

## Adds player to server.
func add_player(id: int):
	## Player scene, that will become a player afterwards
	var player_scene: CharacterBody3D
	player_scene = load($MultiplayerSpawner.get_spawnable_scene(0)).instantiate()
	player_scene.name = str(id)
	add_child(player_scene, true)
	players_list.append(player_scene.name.to_int())
	if is_round_started:
		post_round_start(players_list, id)
	print("Player " + str(id) + " has joined the server!")


## Removes the player from server
func remove_player(id: int):
	if get_node_or_null(str(id)) != null:
		get_node(str(id)).queue_free()
		players_list.erase(id)
		print("Player " + str(id) + " has left the server!")


## Sets player class for a specified player. (RpcId)
@rpc("any_peer", "call_local")
func set_player_class(player_name: String, name_of_class: int, reason: String, post_start: bool):
	$PlayerUI/PreRoundStartPanel.hide()
	var old_player_class: int = get_node(player_name).player_class_key
	if name_of_class < 0 || name_of_class >= game_data.classes.size():
		print("For security reasons, you cannot change to class, that is unsupported by this server")
	var class_data: BaseClass = game_data.classes[name_of_class]
	if !post_start:
		rpc("set_player_class_public", player_name, name_of_class, old_player_class)
	if name_of_class >= 0:
		$PlayerUI/Targets.show()
	else:
		$PlayerUI/Targets.hide()
	get_node(player_name).player_class_key = name_of_class
	get_node(player_name).player_class_description = class_data.player_class_description
	get_node(player_name).sprint_enabled = class_data.sprint_enabled
	get_node(player_name).speed = class_data.speed
	get_node(player_name).jump = class_data.jump
	get_node(player_name).can_move = class_data.can_move
	$PlayerUI/Goals.text = game_data.goals[class_data.team_id]
	get_node(player_name).enable_inventory = class_data.enable_inventory
	get_node(player_name).call("camera_manager", !class_data.custom_camera)
	get_node(player_name).call("update_class_ui", class_data.class_color.to_rgba32())
	get_node(player_name).call("apply_shader", class_data.custom_shader)
	# call("preload_inventory")
	var spawn_point: String = class_data.spawn_points[rng.randi_range(0, class_data.spawn_points.size() - 1)]
	if get_tree().root.get_node_or_null(spawn_point) != null:
		get_node(player_name).global_position = get_tree().root.get_node(spawn_point).global_position


## Sets player class through the RPC.
@rpc("any_peer", "call_local")
func set_player_class_public(player_name: String, name_of_class: int, previous_player_class: int):
	var class_data: BaseClass = game_data.classes[name_of_class]
	get_node(player_name).player_class_name = class_data.player_class_name
	get_node(player_name).move_sounds_enabled = class_data.move_sounds_enabled
	get_node(player_name).unique_type_id = class_data.unique_type_id
	get_node(player_name).footstep_sounds = class_data.footstep_sounds
	get_node(player_name).sprint_sounds = class_data.sprint_sounds
	get_node(player_name).health = class_data.health
	get_node(player_name).current_health = class_data.health.duplicate()
	get_node(player_name).ragdoll_source = class_data.player_ragdoll_source
	load_models(player_name, name_of_class)
	if multiplayer.is_server():
		if get_node_or_null("RoundStats") != null:
			get_node("RoundStats").check_round_stats(previous_player_class, name_of_class)

## Recall player classes for player, which got connected to ongoing round.
func post_round_start(players, target):
	rpc_id(target, "set_player_class", str(multiplayer.get_unique_id()), 0, "Post-roundstart arrival", false)
	for player in players:
		if str(player) != str(multiplayer.get_unique_id()):
			rpc_id(target, "set_player_class", str(player), get_node(str(player)).player_class_key, "Previous player", true)
	#rpc("clean_ragdolls")

func randomize_class(counter: int, player: PlayerScript):
	if counter == 2 || counter % 8 == 0:
		var random_scp: int = all_scps[rng.randi_range(0, all_scps.size() - 1)]
		rpc_id(player.name.to_int(), "set_player_class", str(player.name), random_scp, "Round start", false)
	else:
		rpc_id(player.name.to_int(), "set_player_class", str(player.name), 2, "Round start", false)

## Loads the models of a player.
func load_models(player_name: String, class_id: int):
	var player = get_node(player_name)
	if class_id >= 0 && class_id < game_data.classes.size():
		var model_root: Node = player.get_node("PlayerModel")
		for item_used_before in model_root.get_children():
			item_used_before.queue_free()
		var tmp_model: Node3D = load(game_data.classes[class_id].player_model_source).instantiate()
		model_root.add_child(tmp_model)

## Spawns player ragdoll.
@rpc("any_peer", "call_local")
func spawn_ragdoll(player: String, ragdoll_src: String):
	pass
## Cleans ragdolls (used when a new player connects)
@rpc("any_peer", "call_local")
func clear_ragdolls():
	for node in get_node("Ragdolls").get_children():
		node.queue_free()
## Teleports object to player.
@rpc("any_peer", "call_local")
func teleport_to(from: String, destination: String):
	match destination:
		"random_player":
			get_node(from).global_position = get_node(str(players_list[rng.randi_range(0, players_list.size() - 1)])).global_position
		_:
			get_node(from).global_position = get_node(destination).global_position
## Sets background music.
func set_background_music(to: String):
	if current_ambient != to:
		$AnimationPlayer.play("music_change")
		$BackgroundMusic.stream = load(to)
		$BackgroundMusic.playing = true
		$AnimationPlayer.play_backwards("music_change")
		current_ambient = to

## hides lobby after start
@rpc("any_peer", "call_local")
func hide_lobby():
	$PlayerUI/PreRoundStartPanel.hide()

## bans a player
func ban(id: int):
	get_parent().rpc_id(id, "kick")
	rpc_id(1, "add_detention_note", get_parent().get_peer(id))

@rpc("any_peer")
func add_detention_note(ip: String):
	var txt: TxtParser = TxtParser.new()
	var s: String = txt.load("user://bans.txt")
	s += "\n" + ip
	txt.save("user://bans.txt", s)

@rpc("any_peer")
func grant_admin_privilegies(peer_id: int):
	get_node(str(peer_id)).is_admin = true
	print(str(peer_id) + "became admin")

@rpc("any_peer")
func grant_moderator_privilegies(peer_id: int):
	get_node(str(peer_id)).is_moderator = true
	print(str(peer_id) + "became moderator")

@rpc("any_peer")
func check_if_banned(id: int):
	var txt: TxtParser = TxtParser.new()
	if txt.open("user://bans.txt").contains(get_parent().get_peer(id)):
		get_parent().rpc_id(id, "kick")
