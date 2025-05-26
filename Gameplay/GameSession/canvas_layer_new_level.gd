extends CanvasLayer

@onready var var1_texture = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot1
@onready var var1_label = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot1/Label
@onready var var1_label_new = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot1/Label_new
@onready var var1_label_desc = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot1/Label_Description
@onready var var1 = {}

@onready var var2_texture = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot2
@onready var var2_label = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot2/Label
@onready var var2_label_new = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot2/Label_new
@onready var var2_label_desc = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot2/Label_Description
@onready var var2 = {}

@onready var var3_texture = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot3
@onready var var3_label = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot3/Label
@onready var var3_label_new = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot3/Label_new
@onready var var3_label_desc = $Panel_NewLevel/HBoxContainer_Abilities/TextureRect_SkillSlot3/Label_Description
@onready var var3 = {}

func new_level( variants : Array ) -> void:
	if variants.size() < 3:
		return # Not enough variants
	get_tree().paused = true
	SceneControl.current_scene_state = SceneControl.MySceneState.GAME_LVLUP_PAUSE
	# Set variants
	var1 = variants[0]
	var1_texture.texture = var1.picture
	var1_label.text = str(var1.level)
	if var1.type == SceneControl.UpgradesTypes.NEW_ABILITY ||(
		var1.type == SceneControl.UpgradesTypes.NEW_PASSIVE):
		var1_label_new.visible = true
	else: var1_label_new.visible = false
	var1_label_desc.text = var1.description
	
	var2 = variants[1]
	var2_texture.texture = var2.picture
	var2_label.text = str(var2.level)
	if var2.type == SceneControl.UpgradesTypes.NEW_ABILITY ||(
		var2.type == SceneControl.UpgradesTypes.NEW_PASSIVE):
		var2_label_new.visible = true
	else: var2_label_new.visible = false
	var2_label_desc.text = var2.description
	
	var3 = variants[2]
	var3_texture.texture = var3.picture
	var3_label.text = str(var3.level)	
	if var3.type == SceneControl.UpgradesTypes.NEW_ABILITY ||(
		var3.type == SceneControl.UpgradesTypes.NEW_PASSIVE):
		var3_label_new.visible = true
	else: var3_label_new.visible = false
	var3_label_desc.text = var3.description
	
	self.visible = true

func _on_texture_rect_skill_slot_1_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		SceneControl.game_session.upgrade_chosen(var1)
		SceneControl.current_scene_state = SceneControl.MySceneState.GAME_ACTIVE
		get_tree().paused = false
		self.visible = false		
		
func _on_texture_rect_skill_slot_2_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		SceneControl.game_session.upgrade_chosen(var2)
		SceneControl.current_scene_state = SceneControl.MySceneState.GAME_ACTIVE
		get_tree().paused = false
		self.visible = false

func _on_texture_rect_skill_slot_3_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		SceneControl.game_session.upgrade_chosen(var3)
		SceneControl.current_scene_state = SceneControl.MySceneState.GAME_ACTIVE
		get_tree().paused = false
		self.visible = false
