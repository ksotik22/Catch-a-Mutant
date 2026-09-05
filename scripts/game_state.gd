extends Node

signal catches_changed(total: int)
signal coins_changed(total: int)
signal net_level_changed(level: int)

var catches: int = 0
var coins: int = 0
var stored_value: int = 0
var net_level: int = 1

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
    return true
