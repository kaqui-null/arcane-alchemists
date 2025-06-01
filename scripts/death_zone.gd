extends Area3D

@onready var player = %Player

func _on_body_entered(body: Node3D) -> void:
	print("a")
	if body.is_in_group("Player"):
		get_tree().reload_current_scene()
