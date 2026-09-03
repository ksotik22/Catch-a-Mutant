extends CharacterBody3D

@export var speed := 7.0
@export var jump_velocity := 7.0
@export var mouse_sensitivity := 0.003
@export var net_scene: PackedScene = preload("res://scenes/net.tscn")

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
var mobile_controls = null
var mobile_jump_requested := false

func _ready() -> void:
    if not OS.has_feature("web_android") and not OS.has_feature("web_ios") and not OS.has_feature("android") and not OS.has_feature("ios"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-45), deg_to_rad(35))
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        throw_net()
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta
    if (Input.is_action_just_pressed("jump") or mobile_jump_requested) and is_on_floor():
        velocity.y = jump_velocity
    mobile_jump_requested = false

    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if mobile_controls != null and mobile_controls.move_vector.length() > 0.0:
        input_dir = mobile_controls.move_vector.normalized()
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
    move_and_slide()

func throw_net() -> void:
    var net = net_scene.instantiate()
    get_tree().current_scene.add_child(net)
    net.global_position = global_position + Vector3(0, 1.1, 0) + (-global_transform.basis.z * 1.4)
    net.direction = -global_transform.basis.z.normalized()

func mobile_jump() -> void:
    mobile_jump_requested = true

func mobile_look(delta: Vector2) -> void:
    rotate_y(-delta.x * mouse_sensitivity * 1.5)
    camera_pivot.rotate_x(-delta.y * mouse_sensitivity * 1.5)
    camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-45), deg_to_rad(35))
