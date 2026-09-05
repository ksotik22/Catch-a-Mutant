extends Node

signal catches_changed(total: int)
signal coins_changed(total: int)

var catches: int = 0
var coins: int = 0
var stored_value: int = 0

func add_catch(value: int = 10) -> void:
    catches += 1
    stored_value += value
    catches_changed.emit(catches)

func sell_all() -> int:
    var sold := catches
    if sold <= 0:
        return 0
    coins += stored_value
    catches = 0
    stored_value = 0
    catches_changed.emit(catches)
    coins_changed.emit(coins)
    return sold
