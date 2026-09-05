extends Node

signal catches_changed(total: int)
signal coins_changed(total: int)
signal net_level_changed(level: int)
signal collection_changed()
signal bank_changed(total: int)

var catches: int = 0
var coins: int = 0
var stored_value: int = 0
var net_level: int = 1
var collection: Array[Dictionary] = []
var base_slots: int = 4
var bank_coins: int = 0
var income_fraction: float = 0.0

func _ready() -> void:
    load_game()

func _process(delta: float) -> void:
    var income := get_income_per_second()
    if income <= 0:
        return
    income_fraction += float(income) * delta
    if income_fraction >= 1.0:
        var earned := int(floor(income_fraction))
        income_fraction -= float(earned)
        bank_coins += earned
        bank_changed.emit(bank_coins)

func add_catch(value: int = 10, creature_data: Dictionary = {}) -> void:
    catches += 1
    stored_value += value
    if not creature_data.is_empty() and collection.size() < base_slots:
        collection.append(creature_data.duplicate(true))
        collection_changed.emit()
    catches_changed.emit(catches)
    save_game()

func get_income_per_second() -> int:
    var total := 0
    for mutant in collection:
        total += int(mutant.get("income", 1))
    return total

func collect_bank() -> int:
    var amount := bank_coins
    if amount <= 0:
        return 0
    bank_coins = 0
    coins += amount
    bank_changed.emit(bank_coins)
    coins_changed.emit(coins)
    save_game()
    return amount

func sell_all() -> int:
    var sold := catches
    if sold <= 0:
        return 0
    coins += stored_value
    catches = 0
    stored_value = 0
    catches_changed.emit(catches)
    coins_changed.emit(coins)
    save_game()
    return sold

func next_net_price() -> int:
    if net_level == 1:
        return 50
    if net_level == 2:
        return 150
    return 0

func buy_net_upgrade() -> bool:
    var price := next_net_price()
    if price <= 0 or coins < price:
        return false
    coins -= price
    net_level += 1
    coins_changed.emit(coins)
    net_level_changed.emit(net_level)
    save_game()
    return true

func save_game() -> void:
    var data := {
        "coins": coins,
        "net_level": net_level,
        "collection": collection,
        "base_slots": base_slots,
        "bank_coins": bank_coins
    }
    var file := FileAccess.open("user://save.json", FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(data))

func load_game() -> void:
    if not FileAccess.file_exists("user://save.json"):
        return
    var file := FileAccess.open("user://save.json", FileAccess.READ)
    if file == null:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        coins = int(parsed.get("coins", 0))
        net_level = int(parsed.get("net_level", 1))
        base_slots = int(parsed.get("base_slots", 4))
        bank_coins = int(parsed.get("bank_coins", 0))
        collection.clear()
        var saved_collection = parsed.get("collection", [])
        if saved_collection is Array:
            for item in saved_collection:
                if item is Dictionary:
                    collection.append(item)
