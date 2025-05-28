class_name EnemyClass
extends Resource

@export var picture : Texture2D
@export var minimap_picture : CompressedTexture2D

@export var animation_h_frames : int = 4
@export var animation_v_frames : int = 1

@export var base_damage  : float = 10.0
@export var move_speed  : float = 50.0
@export var damage_resist  : float = 1.0
