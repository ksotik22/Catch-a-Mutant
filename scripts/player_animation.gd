extends Node

var player: CharacterBody3D
var t: float = 0.0
var base: Dictionary = {}

func _ready() -> void:
    player = get_parent() as CharacterBody3D
    call_deferred("_capture_parts")

func _capture_parts() -> void:
    for part_name in ["Body", "Head", "Cap", "CapPeak", "Backpack", "LeftArm", "RightArm", "LeftLeg", "RightLeg"]:
        var part := player.get_node_or_null(part_name)
        if part:
            base[part_name] = {"pos": part.position, "rot": part.rotation}

func _physics_process(delta: float) -> void:
    if base.is_empty():
        return
    var moving: bool = Vector2(player.velocity.x, player.velocity.z).length() > 0.5 and player.is_on_floor()
    var airborne: bool = not player.is_on_floor()
    t += delta * (10.0 if moving else 3.0)
    var swing: float = sin(t) * (0.75 if moving else 0.06)
    var bob: float = absf(sin(t * 2.0)) * (0.09 if moving else 0.025)
    _pose("LeftArm", Vector3(swing, 0, 0), Vector3(0, bob, 0))
    _pose("RightArm", Vector3(-swing, 0, 0), Vector3(0, bob, 0))
    _pose("LeftLeg", Vector3(-swing * 0.7, 0, 0), Vector3(0, bob * 0.35, 0))
    _pose("RightLeg", Vector3(swing * 0.7, 0, 0), Vector3(0, bob * 0.35, 0))
    _pose("Body", Vector3(0, 0, -swing * 0.05), Vector3(0, bob, 0))
    _pose("Head", Vector3(0, sin(t * 0.5) * 0.035, 0), Vector3(0, bob * 0.7, 0))
    _pose("Cap", Vector3.ZERO, Vector3(0, bob * 0.7, 0))
    _pose("CapPeak", Vector3.ZERO, Vector3(0, bob * 0.7, 0))
    _pose("Backpack", Vector3(swing * 0.08, 0, 0), Vector3(0, bob * 0.5, 0))
    if airborne:
        _pose("LeftArm", Vector3(-0.45, 0, -0.25), Vector3(0, 0.05, 0))
        _pose("RightArm", Vector3(-0.45, 0, 0.25), Vector3(0, 0.05, 0))
        _pose("LeftLeg", Vector3(0.35, 0, 0), Vector3.ZERO)
        _pose("RightLeg", Vector3(-0.25, 0, 0), Vector3.ZERO)

func _pose(part_name: String, extra_rot: Vector3, extra_pos: Vector3) -> void:
    var part := player.get_node_or_null(part_name)
    if part == null or not base.has(part_name):
        return
    part.rotation = base[part_name]["rot"] + extra_rot
    part.position = base[part_name]["pos"] + extra_pos
