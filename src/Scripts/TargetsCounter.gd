extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = tr("TARGETS") + " " + str(get_parent().get_parent().get_node("RoundStats").scp_targets)


func _on_visibility_changed() -> void:
	if visible:
		set_process(true)
	else:
		set_process(false)
