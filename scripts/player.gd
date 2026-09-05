extends CharacterBody3D

@export var speed := 7.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.003
@export var net_scene: PackedScene = preload("res://scenes/net.tscn")

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
var mobile_controls = null
var mobile_jump_requested := false

func _ready() -> void:
    if not DisplayServer.is_touchscreen_available():
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    call_deferred("_install_visual_upgrade")

func _install_visual_upgrade() -> void:
    var visual_upgrade = preload("res://scripts/visual_upgrade.gd").new()
    get_tree().current_scene.add_child(visual_upgrade)
    var concept_upgrade = preload("res://scripts/concept_upgrade.gd").new()
    get_tree().current_scene.add_child(concept_upgrade)
    var mechanics = preload("res://scripts/world_mechanics.gd").new()
    get_tree().current_scene.add_child(mechanics)
    var mutant_spawner = preload("res://scripts/mutant_spawner.gd").new()
    get_tree().current_scene.add_child(mutant_spawner)
    var shop_label_style = preload("res://scripts/shop_label_style.gd").new()
    get_tree().current_scene.add_child(shop_label_style)
    await get_tree().process_frame
    var animation_controller = preload("res://scripts/player_animation.gd").new()
    animation_controller.name = "PlayerAnimation"
    add_child(animation_controller)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-35), deg_to_rad(55))
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        throw_net()
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta

    if (Input.is_key_pressed(KEY_SPACE) or mobile_jump_requested) and is_on_floor():
        velocity.y = jump_velocity
    mobile_jump_requested = false

    var input_dir := Vector2(
        float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
        float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
    )
    if mobile_controls != null and mobile_controls.move_vector.length() > 0.0:
        input_dir = mobile_controls.move_vector.normalized()

    var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
    if direction.length() > 0.0:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, speed)
        velocity.z = move_toward(velocity.z, 0.0, speed)

    move_and_slide()

func throw_net() -> void:
    var net = net_scene.instantiate()
    get_tree().current_scene.add_child(net)
    var aim_direction := -camera.global_transform.basis.z.normalized()
    net.global_position = camera.global_position + aim_direction * 1.5
    net.direction = aim_direction

func mobile_jump() -> void:
    mobile_jump_requested = true

func mobile_look(delta: Vector2) -> void:
    rotate_y(-delta.x * mouse_sensitivity * 1.5)
    camera_pivot.rotate_x(-delta.y * mouse_sensitivity * 1.5)
    camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-35), deg_to_rad(55))
