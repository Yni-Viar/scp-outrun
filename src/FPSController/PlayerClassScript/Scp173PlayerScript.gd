extends ScpCommonPlayerScript

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## How many players (all classes) are watching SCP-173
@export var is_watching: int = 0
## How many humans (not other classes) are watching SCP-173
@export var stare_counter: int = 0
@export var invincibility: bool = false
@export var blink_countdown: float  = 4.7
@export var blind_countdown: float = 1000.0
var blink_timer = blink_countdown
var poses = [ "173_Pose1", "173_Pose2", "173_Pose3", "173_Pose4", "173_Pose5", "173_Pose6", "173_Pose7", "173_TPose" ]
var ray: RayCast3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().get_parent().is_multiplayer_authority():
		$SCP173_Rig.hide()
		$AbilityUI.show()
		get_parent().get_parent().can_move = true
	ray = get_parent().get_parent().get_node("PlayerHead/PlayerRecoil/RayCast3D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if get_parent().get_parent().is_multiplayer_authority():
		if Input.is_action_just_pressed("attack") && ray.is_colliding():
			var collided_with = ray.get_collider()
			if collided_with is PlayerScript:
				if collided_with.unique_type_id == -1:
					$InteractSound.stream = load("res://Sounds/Character/173/NeckSnap"+str(rng.randi_range(1, 3))+".ogg")
					rpc_id(collided_with.name.to_int(), "health_manage", -32767, 0, "Crunched by SCP-173")
					rpc("set_state", poses[rng.randi_range(0, poses.size() - 1)])
		#if Input.is_action_pressed("scp173_blind"):
			#ability_blind()
		scp_173_stare(delta)
	
## SCP-173 main mechanic (ported from SCP: SO)
func scp_173_stare(delta: float):
	if is_watching > 0 && stare_counter > 0 && !invincibility:
		if blink_timer <= 0:
			get_parent().get_parent().can_move = true
			await get_tree().create_timer(0.5).timeout
			blink_timer = blink_countdown
		else:
			get_parent().get_parent().can_move = false
		blink_timer -= delta
	else:
		get_parent().get_parent().can_move = true

func ability_blind():
	invincibility = true
	await get_tree().create_timer(7.5).timeout
	invincibility = false
	await get_tree().create_timer(30.0).timeout

## Animation state
@rpc("any_peer", "call_local")
func set_state(s):
	# if animation is the same, do nothing, else play new animation
	if $AnimationPlayer.current_animation == s:
		return
	$AnimationPlayer.play(s, 0.3)


func _on_dont_look_at_me_screen_entered() -> void:
	is_watching += 1


func _on_dont_look_at_me_screen_exited() -> void:
	is_watching -= 1


func _on_stare_area_body_entered(body: Node3D) -> void:
	if body is PlayerScript:
		if body.unique_type_id == -1:
			stare_counter += 1


func _on_stare_area_body_exited(body: Node3D) -> void:
	if body is PlayerScript:
		if body.unique_type_id == -1:
			stare_counter -= 1
