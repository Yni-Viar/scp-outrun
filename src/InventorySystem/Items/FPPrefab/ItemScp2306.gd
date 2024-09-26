extends ItemUse


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_update(delta: float) -> void:
	if get_tree().root.get_node("Main/Game/" + str(multiplayer.get_unique_id())).is_multiplayer_authority():
		if Input.is_action_just_pressed("interact"):
			on_use(get_tree().root.get_node("Main/Game/" + str(multiplayer.get_unique_id())))
