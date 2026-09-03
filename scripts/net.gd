extends Area3D

@export var speed := 16.0
@export var lifetime := 2.0
var direction := Vector3.ZERO

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta
    lifetime -= delta
    if lifetime <= 0.0:
        queue_free()

func _on_body_entered(body: Node) -> void:
    if body.has_method("catch_creature"):
        body.catch_creature()
        queue_free()
