extends Resource
class_name AdminList

@export var admin_list: Array[String]
@export var moderator_list: Array[String]
@export var pending_list: Array[String]

func _init(p_admin_list: Array[String] = [], p_moderator_list: Array[String] = [], p_pending_list: Array[String] = []) -> void:
	admin_list = p_admin_list
	moderator_list = p_moderator_list
	pending_list = p_pending_list
