extends Node

func mat(hex: String, roughness := 0.82) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(hex)
    m.roughness = roughness
    return m

func box(parent: Node, name_: String, pos: Vector3, size: Vector3, material: Material, rot := Vector3.ZERO) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = name_
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh.material = material
    n.mesh = mesh
    n.position = pos
    n.rotation_degrees = rot
    parent.add_child(n)
    return n

func sphere(parent: Node, name_: String, pos: Vector3, scale_: Vector3, material: Material) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = name_
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 16
    mesh.rings = 8
    mesh.material = material
    n.mesh = mesh
    n.position = pos
    n.scale = scale_
    parent.add_child(n)
    return n

func cylinder(parent: Node, name_: String, pos: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = name_
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius * 1.05
    mesh.height = height
    mesh.radial_segments = 12
    mesh.material = material
    n.mesh = mesh
    n.position = pos
    parent.add_child(n)
    return n

func sign_label(parent: Node, text_: String, pos: Vector3, color_: Color, size_: int) -> void:
    var l := Label3D.new()
    l.text = text_
    l.position = pos
    l.font_size = size_
    l.modulate = color_
    l.outline_size = 10
    l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    l.no_depth_test = true
    parent.add_child(l)

func palm_cluster(parent: Node, pos: Vector3, s: float, wood: Material, leaf: Material, leaf2: Material) -> void:
    var trunk := cylinder(parent, "ConceptPalmTrunk", pos + Vector3(0, 1.8 * s, 0), 0.22 * s, 3.7 * s, wood)
    trunk.rotation_degrees.z = -7.0
    for i in 7:
        var a := float(i) * (360.0 / 7.0)
        var material := leaf if i % 2 == 0 else leaf2
        var frond := box(parent, "ConceptPalmLeaf", pos + Vector3(sin(deg_to_rad(a)) * 0.9 * s, 3.75 * s, cos(deg_to_rad(a)) * 0.9 * s), Vector3(0.42 * s, 0.10 * s, 2.5 * s), material, Vector3(-12, a, 0))
        frond.rotation_degrees.z += 4.0

func _ready() -> void:
    call_deferred("build")

func build() -> void:
    var root := get_tree().current_scene
    if root == null or root.has_node("ConceptUpgradeDone"):
        return
    var marker := Node.new()
    marker.name = "ConceptUpgradeDone"
    root.add_child(marker)

    var grass := mat("58b947")
    var grass_dark := mat("238b3a")
    var leaf := mat("1f9b46")
    var leaf_light := mat("65bd3d")
    var wood := mat("81502f")
    var wood_light := mat("b06b39")
    var cream := mat("f5dfad")
    var coral := mat("e85c45")
    var cyan := mat("2ba6c9")
    var navy := mat("294f63")
    var stone := mat("78878b")
    var stone_light := mat("a1aa9f")
    var sand := mat("e6c681")
    var flower_pink := mat("ed7591")
    var flower_yellow := mat("f2cf54")
    var white := mat("f4f0df")

    # Softer light: keep the sunny tropical look without blown highlights.
    var sun := root.get_node_or_null("Sun")
    if sun is DirectionalLight3D:
        sun.light_energy = 0.72
        sun.light_color = Color("fff0d5")
        sun.shadow_enabled = true

    var water := root.get_node_or_null("Water")
    if water is MeshInstance3D:
        water.material_override = mat("279fc1", 0.55)

    # Large readable shop signs, deliberately facing the player through billboard mode.
    box(root, "SellBigSignBoard", Vector3(-7, 4.25, 2.55), Vector3(4.3, 1.0, 0.28), wood)
    sign_label(root, "ПРОДАЖА", Vector3(-7, 4.25, 2.36), Color("fff4cf"), 48)
    box(root, "UpgradeBigSignBoard", Vector3(7, 4.25, 2.55), Vector3(4.8, 1.0, 0.28), navy)
    sign_label(root, "УЛУЧШЕНИЯ", Vector3(7, 4.25, 2.36), Color("fff4cf"), 42)

    # Roof trim and hanging shop decorations.
    for x in [-8.5, -7.5, -6.5, -5.5]:
        box(root, "SellRoofTrim", Vector3(x, 3.15, 2.8), Vector3(0.86, 0.20, 1.0), coral if int(x * 2) % 2 == 0 else white, Vector3(-8, 0, 0))
    for x in [5.5, 6.5, 7.5, 8.5]:
        box(root, "UpgradeRoofTrim", Vector3(x, 3.15, 2.8), Vector3(0.86, 0.20, 1.0), cyan if int(x * 2) % 2 == 0 else white, Vector3(-8, 0, 0))

    # Denser tropical framing around the plaza.
    var palm_positions := [Vector3(-14,0,-1), Vector3(14,0,-1), Vector3(-11,0,-12), Vector3(11,0,-12), Vector3(-14,0,10), Vector3(14,0,10)]
    for i in palm_positions.size():
        palm_cluster(root, palm_positions[i], 1.0 + float(i % 2) * 0.14, wood, leaf, leaf_light)

    var bush_positions := [Vector3(-11,0.55,5),Vector3(-9,0.5,7),Vector3(11,0.55,5),Vector3(9,0.5,7),Vector3(-7,0.5,-9),Vector3(7,0.5,-9),Vector3(-12,0.5,-7),Vector3(12,0.5,-7)]
    for i in bush_positions.size():
        sphere(root, "ConceptBush%d" % i, bush_positions[i], Vector3(2.1, 1.05, 1.55), leaf if i % 2 == 0 else leaf_light)

    # Layered rock groups make the shoreline less empty and geometric.
    var rock_positions := [Vector3(-15,0.3,4),Vector3(-14,0.3,-7),Vector3(-10,0.25,-14),Vector3(10,0.25,-14),Vector3(15,0.3,-6),Vector3(15,0.3,6)]
    for i in rock_positions.size():
        sphere(root, "ConceptRockA%d" % i, rock_positions[i], Vector3(3.0, 1.35, 2.2), stone)
        sphere(root, "ConceptRockB%d" % i, rock_positions[i] + Vector3(1.5,0.1,0.8), Vector3(1.7, 1.0, 1.35), stone_light)

    # Flower beds along the main path.
    var flower_positions := [Vector3(-3.0,0.34,7),Vector3(3.0,0.34,7),Vector3(-3.7,0.34,4.5),Vector3(3.7,0.34,4.5),Vector3(-4.3,0.34,1.8),Vector3(4.3,0.34,1.8)]
    for i in flower_positions.size():
        sphere(root, "ConceptFlower%d" % i, flower_positions[i], Vector3(0.42,0.42,0.42), flower_pink if i % 2 == 0 else flower_yellow)
        sphere(root, "FlowerLeaves%d" % i, flower_positions[i] + Vector3(0,-0.15,0), Vector3(0.7,0.25,0.7), grass_dark)

    # Wooden plaza details: benches, barrels and market crates.
    for z in [6.5, 9.0]:
        box(root, "LeftBenchSeat", Vector3(-10,0.62,z), Vector3(2.8,0.24,0.7), wood_light)
        box(root, "LeftBenchBack", Vector3(-10,1.12,z+0.3), Vector3(2.8,0.72,0.18), wood)
        box(root, "RightBenchSeat", Vector3(10,0.62,z), Vector3(2.8,0.24,0.7), wood_light)
        box(root, "RightBenchBack", Vector3(10,1.12,z+0.3), Vector3(2.8,0.72,0.18), wood)

    for p in [Vector3(-9.6,0.45,1.8),Vector3(-8.6,0.45,1.5),Vector3(9.6,0.45,1.8),Vector3(8.6,0.45,1.5)]:
        box(root, "MarketCrate", p, Vector3(0.9,0.9,0.9), wood_light, Vector3(0,12,0))

    # A stronger lighthouse silhouette with base stones and red bands.
    cylinder(root, "LighthouseBaseRing", Vector3(0,0.28,0), 2.25, 0.5, stone)
    cylinder(root, "LighthouseRedBandLow", Vector3(0,3.15,0), 1.72, 0.38, coral)
    cylinder(root, "LighthouseRedBandHigh", Vector3(0,7.2,0), 1.58, 0.38, coral)
    for y in [4.8, 6.0]:
        box(root, "LighthouseWindowFrame", Vector3(0,y,1.76), Vector3(0.75,1.0,0.18), navy)
        box(root, "LighthouseGlass", Vector3(0,y,1.87), Vector3(0.48,0.72,0.10), cyan)

    # Clouds add depth to the otherwise flat sky.
    for i in 7:
        var x := -24.0 + float(i) * 8.0
        var z := -24.0 - float(i % 3) * 4.0
        var y := 13.0 + float(i % 2) * 2.0
        sphere(root, "CloudA%d" % i, Vector3(x,y,z), Vector3(5.0,1.4,2.0), white)
        sphere(root, "CloudB%d" % i, Vector3(x+2.5,y+0.4,z), Vector3(3.8,1.6,1.8), white)

    # Small sandy pads around shops soften the empty green field.
    box(root, "SellPad", Vector3(-7,0.08,5.0), Vector3(6.0,0.10,4.0), sand)
    box(root, "UpgradePad", Vector3(7,0.08,5.0), Vector3(6.0,0.10,4.0), sand)
