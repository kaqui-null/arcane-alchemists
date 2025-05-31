extends ProgressBar


func _physics_process(delta: float) -> void:
	var curr_hp = get_parent().stats["hp"]
	var max_hp = get_parent().stats["max_hp"]
	
	Range.value = floor(100*(curr_hp/max_hp))
