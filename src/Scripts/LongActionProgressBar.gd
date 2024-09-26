extends TextureProgressBar

signal completed

@export var speed: float = 15.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if visible && Input.is_action_pressed("interact"):
		value += speed * delta
	elif visible:
		hide()



func _on_value_changed(value: float) -> void:
	if value >= 100:
		completed.emit()
		hide()


func _on_visibility_changed() -> void:
	if !visible:
		value = 0
		for signals in completed.get_connections():
			completed.disconnect(signals["callable"])
