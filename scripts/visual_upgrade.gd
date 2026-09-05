extends Node

func _ready() -> void:
    call_deferred("build")

func mat(color: Color, roughness := 0.78) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    return m

func box(parent: Node, name_: String, pos: Vector3, size: Vector3, material: Material, rot := Vector3.ZERO) -> MeshInstance3D:
    var n := MeshInstance3D.new(); n.name = name_
    var mesh := BoxMesh.new(); mesh.size = size; mesh.material = material
    n.mesh = mesh; n.position = pos; n.rotation_degrees = rot; parent.add_child(n); return n

func sphere(parent: Node, name_: String, pos: Vector3, scale_: Vector3, material: Material) -> MeshInstance3D:
    var n := MeshInstance3D.new(); n.name = name_
    var mesh := SphereMesh.new(); mesh.radius = 0.5; mesh.height = 1.0; mesh.radial_segments = 12; mesh.rings = 7; mesh.material = material
    n.mesh = mesh; n.position = pos; n.scale = scale_; parent.add_child(n); return n

func cylinder(parent: Node, name_: String, pos: Vector3, radius: float, height: float, material: Material, segments := 12) -> MeshInstance3D:
    var n := MeshInstance3D.new(); n.name = name_
    var mesh := CylinderMesh.new(); mesh.top_radius = radius; mesh.bottom_radius = radius * 1.07; mesh.height = height; mesh.radial_segments = segments; mesh.material = material
    n.mesh = mesh; n.position = pos; parent.add_child(n); return n

func label3d(parent: Node, text_: String, pos: Vector3, color_: Color, size_ := 52) -> Label3D:
    var l := Label3D.new(); l.text = text_; l.position = pos; l.font_size = size_; l.modulate = color_; l.outline_size = 8; l.billboard = BaseMaterial3D.BILLBOARD_ENABLED; parent.add_child(l); return l

func palm(parent: Node, pos: Vector3, s: float, wood: Material, green: Material) -> void:
    var trunk := cylinder(parent, "PalmTrunk", pos + Vector3(0, 1.8*s, 0), 0.22*s, 3.6*s, wood, 8)
    trunk.rotation_degrees.z = randf_range(-8.0, 8.0)
    for i in 6:
        var a := float(i) * 60.0
        var leaf := box(parent, "PalmLeaf", pos + Vector3(0,3.7*s,0), Vector3(0.45*s,0.14*s,2.5*s), green, Vector3(randf_range(-12,8),a,0))
        leaf.position += Vector3(sin(deg_to_rad(a))*0.8*s,0,cos(deg_to_rad(a))*0.8*s)

func lamp(parent: Node, pos: Vector3, dark: Material, yellow: Material) -> void:
    cylinder(parent,"LampPost",pos+Vector3(0,1.15,0),0.08,2.3,dark,8)
    box(parent,"LampTop",pos+Vector3(0,2.35,0),Vector3(0.48,0.18,0.48),dark)
    sphere(parent,"LampGlow",pos+Vector3(0,2.15,0),Vector3(0.42,0.48,0.42),yellow)

