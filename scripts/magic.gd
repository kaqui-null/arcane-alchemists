extends Area3D

@export var speed = 10.0
var direction = Vector3.RIGHT  # ou LEFT, será substituído ao instanciar
var damage = 5

func _physics_process(delta):
	position += direction * speed * delta

	# remove o projétil após sair da tela
	if abs(global_position.x) > 1000:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	queue_free()
