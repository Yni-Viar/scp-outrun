extends CharacterBody3D

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@export var wait_seconds: float = 5
# Check if human is watching
@export var is_not_watching: bool = true
@export var target: int
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if multiplayer.is_server():
		#If is not watching
		if is_not_watching:
			#Wait
			timer += delta
			if timer >= wait_seconds:
				rpc("teleport")
				# reset timer
				timer = 0
		else:
			# reset timer
			timer = 0



func _on_dont_look_at_me_screen_entered():
	is_not_watching = false


func _on_dont_look_at_me_screen_exited():
	is_not_watching = true

## Animation state
func set_state(s):
	# if animation is the same, do nothing, else play new animation
	if $AnimationPlayer.current_animation == s:
		return
	$AnimationPlayer.play(s, 0.3)

@rpc("any_peer", "call_local")
func teleport():
	target = get_tree().root.get_node("Main/Game").players_list[rng.randi_range(0, get_tree().root.get_node("Main/Game").players_list.size() - 1)]
	#Action. We move SCP-650 to player's global position - offset (which is transform.basis.z) * how far SCP-650 will be from player
	global_position = get_tree().root.get_node("Main/Game/" + str(target)).global_position - get_tree().root.get_node("Main/Game/" + str(target)).global_transform.basis.z * 2
	set_state("Pose " + str(rng.randi_range(4, 10)))
	# Look at player
	look_at(get_tree().root.get_node("Main/Game/" + str(target)).global_position)
