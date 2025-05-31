extends CharacterBody3D

@onready var side_camera = $CameraController/CameraSide
@onready var top_camera = $CameraTop
@onready var camera_controller = $CameraController
@onready var coyote_timer = $CoyoteTimer

@export var speed = 2.0
@export var jump_velocity = 2.5
@export var jump_buffer_time = 0.1
@export var coyote_time = 0.1

@onready var melee_hitbox = $MeleeHitbox
@onready var magic_spawner = $magicSpawner
#cena da magia ??
@export var magic_scene: PackedScene  # atribuir no editor com a cena da magia

var facing_direction := Vector3.RIGHT  # começa olhando para direita

var can_jump = false
var has_jump_buffer = false

func _ready():
	melee_hitbox.monitoring = false
	melee_hitbox.get_node("Sprite3D").visible = false

func _physics_process(delta: float) -> void:
	
	match game_manager.current_state:
		game_manager.GameState.SIDESCROLLER: 
			sidescroller_movement(delta)
			handle_attacks()
			
		game_manager.GameState.TOPDOWN: topdown_movement(delta)
	
	camera_follow()
	
	if Input.is_action_just_pressed("change_camera"):
		change_mode()

func handle_attacks():
	if Input.is_action_just_pressed("melee_attack"):
		melee_attack()
	elif Input.is_action_just_pressed("magic_attack"):
		cast_magic()
#adicioanr dano ao inimigo

func cast_magic():
	if magic_scene and game_manager.current_state == game_manager.GameState.SIDESCROLLER:
		var magic_instance = magic_scene.instantiate()
		get_tree().current_scene.add_child(magic_instance)
		magic_instance.global_transform = magic_spawner.global_transform

		var input_dir = Input.get_vector("left", "right", "up", "down")

		var dir = Vector3.RIGHT
		if input_dir.x < 0:
			dir = Vector3.LEFT
		elif input_dir.x == 0:
			dir = Vector3.RIGHT

		magic_instance.direction = dir

func melee_attack():
	melee_hitbox.get_node("Sprite3D").visible = true
	
	await get_tree().create_timer(0.2).timeout
	
	melee_hitbox.get_node("Sprite3D").visible = false

func sidescroller_movement(delta):
	if not is_on_floor():
		if can_jump:
			if coyote_timer.is_stopped():
				coyote_timer.start(coyote_time)
		else:
			velocity += get_gravity() * delta
	else:
		can_jump = true
		coyote_timer.stop()
		if has_jump_buffer:
			jump()
			has_jump_buffer = false

	if Input.is_action_just_pressed("jump"):
		if can_jump: 
			jump()
		else:
			has_jump_buffer = true
			get_tree().create_timer(jump_buffer_time).timeout.connect(on_jump_buffer_timeout)

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if input_dir.x > 0:
		facing_direction = Vector3.LEFT
	elif input_dir.x > 0:
		facing_direction = Vector3.RIGHT
	
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func jump():
	velocity.y = jump_velocity
	can_jump = false
	
func on_coyote_timeout():
	can_jump = false
	
func on_jump_buffer_timeout():
	has_jump_buffer = false

func topdown_movement(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta *10

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func camera_follow():
	camera_controller.position = lerp(camera_controller.position, position, 0.1)

func change_mode():
	if side_camera.is_current():
		game_manager.current_state = game_manager.GameState.TOPDOWN
		$CameraTop.make_current()
	else:
		game_manager.current_state = game_manager.GameState.SIDESCROLLER
		side_camera.make_current()
		
