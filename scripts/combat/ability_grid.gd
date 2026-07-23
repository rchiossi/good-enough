extends GridContainer
class_name CombatAbilityGrid

const MAX_COLOUMNS = 10
const MAX_ROWS = 2

var _slots : Dictionary = {}
var _ability_scenes : Array[CombatAbilityScene] = []
var current_size : int = 0

func _ready() -> void:
    columns = MAX_COLOUMNS

    for i in range(MAX_COLOUMNS * MAX_ROWS):
        var slot = AspectRatioContainer.new()
        slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
        add_child(slot)
        _slots[i] = slot

func add_item(control_node : CombatAbilityScene):
    _slots[current_size].add_child(control_node)
    _ability_scenes.append(control_node)
    current_size += 1

func update_abilities() -> void:
    for scene : CombatAbilityScene in _ability_scenes:
        scene.update_cooldown()
