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

var battle_distance_counter := 0.0
@export var battle_threshold := 5.0
@export var battle_chance := 0.3

@onready var magic_sound_player = $MagicSoundPLayer
@onready var melee_sound_player = $MeleeSoundPLayer
@onready var jump_sound_player = $JumpSoundPLayer
@onready var footstep_sound_player = $FootstepSoundPLayer

var footstep_timer := 0.0
var footstep_interval := 0.2
var melee_sound_timer := 0.0
var melee_sound_interval := 0.3

var facing_direction := Vector3.RIGHT  # começa olhando para direita
var health = 100
var is_dead = false
var can_jump = false
var has_jump_buffer = false

var magic_cooldown = 0.1
var magic_timer = 0.0

func _ready():
	melee_hitbox.monitoring = false
	melee_hitbox.get_node("Sprite3D").visible = false


func _physics_process(delta: float) -> void:
	if is_dead:
		get_tree().reload_current_scene()
	
	if magic_timer > 0:
		magic_timer -= delta
	if melee_sound_timer > 0.0:
		melee_sound_timer -= delta
		
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
	elif Input.is_action_pressed("magic_attack") and magic_timer <= 0:
		cast_magic()
		magic_timer = magic_cooldown
#adicioanr dano ao inimigo

func cast_magic():
	if magic_scene and game_manager.current_state == game_manager.GameState.SIDESCROLLER:
		var magic_instance = magic_scene.instantiate()
		get_tree().current_scene.add_child(magic_instance)

		var dir = facing_direction

		if Input.is_action_pressed("aim_mode"):
			var input_dir = Input.get_vector("left", "right", "up", "down")
			dir = get_aim_direction(input_dir)

		var offset = Vector3(0.1, 0, 0) if dir == Vector3.RIGHT else Vector3(-0.5, 0, 0)
		var spawn_pos = magic_spawner.global_transform.origin + offset
		var spawn_transform = magic_spawner.global_transform
		spawn_transform.origin = spawn_pos

		magic_instance.global_transform = spawn_transform
		magic_instance.direction = dir

		magic_sound_player.play()

func melee_attack():
	if melee_sound_timer <= 0.0:
		melee_sound_player.play()
		melee_sound_timer = melee_sound_interval
	
	var offset = Vector3(0, 0, 0) if facing_direction == Vector3.RIGHT else Vector3(-0.43, 0, 0)
	melee_hitbox.position = offset 
	melee_hitbox.get_node("Sprite3D").visible = true
	
	melee_hitbox.monitoring = true
	melee_hitbox.get_node("Sprite3D").visible = true
	
	await get_tree().create_timer(0.2).timeout
	
	melee_hitbox.monitoring = false
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
	
	if Input.is_action_pressed("aim_mode"):
		velocity.x = 0
		move_and_slide()
		return

	var input_dir := Input.get_vector("left", "right", "up", "down")
	
	if input_dir.x < 0:
		facing_direction = Vector3.LEFT
	elif input_dir.x > 0:
		facing_direction = Vector3.RIGHT
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func get_aim_direction(input_dir: Vector2) -> Vector3:
	if input_dir.length() == 0:
		return facing_direction  # ou qualquer padrão
	
	var angle = rad_to_deg(input_dir.angle())
	
	if angle < -157.5 or angle > 157.5:
		return Vector3.LEFT
	elif angle < -112.5:
		return (Vector3.LEFT + Vector3.UP).normalized()
	elif angle < -67.5:
		return Vector3.UP
	elif angle < -22.5:
		return (Vector3.RIGHT + Vector3.UP).normalized()
	elif angle < 22.5:
		return Vector3.RIGHT

	return facing_direction

func jump():
	jump_sound_player.play()
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
	
	if is_on_floor():
		if direction != Vector3.ZERO:
			footstep_timer -= delta
			if footstep_timer <= 0.0:
				play_footstep_sound()
				footstep_timer = footstep_interval
		else:
			if footstep_sound_player.playing:
				footstep_sound_player.stop()
			footstep_timer = 0.0
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		battle_distance_counter += direction.length() * speed * delta
		if battle_distance_counter >= battle_threshold:
			battle_distance_counter = 0.0
			if randf() < battle_chance:
				start_battle()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()

func play_footstep_sound():
	footstep_sound_player.pitch_scale = randf_range(0.8, 1.2)
	footstep_sound_player.play()

func start_battle():
	print("batalha")
	#adicionar a cena

func camera_follow():
	camera_controller.position = lerp(camera_controller.position, position, 0.1)

func change_mode():
	if side_camera.is_current():
		game_manager.current_state = game_manager.GameState.TOPDOWN
		$CameraTop.make_current()
	else:
		game_manager.current_state = game_manager.GameState.SIDESCROLLER
		side_camera.make_current()
		

func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	print("Player died")
	is_dead = true
