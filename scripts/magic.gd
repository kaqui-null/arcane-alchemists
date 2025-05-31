extends Area3D

@export var speed = 10.0
var direction = Vector3.RIGHT  # ou LEFT, será substituído ao instanciar

func _physics_process(delta):
	position += direction * speed * delta

	# remove o projétil após sair da tela
	if abs(global_position.x) > 1000:
		queue_free()
