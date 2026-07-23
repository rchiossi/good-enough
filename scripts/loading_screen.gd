extends CanvasLayer
class_name LoadingScreen

@export var fade_duration : float = 0.5

@onready var _base_panel : PanelContainer = %BasePanel

signal transition_complete

func fade_in() -> void:
    if not is_node_ready():
        return

    _base_panel.modulate.a = 0.0
    show()

    var tween = create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_base_panel, "modulate:a", 1.0, fade_duration)
    tween.tween_callback(transition_complete.emit)

func fade_out() -> void:
    if not is_node_ready():
        return

    var tween = create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_base_panel, "modulate:a", 0.0, fade_duration)
    tween.tween_callback(queue_free)
