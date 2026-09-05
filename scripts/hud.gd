extends CanvasLayer

@onready var catch_label: Label = $CatchLabel
@onready var game_state = get_parent().get_node("GameState")
var coin_label: Label

func _ready() -> void:
    game_state.catches_changed.connect(_on_catches_changed)
    game_state.coins_changed.connect(_on_coins_changed)
    coin_label = Label.new()
    coin_label.position = Vector2(30, 70)
    coin_label.add_theme_font_size_override("font_size", 28)
    add_child(coin_label)
    _on_catches_changed(game_state.catches)
    _on_coins_changed(game_state.coins)

func _on_catches_changed(total: int) -> void:
    catch_label.text = "Поймано: %d" % total

func _on_coins_changed(total: int) -> void:
    coin_label.text = "Монеты: %d" % total
