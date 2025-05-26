extends Node2D

var exp_bar_link : ProgressBar = null
# Links to UI elements for skill representation
# When becomes uccupied link is stored in chosen_skills and chosen_passives

var skill_slots_arr : Array = []
var passive_slots_arr : Array = []

# always equals by index with corresponding slot
# ! fix ! can combine in one array
var chosen_skills : Array = []
var chosen_passives : Array = []

var free_skills : Array = [0]
var free_passives : Array = [0,1,2]

@onready var all_skills : Array = [weapon1]
@onready var all_passives : Array = [passive1,passive2,passive3]

@export var max_skill_level : int = 7
@export var max_passive_level : int = 7
@export var exp_per_level_base : float = 100.0
@export var percent_exp_per_level_increase : float = 1.2
@export var weapon1 : Node2D
@export var passive1 : PassiveStatsClass
@export var passive2 : PassiveStatsClass
@export var passive3 : PassiveStatsClass

@export var weapon_global_modifires : WeaponGlobalModifiresClass

var exp_per_level_cur : float = 100.0
var current_exp = 0.0
var current_level : int = 1

func init(skill_slots : Array, passive_slots : Array,  e_b_l : ProgressBar) -> void:
	exp_bar_link = e_b_l
	skill_slots_arr = skill_slots
	passive_slots_arr = passive_slots
	# Activate bat
	free_skills.pop_front()
	add_skill_to_slot(0, 0)

func on_save_game() -> PlayerSave_ExpWeaponSystem:
	var save_res : PlayerSave_ExpWeaponSystem = PlayerSave_ExpWeaponSystem.new()
	for i in skill_slots_arr.size():
		save_res.skill_slots_arr.push_back(skill_slots_arr[i].occupied) 
	for i in passive_slots_arr.size():
		save_res.passive_slots_arr.push_back(passive_slots_arr[i].occupied) 
	save_res.chosen_skills = chosen_skills	
	save_res.chosen_passives = chosen_passives
	save_res.free_skills = free_skills
	save_res.free_passives = free_passives
	save_res.exp_per_level_cur = exp_per_level_cur
	save_res.current_exp = current_exp
	save_res.current_level = current_level
	return save_res

func on_load_game(save_res:PlayerSave_ExpWeaponSystem) -> void:
	for i in save_res.skill_slots_arr.size():
		skill_slots_arr[i].occupied = save_res.skill_slots_arr[i]
	for i in save_res.passive_slots_arr.size():
		passive_slots_arr[i].occupied = save_res.passive_slots_arr[i]
	chosen_skills = save_res.chosen_skills	
	chosen_passives = save_res.chosen_passives
	for i in chosen_passives.size():
		passive_slots_arr[i].level_n_node.text = str(chosen_passives[i].lvl)
		passive_slots_arr[i].icon_node.texture = all_passives[chosen_passives[i].n].picture	
		all_passives[chosen_passives[i].n].current_level = chosen_passives[i].lvl
	for i in chosen_skills.size():
		skill_slots_arr[i].level_n_node.text = str(chosen_skills[i].lvl)
		skill_slots_arr[i].icon_node.texture = all_skills[chosen_skills[i].n].stats.picture
		all_skills[chosen_skills[i].n].stats.current_level = chosen_skills[i].lvl
		all_skills[chosen_skills[i].n].update_weapon_stats()		
	free_skills = save_res.free_skills
	free_passives = save_res.free_passives
	exp_per_level_cur = save_res.exp_per_level_cur
	current_exp = save_res.current_exp
	current_level = save_res.current_level
	exp_bar_link.value = current_exp

var exp_leftover : float = 0.0

func upgrade_chosen(variant) -> void:
	current_exp = exp_leftover
	exp_bar_link.value = current_exp
	
	#type = SceneControl.UpgradesTypes.NEW_PASSIVE,
	#position = free_passive_copy[i],
	#level = 1,
	#picture = all_passives[free_passive_copy[i]].picture}	
	
	match variant.type:
		SceneControl.UpgradesTypes.NEW_ABILITY:
			return # No new ability for now
		SceneControl.UpgradesTypes.NEW_PASSIVE:
			var passive_slot : int = get_free_passive_slot()
			# delete from free
			var indx = free_passives.find(int(variant.position))
			free_passives.remove_at(indx)
			# adding
			add_passive_to_slot(variant.position, passive_slot)
			# update visuals
			var passive_res : PassiveStatsClass = all_passives[variant.position]
			passive_res.current_level = 1
			update_global()
			return	
		SceneControl.UpgradesTypes.ABILITY_LVLUP:
			# chosen_skills.push_back({n = skill_node_n, lvl = 1})
			_n_for_search = variant.position
			var indx = chosen_skills.find_custom(_find_by_n)
			chosen_skills[indx].lvl = chosen_skills[indx].lvl + 1
			# update visuals
			skill_slots_arr[indx].level_n_node.text = str(chosen_skills[indx].lvl)
			# apply
			all_skills[variant.position].set_new_level(chosen_skills[indx].lvl) 
			return
		SceneControl.UpgradesTypes.PASSIVE_LVLUP:
			_n_for_search = variant.position
			var indx = chosen_passives.find_custom(_find_by_n)
			chosen_passives[indx].lvl = chosen_passives[indx].lvl + 1
			# update visuals
			passive_slots_arr[indx].level_n_node.text = str(chosen_passives[indx].lvl)					
			# apply
			var passive_res : PassiveStatsClass = all_passives[variant.position]
			passive_res.current_level = chosen_passives[indx].lvl 
			update_global()			
			return

var _n_for_search : int = 0
func _find_by_n(dat : Dictionary) -> bool:
	if dat.n == _n_for_search: return true
	else: return false

