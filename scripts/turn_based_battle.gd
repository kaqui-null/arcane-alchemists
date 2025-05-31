extends Node2D

enum Turn { PLAYER, ENEMY }
var current_turn = Turn.PLAYER

var player_hp = 100
var enemy_hp = 100

func _ready():
	print("Combat starts!")
	await start_turn()

func start_turn():
	if current_turn == Turn.PLAYER:
		print("Player's Turn")
		await get_tree().create_timer(1.0).timeout
		player_attack()
	else:
		print("Enemy's Turn")
		await get_tree().create_timer(1.0).timeout
		enemy_attack()

func player_attack():
	var damage = randi() % 20 + 5
	print("Player attacks for ", damage, " damage!")
	enemy_hp -= damage
	check_battle_state()

func enemy_attack():
	var damage = randi() % 15 + 3
	print("Enemy attacks for ", damage, " damage!")
	player_hp -= damage
	check_battle_state()

func check_battle_state():
	if enemy_hp <= 0:
		print("Enemy defeated!")
	elif player_hp <= 0:
		print("Player defeated!")
	else:
		end_turn()

func end_turn():
	current_turn = Turn.ENEMY if current_turn == Turn.PLAYER else Turn.PLAYER
	await start_turn()