func build() -> void:
    var root := get_tree().current_scene
    if root == null or root.has_node("VisualUpgradeDone"): return
    var marker := Node.new(); marker.name = "VisualUpgradeDone"; root.add_child(marker)

    var cream := mat(Color("ffd98c")); var dark := mat(Color("202b35")); var white := mat(Color("fff6df"))
    var red := mat(Color("e94732")); var blue := mat(Color("168ee0")); var wood := mat(Color("70401f"))
    var wood_light := mat(Color("a7642f")); var green := mat(Color("21a83d")); var light_green := mat(Color("65cc39"))
    var orange := mat(Color("ff922e")); var pink := mat(Color("ff6f91")); var yellow := mat(Color("ffd447"))
    var rock := mat(Color("697780")); var rock_light := mat(Color("8b969b")); var sand := mat(Color("efc86e"))

    # Explorer character.
    var player := root.get_node_or_null("Player")
    if player:
        var old_mesh := player.get_node_or_null("Mesh"); if old_mesh: old_mesh.visible = false
        sphere(player,"Body",Vector3(0,0.05,0),Vector3(0.9,1.15,0.68),blue)
        sphere(player,"Head",Vector3(0,1.0,0),Vector3(0.72,0.72,0.68),cream)
        box(player,"Cap",Vector3(0,1.4,-0.05),Vector3(0.78,0.18,0.72),dark)
        box(player,"CapPeak",Vector3(0,1.35,-0.42),Vector3(0.58,0.10,0.38),dark)
        box(player,"Backpack",Vector3(0,0.18,0.5),Vector3(0.7,0.78,0.3),red)
        sphere(player,"LeftArm",Vector3(-0.58,0.12,0),Vector3(0.25,0.72,0.25),cream)
        sphere(player,"RightArm",Vector3(0.58,0.12,0),Vector3(0.25,0.72,0.25),cream)
        sphere(player,"LeftLeg",Vector3(-0.24,-0.72,0),Vector3(0.3,0.65,0.34),dark)
        sphere(player,"RightLeg",Vector3(0.24,-0.72,0),Vector3(0.3,0.65,0.34),dark)

    # Cat mutant.
    var creature := root.get_node_or_null("CatLoaf")
    if creature:
        var cm := creature.get_node_or_null("Mesh"); if cm: cm.visible = false
        sphere(creature,"LoafBody",Vector3.ZERO,Vector3(1.45,0.9,1.0),orange)
        sphere(creature,"Face",Vector3(0,0.28,-0.58),Vector3(0.78,0.72,0.45),orange)
        box(creature,"EarL",Vector3(-0.34,0.78,-0.55),Vector3(0.28,0.42,0.18),orange,Vector3(0,0,-22))
        box(creature,"EarR",Vector3(0.34,0.78,-0.55),Vector3(0.28,0.42,0.18),orange,Vector3(0,0,22))
        sphere(creature,"EyeL",Vector3(-0.22,0.38,-0.82),Vector3(0.13,0.16,0.08),dark)
        sphere(creature,"EyeR",Vector3(0.22,0.38,-0.82),Vector3(0.13,0.16,0.08),dark)
        sphere(creature,"Nose",Vector3(0,0.17,-0.87),Vector3(0.13,0.1,0.07),pink)

    # Lighthouse becomes the island centerpiece.
    cylinder(root,"LighthouseBalcony",Vector3(0,8.9,0),1.65,0.24,red,16)
    cylinder(root,"LanternRoom",Vector3(0,9.55,0),1.08,1.15,white,16)
    cylinder(root,"LanternGlow",Vector3(0,9.58,0),0.82,0.72,yellow,16)
    cylinder(root,"LanternRoof",Vector3(0,10.35,0),1.48,0.34,red,16)
    for i in 8:
        var a := float(i)*45.0
        var p := Vector3(sin(deg_to_rad(a))*1.4,9.35,cos(deg_to_rad(a))*1.4)
        cylinder(root,"Rail",p,0.045,0.75,dark,6)
    box(root,"Door",Vector3(0,1.12,2.0),Vector3(1.12,1.9,0.2),wood)
    box(root,"DoorAwning",Vector3(0,2.18,2.08),Vector3(1.55,0.25,0.65),red,Vector3(-12,0,0))
    box(root,"Window",Vector3(0,5.05,1.69),Vector3(0.68,0.9,0.13),blue)

    # Bigger shop facades with striped awnings, counters, crates and signs.
    box(root,"SellFront",Vector3(-7,1.35,3.13),Vector3(3.5,1.5,0.2),white)
    box(root,"SellCounter",Vector3(-7,1.0,3.55),Vector3(4.0,0.38,0.78),wood)
    for i in 5:
        box(root,"SellStripe",Vector3(-8.4+i*0.7,2.42,3.48),Vector3(0.68,0.25,0.9),red if i%2==0 else white,Vector3(-10,0,0))
    box(root,"SellSign",Vector3(-7,3.75,1.48),Vector3(3.2,0.8,0.25),wood)
    label3d(root,"МАГАЗИН",Vector3(-7,3.75,1.31),Color.WHITE,38)
    box(root,"UpgradeFront",Vector3(7,1.35,3.13),Vector3(3.5,1.5,0.2),white)
    box(root,"UpgradeCounter",Vector3(7,1.0,3.55),Vector3(4.0,0.38,0.78),wood)
    for i in 5:
        box(root,"UpgradeStripe",Vector3(5.6+i*0.7,2.42,3.48),Vector3(0.68,0.25,0.9),blue if i%2==0 else white,Vector3(-10,0,0))
    box(root,"UpgradeSign",Vector3(7,3.75,1.48),Vector3(3.5,0.8,0.25),wood)
    label3d(root,"УЛУЧШЕНИЯ",Vector3(7,3.75,1.31),Color.WHITE,32)

    # Rocky coast around the island.
    var rocks := [Vector3(-14,0.4,10),Vector3(-15,0.3,5),Vector3(-14,0.35,-7),Vector3(-10,0.35,-14),Vector3(12,0.4,-13),Vector3(15,0.35,-6),Vector3(15,0.35,7),Vector3(12,0.4,13)]
    for i in rocks.size():
        sphere(root,"CoastRock%d"%i,rocks[i],Vector3(2.8,1.8,2.1),rock if i%2==0 else rock_light)

    # Palms and dense tropical greenery.
    var palms := [Vector3(-12,0,-3),Vector3(12,0,-2),Vector3(-9,0,-11),Vector3(8,0,-12),Vector3(-13,0,9),Vector3(12,0,10)]
    for i in palms.size(): palm(root,palms[i],0.9+float(i%3)*0.12,wood,green)
    var bushes := [Vector3(-10,0.65,4),Vector3(10,0.65,4),Vector3(-6,0.65,-9),Vector3(5,0.65,-12),Vector3(12,0.65,-11),Vector3(-13,0.65,11),Vector3(-5,0.65,6),Vector3(5,0.65,6)]
    for i in bushes.size(): sphere(root,"Bush%d"%i,bushes[i],Vector3(1.7,0.9,1.35),green if i%2==0 else light_green)
    var flowers := [Vector3(-4,0.5,7),Vector3(4,0.5,8),Vector3(-9,0.5,-4),Vector3(9,0.5,-5),Vector3(-6,0.5,-7),Vector3(6,0.5,-8)]
    for i in flowers.size():
        sphere(root,"Flower%d"%i,flowers[i],Vector3(0.32,0.32,0.32),pink if i%2==0 else yellow)

    # Harbor/pier on the front-left side.
    for i in 6: box(root,"PierBoard%d"%i,Vector3(-11.0-float(i)*1.0,-0.05,12.5),Vector3(0.92,0.24,4.2),wood_light)
    for x in [-10.5,-13.0,-15.5]:
        cylinder(root,"PierPost",Vector3(x,-0.3,10.8),0.16,2.2,wood,8)
        cylinder(root,"PierPost",Vector3(x,-0.3,14.2),0.16,2.2,wood,8)
    box(root,"BoatHull",Vector3(-15.5,-0.25,16.0),Vector3(3.0,0.65,1.45),red,Vector3(0,-18,0))
    box(root,"BoatCabin",Vector3(-15.5,0.35,15.8),Vector3(1.3,0.85,1.05),white,Vector3(0,-18,0))

    # Plaza furniture, lights and fencing.
    lamp(root,Vector3(-3.3,0,5.5),dark,yellow); lamp(root,Vector3(3.3,0,5.5),dark,yellow)
    lamp(root,Vector3(-5.0,0,-5.0),dark,yellow); lamp(root,Vector3(5.0,0,-5.0),dark,yellow)
    box(root,"BenchSeat",Vector3(9,0.65,8),Vector3(3.0,0.28,0.7),wood)
    box(root,"BenchBack",Vector3(9,1.15,8.3),Vector3(3.0,0.75,0.22),wood)
    box(root,"NoticeBoard",Vector3(10,1.7,-8),Vector3(3.5,2.2,0.28),wood)
    cylinder(root,"NoticePostL",Vector3(8.6,0.7,-8),0.12,2.2,wood,8); cylinder(root,"NoticePostR",Vector3(11.4,0.7,-8),0.12,2.2,wood,8)
    for p in [Vector3(-8,0.55,6),Vector3(8,0.55,6),Vector3(-8,0.55,-5),Vector3(8,0.55,-5)]:
        cylinder(root,"FencePost",p,0.12,1.1,wood,8)

    # Crates and barrels make shops feel occupied.
    for p in [Vector3(-9.6,0.6,3.0),Vector3(-9.2,0.5,4.2),Vector3(9.6,0.6,3.0),Vector3(9.1,0.5,4.1)]: box(root,"Crate",p,Vector3(1.05,1.05,1.05),wood,Vector3(0,randf_range(-18,18),0))
    for p in [Vector3(-5.0,0.65,3.4),Vector3(5.0,0.65,3.4)]: cylinder(root,"Barrel",p,0.48,1.25,wood_light,10)

    # Tropical lighting.
    var world_env := WorldEnvironment.new(); world_env.name = "TropicalEnvironment"
    var env := Environment.new(); env.background_mode = Environment.BG_COLOR; env.background_color = Color("55c8f2")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color = Color("d7efff"); env.ambient_light_energy = 0.62
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world_env.environment = env; root.add_child(world_env)
