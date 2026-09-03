extends Node

signal catches_changed(total: int)
var catches := 0

func add_catch() -> void:
    catches += 1
    catches_changed.emit(catches)
