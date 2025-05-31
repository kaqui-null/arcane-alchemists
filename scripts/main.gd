extends Node3D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("change_camera"):
		if $CameraSide.is_current():
			game_manager.current_state = game_manager.GameState.TOPDOWN
			$CameraTop.make_current()
		else:
			game_manager.current_state = game_manager.GameState.SIDESCROLLER
			$CameraSide.make_current()
