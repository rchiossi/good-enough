class_name MapLevelScene extends VBoxContainer

var node_scene: PackedScene = preload("uid://dytp76daenoys")
var level_id: int = 0

func _init(id: int = 0) -> void:
    level_id = id
    alignment = BoxContainer.ALIGNMENT_CENTER

func _ready():
    var button_group = ButtonGroup.new()
    button_group.pressed.connect(node_selected)
    for type in GameState.map[level_id]:
        var node = node_scene.instantiate()
        node.set_type(type)
        node.button_group = button_group
        add_child(node)
        var separator = HSeparator.new()
        separator.custom_minimum_size.y = 128
        add_child(separator)

func node_selected(button: MapChoiceButton):
    print("[%s] selected" % [level_id, ])
    button.on_pressed()
