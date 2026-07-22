class_name MapLevelScene extends VBoxContainer

var node_scene: PackedScene = preload("uid://dytp76daenoys")
var nodes_number: int = 1

func _init(nr_of_nodes: int) -> void:
    nodes_number = nr_of_nodes
    alignment = BoxContainer.ALIGNMENT_CENTER

func _ready():
    for i in range(nodes_number):
        add_child(node_scene.instantiate())
        var separator = HSeparator.new()
        separator.custom_minimum_size.y = 128
        add_child(separator)
