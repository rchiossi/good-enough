extends Control

var level_scene: PackedScene = preload("uid://00urot6twxdg")

func _ready() -> void:
    for i in range(GameState.max_turns):
        var nr = randi() % 4 + 1
        var level = MapLevelScene.new(nr)
        %MapNodesContainer.add_child(level)
        var separator = VSeparator.new()
        separator.custom_minimum_size.x = 128
        %MapNodesContainer.add_child(separator)
    %MapNodesContainer.add_child(MapLevelScene.new(1))
