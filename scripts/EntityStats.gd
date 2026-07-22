extends Resource
class_name EntityStats

@export var name : String

@export var max_health : int
@export var max_armor : int
@export var max_shield :int

var health : int
var armor : int
var shield : int

func init() -> void:
    health = max_health
    armor = max_armor
    shield = max_shield


