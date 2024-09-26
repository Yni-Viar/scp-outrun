extends Node

## Round end definition depends on this value.
## If tasks > 0 - then MTF wins.
## If tasks < 0 - then SCP wins.
## If tasks = 0 - stalemate.
@export var tasks: float = 0
@export var generators: int = 0
@export var generator_spawns: PackedStringArray
@export var scp_targets: int = 0
@export var scp_amount: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@rpc("any_peer", "call_local")
func task_updater(type: int, value: float):
	match type:
		0:
			tasks += value
		1:
			generators += int(value)
			if generators >= 3:
				tasks -= 1
				set_physics_process(false)
	

func end_game_server():
	if tasks > 0: #MTF
		rpc("end_game", 1)
	elif tasks < 0: #SCPs
		rpc("end_game", 2)
	else: #Stalemate
		rpc("end_game", 0)

@rpc("any_peer", "call_local")
func end_game(reason: int):
	get_parent().get_node("PlayerUI/Goals").hide()
	match reason:
		0:
			get_parent().get_node("PlayerUI/GameEnd").text = tr("STALEMATE_ROUNDEND")
		1:
			get_parent().get_node("PlayerUI/GameEnd").text = tr("MTF_ROUNDEND")
		2:
			get_parent().get_node("PlayerUI/GameEnd").text = tr("SCPS_ROUNDEND")
	get_parent().get_node("PlayerUI/AnimationPlayer").play("roundend")
	await get_tree().create_timer(12.0).timeout
	get_parent().get_parent().round_restart()


func _on_facility_generator_generated() -> void:
	if multiplayer.is_server():
		var available_generator_pos = get_tree().get_nodes_in_group("powerbox")
		var size = 3
		var random = 0
		if available_generator_pos.size() < 3:
			size = available_generator_pos.size()
		var i = 0
		while i < size:
			rng.randomize()
			random = rng.randi_range(0, available_generator_pos.size() - 1)
			if generator_spawns.has(available_generator_pos[random].get_path()):
				continue
			else:
				spawn_powerbox(available_generator_pos[random].get_path())
				generator_spawns.append(available_generator_pos[random].get_path())
			i += 1
	else:
		for path in generator_spawns:
			spawn_powerbox(path)


func check_round_stats(prev_name_of_class: int, name_of_class: int):
	if get_parent().game_data.classes[name_of_class].unique_type_id > 0:
		scp_amount += 1
	elif get_parent().game_data.classes[prev_name_of_class].unique_type_id > 0 && get_parent().game_data.classes[name_of_class].unique_type_id <= 0:
		scp_amount -= 1
	if get_parent().game_data.classes[name_of_class].unique_type_id == -1:
		scp_targets += 1
	elif get_parent().game_data.classes[prev_name_of_class].unique_type_id == -1 && get_parent().game_data.classes[name_of_class].unique_type_id != -1:
		scp_targets -= 1
	check_round_end()


func check_round_end():
	await get_tree().create_timer(3.0).timeout
	if get_parent().players_list.size() > 1 && get_parent().is_round_started:
		if scp_targets <= 0 && scp_amount > 0:
			rpc("end_game", 2)
		elif scp_amount <= 0 && scp_targets > 0:
			rpc("end_game", 1)

func spawn_powerbox(path: String):
	var generator_mesh = load("res://Assets/Models/PowerBox.tscn").instantiate()
	get_node(path).add_child(generator_mesh)
