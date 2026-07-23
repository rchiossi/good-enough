extends RefCounted
class_name CombatManager

# -------- STATE MACHINE -------------

enum CombatState {
    PRE_COMBAT,
    COMBAT_READY,
    WAITING_FOR_PLAYER_ACTION,
    PLAYER_ACTION_STARTED,
    PLAYER_ACTION_ENDED,
    WAITING_FOR_ENEMY_ACTION,
    ENEMY_ACTION_STARTED,
    ENEMY_ACTION_ENDED,
    COMBAT_ENDED,
}

var state : CombatState = CombatState.PRE_COMBAT

signal state_changed(state : CombatState)

func step():
    match state:
        CombatState.PRE_COMBAT:
            _change_state(CombatState.COMBAT_READY)
        CombatState.COMBAT_READY:
            _change_state(CombatState.WAITING_FOR_PLAYER_ACTION)

        CombatState.WAITING_FOR_PLAYER_ACTION:
            _change_state(CombatState.PLAYER_ACTION_STARTED)
        CombatState.PLAYER_ACTION_STARTED:
            _change_state(CombatState.PLAYER_ACTION_ENDED)
            _advance_turn()
        CombatState.PLAYER_ACTION_ENDED:
            if _check_combat_end():
                _change_state(CombatState.COMBAT_ENDED)
            else:
                _change_state(CombatState.WAITING_FOR_ENEMY_ACTION)
                _take_enemy_action()

        CombatState.WAITING_FOR_ENEMY_ACTION:
            _change_state(CombatState.ENEMY_ACTION_STARTED)
        CombatState.ENEMY_ACTION_STARTED:
            _change_state(CombatState.ENEMY_ACTION_ENDED)
            _advance_turn()
        CombatState.ENEMY_ACTION_ENDED:
            if _check_combat_end():
                _change_state(CombatState.COMBAT_ENDED)
            else:
                _change_state(CombatState.WAITING_FOR_PLAYER_ACTION)

func _change_state(_state : CombatState):
    state = _state
    state_changed.emit(state)
    print("New State: " + CombatState.keys()[state])

# -------- STATE MACHINE END -------------

var _entities : Dictionary[String, EntityStats] = {}
var _active : String
var _player : String

var _turn_order : Array[String] = []
var _turn_count : int = 0

var combat_events : Array[CombatEvent]

signal new_turn(turn_count : int)

func init_combat(entities: Dictionary[String, EntityStats], active_entity: String):
    state = CombatState.PRE_COMBAT

    _entities = entities
    _active = active_entity

    _turn_count = 0
    _turn_order = []
    for entity in entities.values():
        if entity.name == active_entity:
            _turn_order.push_front(entity.name)
        else:
            _turn_order.push_back(entity.name)
        
        if entity.is_player:
            _player = entity.name
            entity.damage_dealt.connect( _resolve_player_action)
        else:
            entity.damage_dealt.connect(_resolve_enemy_action)

    print(_turn_order)
            
    step() #Move to COMBAT_READY

func _advance_turn():
    _turn_count += 1
    var last: String = _turn_order.pop_front()
    _turn_order.push_back(last)

    _active = _turn_order.front()

    print("Turn: " + str(_turn_count) + " active: " + _active)

    new_turn.emit(_turn_count)

    step()

func start_combat() -> void:
    if state != CombatState.COMBAT_READY:
        push_error("Cannot start combat, Combat not in COMBAT_READY state")
        return

    step() # Move to WAITING_FOR_PLAYER_ACTION

func take_player_action(ability_name : String, targets : Array[String]) -> void:
    step() #Move to PLAYER_ACTION_STARTED

    var ability : Ability = GameState.all_abilities[ability_name]

    for target_name in targets:
        var target : EntityStats = _entities[target_name]
        ability.take_action(_entities[_player], target)
        # This will trigger a damage_taken signal that will call _resolve_player_action

func _resolve_player_action(source: EntityStats, target: EntityStats, shield_damage: int, armor_damage: int, hp_damage: int):
    var event = CombatEvent.new()

    event.type = CombatEvent.CombatEventType.DAMAGE
    event.shield_damage = shield_damage
    event.armor_damage = armor_damage
    event.hp_damage = hp_damage

    event.source = source
    event.target = target

    combat_events.push_back(event)

    #NOTE: Do not updage state here. The UI may still be animating

func conclude_player_action() -> void:
    if state != CombatState.PLAYER_ACTION_STARTED:
        push_error("Invalid state transition: Combat is not in PLAYER_ACTION_STARTED state")
        return

    step() #Move to PLAYER_ACTION_ENDED


func _take_enemy_action() -> void:
    step() #Move to ENEMY_ACTION_STARTED

    var enemy : EntityStats = _entities[_turn_order.front()]
    var ability : Ability = enemy.abilities.values().pick_random()
    var target : EntityStats = _entities[_player] 

    ability.take_action(enemy, target)
    # This will trigger a damage_taken signal that will call _resolve_enemy_action


func _resolve_enemy_action(source: EntityStats, target: EntityStats, shield_damage: int, armor_damage: int, hp_damage: int):
    var event = CombatEvent.new()

    event.type = CombatEvent.CombatEventType.DAMAGE
    event.shield_damage = shield_damage
    event.armor_damage = armor_damage
    event.hp_damage = hp_damage

    event.source = source
    event.target = target

    combat_events.push_back(event)

    #NOTE: Do not updage state here. The UI may still be animating


func conclude_enemy_action() -> void:
    if state != CombatState.ENEMY_ACTION_STARTED:
        push_error("Invalid state transition: Combat is not in ENEMY_ACTION_STARTED state")
        return

    step() #Move to ENEMY_ACTION_ENDED


func _check_combat_end() -> bool:
    for entity in _entities.values():
        if entity.health == 0:
            return true

    return false

func get_active_entity_name() -> String:
    return _active
    
