extends Control


func _on_back_button_pressed() -> void:
    SceneLoader.load_scene("res://scenes/map/map.tscn")
