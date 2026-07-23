extends Control
@onready var label: Label = $ColorRect/Label
@onready var accept_button: Button = $ColorRect/AcceptButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    label.text = "Unionized Bandits

You stumble upon a gang of bandits picketing instead of pillaging.

<<Fair pay for fair plunder>>

Their leader hands you a pamphlet.
You gain +1 on your shield"
