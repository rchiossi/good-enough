extends Control
@onready var event_text: RichTextLabel = $EventText
@onready var accept_button: Button = $ButtonContainer/AcceptButton
@onready var reject_button: Button = $ButtonContainer/RejectButton

var available_events: Array[GameEvent] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    accept_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    reject_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var index_to_remove = randi_range(0, len(GameState.player_stats.abilities.values())-1)
    var ability_1 = GameState.player_stats.abilities.values()[index_to_remove].name
    var existential_event: GameEvent = GameEvent.new()
    existential_event.text = "
        You eat a strange mushroom.
        Moments later you're wondering whether your 
        enemies are merely projections of your own
        subconscious.

        You gain +5 health but can't ever cast " + ability_1 + "."
    existential_event.accept_text = "Accept enlightment"
    existential_event.reject_text = "Purge"
    existential_event.take_action_func = Callable(existential_event_callback.bind(ability_1))
    available_events.append(existential_event)
    choose_random_event()
    # setup event

func choose_random_event():
    var event_index = randi_range(0, len(available_events)-1)
    var picked_event = available_events[event_index]
    event_text.text = picked_event.text
    accept_button.text = picked_event.accept_text
    accept_button.pressed.connect(picked_event.take_action_func)
    reject_button.text = picked_event.reject_text

func existential_event_callback(ability_to_toss: String):
    GameState.player_stats.abilities.erase(ability_to_toss)
    GameState.player_stats.health = min(GameState.player_stats.health + 5, GameState.player_stats.max_health)
    SceneLoader.load_scene("res://scenes/map/map.tscn")

func _on_reject_button_pressed() -> void:
    SceneLoader.load_scene("res://scenes/abilities_window.tscn")
