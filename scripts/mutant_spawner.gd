extends Node

var root: Node3D
var creature_script = preload("res://scripts/creature.gd")

func mat(hex: String) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(hex)
    m.roughness = 0.8
    return m

func mesh_box(parent: Node3D, pos: Vector3, size_: Vector3, material: Material) -> void:
    var n := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size_
    mesh.material = material
    n.mesh = mesh
    n.position = pos
    parent.add_child(n)

func mesh_sphere(parent: Node3D, pos: Vector3, scale_: Vector3, material: Material) -> void:
    var n := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 12
    mesh.rings = 6
    mesh.material = material
    n.mesh = mesh
    n.position = pos
    n.scale = scale_
    parent.add_child(n)

func make_mutant(name_: String, pos: Vector3, body_color: String, accent_color: String, kind: int, speed_: float) -> CharacterBody3D:
    var body := CharacterBody3D.new()
    body.name = name_.replace(" ", "")
    body.position = pos
    body.collision_layer = 4
    body.collision_mask = 1
    body.set_script(creature_script)
    body.set("creature_name", name_)
    body.set("wander_speed", speed_)
    body.set("wander_radius", 4.5)

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.6
    shape.height = 1.3
    collision.shape = shape
    collision.position.y = 0.65
    body.add_child(collision)

    var main := mat(body_color)
    var accent := mat(accent_color)
    var dark := mat("343a40")
    var white := mat("f7f2df")

    match kind:
        0: # banana creature
            mesh_box(body, Vector3(0,0.65,0), Vector3(0.75,1.25,0.65), main)
            mesh_sphere(body, Vector3(0,1.35,0), Vector3(0.75,0.55,0.7), main)
            mesh_box(body, Vector3(-0.34,0.35,0), Vector3(0.18,0.55,0.25), accent)
            mesh_box(body, Vector3(0.34,0.35,0), Vector3(0.18,0.55,0.25), accent)
        1: # crab bandit
            mesh_sphere(body, Vector3(0,0.55,0), Vector3(1.45,0.75,1.0), main)
            mesh_sphere(body, Vector3(-0.9,0.65,0), Vector3(0.55,0.4,0.55), accent)
            mesh_sphere(body, Vector3(0.9,0.65,0), Vector3(0.55,0.4,0.55), accent)
            mesh_box(body, Vector3(0,0.85,-0.48), Vector3(1.0,0.18,0.12), dark)
        2: # turbo frog
            mesh_sphere(body, Vector3(0,0.55,0), Vector3(1.15,0.85,1.0), main)
            mesh_sphere(body, Vector3(-0.38,1.05,-0.3), Vector3(0.35,0.35,0.35), white)
            mesh_sphere(body, Vector3(0.38,1.05,-0.3), Vector3(0.35,0.35,0.35), white)
            mesh_box(body, Vector3(0,0.55,0.65), Vector3(0.7,0.35,0.55), accent)
        3: # shark on legs
            mesh_sphere(body, Vector3(0,0.9,0), Vector3(0.85,0.7,1.6), main)
            mesh_box(body, Vector3(-0.32,0.3,0), Vector3(0.25,0.75,0.3), accent)
            mesh_box(body, Vector3(0.32,0.3,0), Vector3(0.25,0.75,0.3), accent)
            mesh_box(body, Vector3(0,1.55,0.15), Vector3(0.12,0.7,0.65), main)
        _: # coconut
            mesh_sphere(body, Vector3(0,0.75,0), Vector3(1.0,1.0,1.0), main)
            mesh_box(body, Vector3(-0.35,0.25,0), Vector3(0.2,0.65,0.2), accent)
            mesh_box(body, Vector3(0.35,0.25,0), Vector3(0.2,0.65,0.2), accent)

    var label := Label3D.new()
    label.text = name_
    label.position = Vector3(0, 2.0, 0)
    label.font_size = 34
    label.outline_size = 8
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.no_depth_test = true
    body.add_child(label)
    root.add_child(body)
    return body

func _ready() -> void:
    call_deferred("spawn_all")

func spawn_all() -> void:
    root = get_tree().current_scene
    if root == null or root.has_node("ExtraMutantsSpawned"):
        return
    var marker := Node.new()
    marker.name = "ExtraMutantsSpawned"
    root.add_child(marker)

    make_mutant("Бананчик", Vector3(-10,1.0,-5), "f2cf43", "7abf45", 0, 2.0)
    make_mutant("Краб Бандит", Vector3(10,1.0,-5), "dc5847", "8e2e32", 1, 2.7)
    make_mutant("Жабыч Турбо", Vector3(-11,1.0,10), "56b84b", "2d7693", 2, 4.2)
    make_mutant("Акулыч на ножках", Vector3(11,1.0,10), "5a91ad", "e5c28c", 3, 3.4)
    make_mutant("Кокосыч", Vector3(13,1.0,0), "825435", "55a645", 4, 1.7)
