extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body is PlayerScript:
		get_tree().root.get_node("Main/Game/RoundStats").end_game_server()
		body_entered.disconnect(_on_body_entered)
