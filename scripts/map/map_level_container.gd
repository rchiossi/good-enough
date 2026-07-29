class_name MapLevelScene extends VBoxContainer

var node_scene: PackedScene = preload("uid://dytp76daenoys")
var null_scene: PackedScene = preload("uid://v8lop30wa1hj")
var level_id: int = 0

func _ready():
    var button_group = ButtonGroup.new()
    button_group.pressed.connect(node_selected)
    for n in GameState.map[level_id]["nodes"].keys():
        if GameState.map[level_id]["nodes"][n]["type"] == GameState.NodeTypes.Null:
            var node = null_scene.instantiate()
            add_child(node)
        else:
            var node: MapChoiceButton = node_scene.instantiate()
            GameState.nodes[Vector2i(level_id, n)] = node
            node.set_coords(Vector2i(level_id, n))
            node.button_group = button_group
            add_child(node)

func node_selected(button: MapChoiceButton):
    print("[%s] selected" % [level_id, ])
    GameState.current_position = button.coords
    GameState.current_turn = button.coords.x
    GameState.map[GameState.current_position.x]["status"]  = 0
    GameState.map[GameState.current_position.x]["nodes"][GameState.current_position.y]["visited"] = 1
    button.on_pressed()
