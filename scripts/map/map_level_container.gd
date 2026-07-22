class_name MapLevelScene extends VBoxContainer

var node_scene: PackedScene = preload("uid://dytp76daenoys")
var level_id: int = 0

func _init(id: int = 0) -> void:
    level_id = id
    alignment = BoxContainer.ALIGNMENT_CENTER

func _ready():
    var button_group = ButtonGroup.new()
    button_group.pressed.connect(node_selected)
    for n in GameState.map[level_id]["nodes"].keys():
        var node: MapChoiceButton = node_scene.instantiate()
        node.set_type(GameState.map[level_id]["nodes"][n]["type"])
        node.button_group = button_group
        add_child(node)
        var separator = HSeparator.new()
        separator.custom_minimum_size.y = 128
        add_child(separator)
        if GameState.map[level_id]["status"] == 0:
            node.disabled = true

func node_selected(button: MapChoiceButton):
    print("[%s] selected" % [level_id, ])
    GameState.map[level_id]["status"]  = 0
    button.on_pressed()
