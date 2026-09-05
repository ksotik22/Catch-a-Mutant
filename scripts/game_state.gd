extends Node

signal catches_changed(total: int)
signal coins_changed(total: int)

var catches: int = 0
var coins: int = 0
var mutant_sell_price: int = 10

func add_catch() -> void:
    catches += 1
    catches_changed.emit(catches)

func sell_all() -> int:
    var sold := catches
    if sold <= 0:
        return 0
    coins += sold * mutant_sell_price
    catches = 0
    catches_changed.emit(catches)
    coins_changed.emit(coins)
    return sold
