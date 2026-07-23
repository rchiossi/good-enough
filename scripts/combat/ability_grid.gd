extends GridContainer
class_name CombatAbilityGrid

const MAX_COLOUMNS = 10
const MAX_ROWS = 2

var _slots : Dictionary = {}
var current_size : int = 0

func _ready() -> void:
    columns = MAX_COLOUMNS

    for i in range(MAX_COLOUMNS * MAX_ROWS):
        var slot = AspectRatioContainer.new()
        slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
        add_child(slot)
        _slots[i] = slot

func add_item(control_node : Control):
    _slots[current_size].add_child(control_node)
    current_size += 1
