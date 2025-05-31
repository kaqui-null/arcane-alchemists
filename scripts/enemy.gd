extends Node2D
# hp = hp + (stamina/4)*lvl + if(lvl is div by 5) add 30
# mp = mp + (intelligence/4)*(lvl/2) + if(lvl is div by 10) add 30
# other = +2 per lvl + rand(0,2) each per lvl (for now)

# accuracy = 100 + 40(if target blind) - 40(if attacker blind) + 40(if target is weak)
# hit = 100*agility*(1/4 of mag. def. if mag attack) / 256(max value) -> if accuracy > hit: hit()
# heal = (5, 10, 20, 40 by spell lvl)*lvl % of max life : cap 100%
#         1,  2,  4,  8
#         2⁰, 2¹, 2³, 2⁴
# attack_spell_dmg = floor(rand(int, 2*int) - mag. def.) * 2(if weak) * 1/2(if resist) * -1 (if absorb)

@export var stats = {}
@export var stat_keys = {}
@export var stat_values = {}

func _physics_process(delta: float) -> void:
	pass

func _init() -> void:
	file_reading()

func file_reading():
	var stat_file = FileAccess.open('res://enemy_stats/base_stats.json', FileAccess.READ)
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
