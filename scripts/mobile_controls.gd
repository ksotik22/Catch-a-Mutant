extends Control

var move_vector := Vector2.ZERO
var dragging_look := false
var last_look_pos := Vector2.ZERO
@onready var player = get_parent().get_node("Player")

func _ready() -> void:
    $Left/Up.button_down.connect(_up_down)
    $Left/Up.button_up.connect(_up_up)
    $Left/Down.button_down.connect(_down_down)
    $Left/Down.button_up.connect(_down_up)
    $Left/Left.button_down.connect(_left_down)
    $Left/Left.button_up.connect(_left_up)
    $Left/Right.button_down.connect(_right_down)
    $Left/Right.button_up.connect(_right_up)
    $Throw.pressed.connect(_throw_pressed)
    $Jump.pressed.connect(_jump_pressed)
    player.mobile_controls = self

func _up_down() -> void:
    move_vector.y = -1.0

func _up_up() -> void:
    if move_vector.y < 0.0:
        move_vector.y = 0.0

func _down_down() -> void:
    move_vector.y = 1.0

func _down_up() -> void:
    if move_vector.y > 0.0:
        move_vector.y = 0.0

func _left_down() -> void:
    move_vector.x = -1.0

func _left_up() -> void:
    if move_vector.x < 0.0:
        move_vector.x = 0.0

func _right_down() -> void:
    move_vector.x = 1.0

func _right_up() -> void:
    if move_vector.x > 0.0:
        move_vector.x = 0.0

func _throw_pressed() -> void:
    player.throw_net()

func _jump_pressed() -> void:
    player.mobile_jump()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.position.x > size.x * 0.45:
            dragging_look = event.pressed
            last_look_pos = event.position
    elif event is InputEventScreenDrag and dragging_look:
        var look_delta: Vector2 = event.position - last_look_pos
        player.mobile_look(look_delta)
        last_look_pos = event.position