func update_global():
	weapon_global_modifires.global_damage_modifire = 1.0
	weapon_global_modifires.global_cooldown_modifire = 1.0
	weapon_global_modifires.global_scale_modifire = 1.0
	for i in all_passives.size():
		weapon_global_modifires.global_damage_modifire = weapon_global_modifires.global_damage_modifire + all_passives[i].get_damage()
		weapon_global_modifires.global_cooldown_modifire = weapon_global_modifires.global_cooldown_modifire + all_passives[i].get_speed()
		weapon_global_modifires.global_scale_modifire = weapon_global_modifires.global_scale_modifire + all_passives[i].get_scale()

	for i in all_skills.size():
		all_skills[i].update_weapon_stats()

func gain_powerup(body) -> void:
	current_exp = current_exp + 50.0
	exp_bar_link.value = current_exp
	# New level
	if current_exp >= exp_per_level_cur:
		exp_leftover = current_exp - exp_per_level_cur
		SceneControl.game_session.new_level(get_3_up_chose())

func get_3_up_chose() -> Array:
	var free_skill_copy = free_skills.duplicate()
	var free_passive_copy = free_passives.duplicate()
	var chosen_skills_copy = chosen_skills.duplicate()
	var chosen_passives_copy = chosen_passives.duplicate()
	
	# Now combine in one array to randomly chose
	var all_variants : Array = []
	
	# Check if there is free skill slots
	var free_skill_slot = get_free_skill_slot()
	if free_skill_slot >= 0 :
		for i in free_skill_copy.size():
			all_variants.push_back({type = SceneControl.UpgradesTypes.NEW_ABILITY,
				position = free_skill_copy[i],
				level = 1,
				picture = all_skills[free_skill_copy[i]].stats.picture,
				description = Settings.translate_to_local(all_skills[free_skill_copy[i]].stats.description_en,all_skills[free_skill_copy[i]].stats.description_ru)})
	# Check if there is free passive slots
	var free_passive_slot = get_free_passive_slot()
	if free_passive_slot >= 0 :	
		for i in free_passive_copy.size():
			all_variants.push_back({type = SceneControl.UpgradesTypes.NEW_PASSIVE,
				position = free_passive_copy[i],
				level = 1,
				picture = all_passives[free_passive_copy[i]].picture,
				description = Settings.translate_to_local(all_passives[free_passive_copy[i]].description_en,all_passives[free_passive_copy[i]].description_ru)})
	
	# possible skill lvlups
	for i in chosen_skills_copy.size():
		if chosen_skills_copy[i].lvl < max_skill_level:
			all_variants.push_back({type = SceneControl.UpgradesTypes.ABILITY_LVLUP,
				position = chosen_skills_copy[i].n,
				level = chosen_skills_copy[i].lvl+1, # cuz its lvlup
				picture = all_skills[chosen_skills_copy[i].n].stats.picture,
				description = Settings.translate_to_local(all_skills[chosen_skills_copy[i].n].stats.description_en,all_skills[chosen_skills_copy[i].n].stats.description_ru)})
	
	# possible passive lvlups
	for i in chosen_passives_copy.size():
		if chosen_passives_copy[i].lvl < max_skill_level:
			all_variants.push_back({type = SceneControl.UpgradesTypes.PASSIVE_LVLUP,
				position = chosen_passives_copy[i].n,
				level = chosen_passives_copy[i].lvl+1,
				picture = all_passives[chosen_passives_copy[i].n].picture,
				description = Settings.translate_to_local(all_passives[chosen_passives_copy[i].n].description_en,all_passives[chosen_passives_copy[i].n].description_ru)})			

	# now need randomly choose 3
	var variants_q = all_variants.size()
	if variants_q == 0: # No lvlups variants
		return []
		
	# 1
	var n1 : int = randi_range(0,variants_q-1)
	var var1 = all_variants[n1]
	all_variants.remove_at(n1)
	variants_q = all_variants.size()
	if variants_q == 0:
		return []
	
	# 2
	var n2 : int = randi_range(0,variants_q-1)
	var var2 = all_variants[n2]
	all_variants.remove_at(n2)
	variants_q = all_variants.size()
	if variants_q == 0:
		return []
	
	# 3
	var n3 : int = randi_range(0,variants_q-1)
	var var3 = all_variants[n3]
	all_variants.remove_at(n3)
	variants_q = all_variants.size()	

	return [var1,var2,var3]

#func add_skill_to_slot(skill_node : Node2D, slot : Dictionary) -> void:
func add_skill_to_slot(skill_node_n : int, slot_n : int) -> void:
	var skill_node = all_skills[skill_node_n]
	var slot = skill_slots_arr[slot_n]
	slot.icon_node.texture = skill_node.stats.picture
	slot.level_n_node.text = "1"
	slot.occupied = true
	chosen_skills.push_back({n = skill_node_n, lvl = 1})

func add_passive_to_slot(passive_n : int, slot_n : int) -> void:
	var passive_dat = all_passives[passive_n]
	var slot = passive_slots_arr[slot_n]
	slot.icon_node.texture = passive_dat.picture
	slot.level_n_node.text = "1"
	slot.occupied = true
	chosen_passives.push_back({n = passive_n, lvl = 1})

func get_free_skill_slot() -> int:
	var first_free_slot : int = -1 # -1 means no free slots
	
	for i in skill_slots_arr.size():
		if !skill_slots_arr[i].occupied:
			first_free_slot = i
			break
			
	return first_free_slot
	
func get_free_passive_slot() -> int:
	var first_free_slot : int = -1 # -1 means no free slots
	
	for i in passive_slots_arr.size():
		if !passive_slots_arr[i].occupied:
			first_free_slot = i
			break
			
	return first_free_slot
