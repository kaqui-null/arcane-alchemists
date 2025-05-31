extends Node2D

@export var stats = {}
@export var stat_keys = {}
@export var stat_values = {}
@export var status = "none"

func _physics_process(delta: float) -> void:
	pass

func _init() -> void:
	file_reading()
	set_lvl_stats()

func file_reading():
	var stat_file = FileAccess.open('res://enemy_stats/player_stats.json', FileAccess.READ)
	var stat_string = stat_file.get_as_text()
	stat_file.close()
	var json = JSON.new()
	var error = json.parse(stat_string)
	if error == OK:
		stats = json.data
	
	stat_keys = stats.keys()
	stat_values = stats.values()

func physical_attack(target_defense) -> float:
	var dmg = floor((randf_range(stats["strenght"], stats["strenght"]) - target_defense))
	return dmg

# matrix_resistance is a string of the element: fire, water, earth, air, etc and type of resistance
# eg. [[fire, weak], [water, absorb]]
func magic_attack(magical_element, mp_consumption, target_magical_defense, resistance_matrix) -> float:
	if stats["mp"] < mp_consumption:
		return 0.0
	else: 
		var dmg = floor(randf_range(stats["intelligence"], 2*stats["intelligence"]) - target_magical_defense)
		for res_element in resistance_matrix:
			if res_element[0] == magical_element:
				match res_element[1]:
					"weak":
						dmg = dmg * 2
					"resist":
						dmg = floor(dmg / 2)
					"absorb":
						dmg = -dmg
		stats["mp"] = stats["mp"] - mp_consumption
		return dmg

func heal(spell_lvl, mp_consumption):
	if stats["mp"] >= mp_consumption:
		var spell_lvl_mod = 5 * 2^(spell_lvl - 1)
		var heal_amount = floor(stats["lvl"] * spell_lvl_mod * 100 / stats["max_hp"])
		stats["hp"] += heal_amount
		if stats["hp"] > stats["max_hp"]:
			stats["hp"] = stats["max_hp"]

# status blind, weak
func hit_chance(is_magical, magical_element, target_status, resistance_matrix):
	var accuracy = 100
	if status == "blind":
		accuracy -= 40
	if target_status == "blind":
		accuracy += 40
	for resistance in resistance_matrix:
		if resistance[0] == magical_element:
			accuracy -= 40
			
	var is_mag_attack = 0.25*stats["magic_defence"] if is_magical == true else 1
	var hit = 100*stats["agility"]*is_mag_attack / 256
	
	return true if hit < accuracy else false

func set_lvl_stats():
	for stat_key in stats.keys():
		match stat_key:
			"hp":
				stats["hp"]+= stats["lvl"]*(stats["stamina"]/4)
			"max_hp": 
				stats["max_hp"]+= stats["lvl"]*(stats["stamina"]/4)
			"mp":
				stats["mp"]+= (stats["lvl"]/5)*(stats["intelligence"]/4)
			"max_mp":
				stats["mp"]+= (stats["lvl"]/5)*(stats["intelligence"]/4)
			_:
				stats[stat_key] += 2 + randi_range(0,1)

func end_turn():
	pass
