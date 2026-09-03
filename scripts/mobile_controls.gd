extends Control

var move_vector := Vector2.ZERO
var dragging_look := false
var last_look_pos := Vector2.ZERO
@onready var player = get_parent().get_node("Player")

func _ready() -> void:
    $Left/Up.button_down.connect(func(): move_vector.y = -1)
    $Left/Up.button_up.connect(func(): if move_vector.y < 0: move_vector.y = 0)
    $Left/Down.button_down.connect(func(): move_vector.y = 1)
    $Left/Down.button_up.connect(func(): if move_vector.y > 0: move_vector.y = 0)
    $Left/Left.button_down.connect(func(): move_vector.x = -1)
    $Left/Left.button_up.connect(func(): if move_vector.x < 0: move_vector.x = 0)
    $Left/Right.button_down.connect(func(): move_vector.x = 1)
    $Left/Right.button_up.connect(func(): if move_vector.x > 0: move_vector.x = 0)
    $Throw.pressed.connect(func(): player.throw_net())
    $Jump.pressed.connect(func(): player.mobile_jump())
    player.mobile_controls = self

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.position.x > size.x * 0.45:
            dragging_look = event.pressed
            last_look_pos = event.position
    elif event is InputEventScreenDrag and dragging_look:
        var delta := event.position - last_look_pos
        player.mobile_look(delta)
        last_look_pos = event.position
