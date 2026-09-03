extends CanvasLayer

@onready var catch_label: Label = $CatchLabel
@onready var game_state = get_parent().get_node("GameState")

func _ready() -> void:
    game_state.catches_changed.connect(_on_catches_changed)
    _on_catches_changed(game_state.catches)

func _on_catches_changed(total: int) -> void:
    catch_label.text = "Поймано: %d" % total
