extends Node2D
# hp = hp + (stamina/4)*lvl + if(lvl is div by 5) add 30
# mp = mp + (intelligence/4)*(lvl/2) + if(lvl is div by 10) add 30
# other = +2 per lvl + rand(0,2) each per lvl (for now)

# attack -> strenght
# dmg = floor(rand(attack, 2*attack) - Defense)
# accuracy = 100 + 40(if target blind) - 40(if attacker blind) + 40(if target is weak)
# hit = 100*agility*(1/4 of mag. def. if mag attack) / 256(max value) -> if accuracy > hit: hit()
# heal = (5, 10, 20, 40 by spell lvl)*lvl % of max life : cap 100%
# attack_spell_dmg = floor(rand(int, 2*int) - mag. def.) * 2(if weak) * 1/2(if resist) * 1 (if absorb)

@export var stats = {}
@export var stat_keys = {}
@export var stat_values = {}

func _init() -> void:
	var stat_file = FileAccess.open('res://enemy_stats/base_stats.json', FileAccess.READ)
	var stat_string = stat_file.get_as_text()
	stat_file.close()
	var json = JSON.new()
	var error = json.parse(stat_string)
	if error == OK:
		stats = json.data
	
	stat_keys = stats.keys()
	stat_values = stats.values()
	
func _physics_process(delta: float) -> void:
	
	print(stat_keys)
	print(stat_values)

func attack():
	pass
	
