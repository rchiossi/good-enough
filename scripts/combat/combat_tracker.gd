extends RefCounted
class_name CombatTracker

var _active_entity : EntityStats
var _entities : Dictionary[String, EntityStats]

var _player_stats: EntityStats

var _turn_order : Array[EntityStats]

var combat_events : Array[CombatEvent]

signal new_turn(entity_name: String)
signal enemy_turn
signal combat_ended

func is_active(entity_name: String) -> bool:
	return _active_entity && _active_entity.name == entity_name

func start_combat(entities: Dictionary[String, EntityStats], active: EntityStats):
	_active_entity = active
	_entities = entities

	for entity in entities.values():
		if entity == active:
			_turn_order.push_front(entity)
		else:
			_turn_order.push_back(entity)

		if entity.is_player:
			_player_stats = entity

		entity.damage_taken.connect(on_damage_taken.bind(entity))

func step():
	var last = _turn_order.pop_front()
	_turn_order.push_back(last)

	_active_entity = _turn_order.front()

func take_turn():
	new_turn.emit(_active_entity.name)

	if not _active_entity.is_player:
		enemy_turn.emit()

func take_action(ability_name: String, target: EntityStats):
	var ability : Ability = GameState.all_abilities[ability_name]

	ability.take_action(target)

func take_enemy_turn():
	var enemy : EntityStats = _active_entity
	var ability : Ability = enemy.abilities.values().pick_random()

	take_action(ability.name, _player_stats)

func on_damage_taken(shield_damage: int, armor_damage: int, hp_damage: int, entity: EntityStats):
	var event = CombatEvent.new()

	event.type = CombatEvent.CombatEventType.DAMAGE
	event.shield_damage = shield_damage
	event.armor_damage = armor_damage
	event.hp_damage = hp_damage

	event.target = entity

	combat_events.push_back(event)

	if _active_entity.health == 0:
		combat_ended.emit()
