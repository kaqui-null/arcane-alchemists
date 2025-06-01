extends CharacterBody3D

@onready var left_raycast = $LeftEdgeCast
@onready var right_raycast = $RightEdgeCast
@export var speed = 0.5

var damage = 50
var health = 100
var facing_direction = -1

func _physics_process(delta):
	if is_on_floor():
		if !left_raycast.is_colliding() and facing_direction == -1:
			flip_direction()
		elif !right_raycast.is_colliding() and facing_direction == 1:
			flip_direction()
			
	velocity.y += get_gravity().y * delta
	velocity.x = speed * facing_direction
	move_and_slide()

func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	queue_free()

func flip_direction():
	facing_direction *= -1

func _on_left_area_body_entered(body: Node3D) -> void:
	facing_direction = 1

func _on_right_area_body_entered(body: Node3D) -> void:
	facing_direction = -1

func _on_damage_area_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
