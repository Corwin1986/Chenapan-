extends Node2D
## Straight 500-point streets. Camera heading is constant; only junctions transition.
const POINTS_PER_STREET=500
const SECONDS_PER_STREET=50.0
const BASE_SPEED=2.0
const VISUAL_ACCELERATION=1.15
const SHOP_WIDTH=8.0
const FRONT_X=7.2
var g
var viewport: SubViewport
var world: Node3D
var scenery: Node3D
var camera: Camera3D
var doors: Array=[]
var distance=0.0
var street_index=-1
var length=0.0
var total_plots=0
var pool={}
var layouts={}
var prepared_index=-1
var previous_distance=0.0
var street_shift=0.0
var facade=preload("res://assets/facades_v24.png")
var landmarks=preload("res://assets/landmarks_v24.png")
var building_materials=preload("res://assets/building_materials_v25.png")
var horizon=preload("res://assets/village_horizon_v25.png")
var church=preload("res://assets/church_v24.png")
var front_textures: Array=[]
var wall_materials: Array=[]
var landmark_textures: Array=[]
var prop_textures: Array=[]
var road_material: StandardMaterial3D
var pavement_material: StandardMaterial3D
var roof_material: StandardMaterial3D
var sky_node: MeshInstance3D

func speed_at(seconds: float) -> float:
	return BASE_SPEED*(1.0+2.0*maxf(seconds,0.0)/(maxf(seconds,0.0)+200.0))

func travel_between(start: float,finish: float) -> float:
	return BASE_SPEED*(3.0*(finish-start)-400.0*log((finish+200.0)/(start+200.0)))

func street_length(index: int) -> float:
	return travel_between(index*SECONDS_PER_STREET,(index+1)*SECONDS_PER_STREET)

func turning() -> bool:
	return false

func transition_alpha() -> float:
	if g.time<49.84:return 0.0
	var phase=fposmod(g.time+0.16,SECONDS_PER_STREET)
	if phase>0.32:return 0.0
	return sin(PI*phase/0.32)

func destination_name(index: int) -> String:
	return ["PLACE DE LA MAIRIE","PLACE DE L’ÉCOLE","PLACE DE L’ÉGLISE"][posmod(index,3)]

func _ready():
	viewport=SubViewport.new();viewport.size=Vector2i(720,1280)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	viewport.msaa_3d=Viewport.MSAA_2X;add_child(viewport)
	world=Node3D.new();viewport.add_child(world)
	var environment=WorldEnvironment.new();var env=Environment.new()
	env.background_mode=Environment.BG_COLOR;env.background_color=Color("9ad2eb")
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color.WHITE
	env.ambient_light_energy=0.85;environment.environment=env;world.add_child(environment)
	camera=Camera3D.new();camera.fov=64;camera.far=1000;camera.near=0.2
	world.add_child(camera);camera.current=true
	cache_art()
	sync()

func cropped(tex: Texture2D, region: Rect2) -> Texture2D:
	var img=tex.get_image().get_region(Rect2i(region));img.generate_mipmaps()
	return ImageTexture.create_from_image(img)

func texture_material(tex: Texture2D,tint=Color.WHITE) -> StandardMaterial3D:
	var mat=StandardMaterial3D.new();mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture=tex;mat.albedo_color=tint;mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return mat

func solid(color: Color) -> StandardMaterial3D:
	var mat=StandardMaterial3D.new();mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;mat.albedo_color=color;return mat

func cache_art():
	road_material=texture_material(cropped(g.art_tex,Rect2(Vector2(g.art_tex.get_width()/2.0,0),g.art_tex.get_size()/2.0)))
	pavement_material=texture_material(g.sidewalk_tex)
	var cell=facade.get_size()/Vector2(4,2)
	var mat_cell=building_materials.get_size()/2
	roof_material=texture_material(cropped(building_materials,Rect2(Vector2.ZERO,mat_cell)))
	for kind in range(8):
		var origin=Vector2(kind%4,int(kind/4))*cell
		front_textures.append(cropped(facade,Rect2(origin+Vector2(0,cell.y*0.12),Vector2(cell.x,cell.y*0.88))))
		var material_origin=Vector2(1,0) if kind%2==0 else Vector2(0,1)
		wall_materials.append(texture_material(cropped(building_materials,Rect2(material_origin*mat_cell,mat_cell)),Color("e3d4bd")))
	front_textures.append(cropped(church,Rect2(Vector2(0,church.get_height()*0.28),Vector2(church.get_width(),church.get_height()*0.72))))
	wall_materials.append(texture_material(cropped(building_materials,Rect2(mat_cell,mat_cell))))
	for kind in range(2):landmark_textures.append(cropped(landmarks,Rect2(Vector2(kind*landmarks.get_width()/2.0,0),landmarks.get_size()/Vector2(2,1))))
	landmark_textures.append(church)
	for region in [Rect2(41,113,445,370),Rect2(577,91,377,381),Rect2(1053,16,448,473),Rect2(75,569,370,401),Rect2(621,552,302,425),Rect2(1074,559,379,421)]:
		prop_textures.append(cropped(g.sidewalk_props_tex,region))

func mesh_node(parent: Node3D,mesh: Mesh,mat: Material,pos=Vector3.ZERO) -> MeshInstance3D:
	var node=MeshInstance3D.new();node.mesh=mesh;node.material_override=mat;node.position=pos;parent.add_child(node);return node

func box(parent: Node3D,pos: Vector3,size: Vector3,mat: Material) -> MeshInstance3D:
	var mesh=BoxMesh.new();mesh.size=size;return mesh_node(parent,mesh,mat,pos)

func surface_quad(parent: Node3D,points: Array,uvs: Array,mat: Material) -> MeshInstance3D:
	var surface=SurfaceTool.new();surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in [0,1,2,0,2,3]:surface.set_uv(uvs[i]);surface.add_vertex(points[i])
	return mesh_node(parent,surface.commit(),mat)

func face(parent: Node3D,pos: Vector3,width: float,height: float,normal: Vector3,tex: Texture2D):
	var mesh=QuadMesh.new();mesh.size=Vector2(width,height)
	var node=mesh_node(parent,mesh,texture_material(tex),pos+Vector3.UP*height/2)
	node.rotation.y=atan2(normal.x,normal.z)

func roof(parent: Node3D,width: float,depth: float,base: float,rise: float):
	var w=width/2;var d=depth/2
	for side in [-1,1]:
		var points=[Vector3(-w,base,side*d),Vector3(w,base,side*d),Vector3(w,base+rise,0),Vector3(-w,base+rise,0)]
		surface_quad(parent,points,[Vector2(0,0),Vector2(width/3,0),Vector2(width/3,1.5),Vector2(0,1.5)],roof_material)
	for side in [-1,1]:
		var surface=SurfaceTool.new();surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for p in [Vector3(side*w,base,-d),Vector3(side*w,base,d),Vector3(side*w,base+rise,0)]:surface.add_vertex(p)
		mesh_node(parent,surface.commit(),solid(Color("dfbc8d")))

func add_awning(parent: Node3D,width: float,depth: float,kind: int):
	for i in range(8):
		var x0=-width*0.42+i*width*0.84/8;var x1=x0+width*0.84/8
		var color=Color("b34b38") if i%2==0 else Color("fff1d6")
		if kind==6 and i%2==0:color=Color("408d78")
		surface_quad(parent,[Vector3(x0,3.4,depth/2+0.03),Vector3(x1,3.4,depth/2+0.03),Vector3(x1,2.9,depth/2+0.9),Vector3(x0,2.9,depth/2+0.9)],[Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN],solid(color))
		box(parent,Vector3((x0+x1)/2,2.82,depth/2+0.9),Vector3(x1-x0,0.18,0.04),solid(color))

func build_house(parent: Node3D,pos: Vector3,normal: Vector3,kind: int,width=8.0):
	var house=Node3D.new();parent.add_child(house);house.position=pos
	house.rotation.y=atan2(normal.x,normal.z)
	var depth=6.0;var height=6.8+float(kind%3)*0.25
	# Closed building volume. The painted front is attached to a real wall.
	box(house,Vector3(0,height/2,0),Vector3(width,height,depth),wall_materials[kind])
	face(house,Vector3(0,0,depth/2+0.025),width,height,Vector3.BACK,front_textures[kind])
	roof(house,width+0.22,depth+0.5,height,2.0)
	box(house,Vector3(width*0.28,height+1.7,-0.9),Vector3(0.65,2.1,0.65),solid(Color("c58c6b")))
	box(house,Vector3(width*0.28,height+2.78,-0.9),Vector3(0.86,0.16,0.86),solid(Color("edc6a0")))
	if kind in [0,5,6]:add_awning(house,width,depth,kind)
	if kind==8:
		box(house,Vector3(0,height+2.4,0),Vector3(1.6,3.2,1.6),wall_materials[0])
		box(house,Vector3(0,height+4.6,0),Vector3(0.18,1.5,0.18),solid(Color("574434")))
		box(house,Vector3(0,height+4.8,0),Vector3(0.9,0.18,0.18),solid(Color("574434")))

func ground(parent: Node3D,x0: float,x1: float,z0: float,z1: float,y: float,mat: Material,tile=5.0):
	surface_quad(parent,[Vector3(x0,y,z0),Vector3(x1,y,z0),Vector3(x1,y,z1),Vector3(x0,y,z1)],[Vector2(x0/tile,z0/tile),Vector2(x1/tile,z0/tile),Vector2(x1/tile,z1/tile),Vector2(x0/tile,z1/tile)],mat)

func build_landmark(parent: Node3D,center: Vector3,kind: int):
	var node=Node3D.new();parent.add_child(node);node.position=center
	var width=13.0;var depth=10.0
	box(node,Vector3(0,4.2,0),Vector3(width,8.4,depth),wall_materials[kind])
	roof(node,width+0.4,depth+0.6,8.4,2.5)
	var tex: Texture2D=landmark_textures[kind]
	# Main elevation uses its actual roof silhouette, backed by a solid house.
	var points=PackedVector2Array([Vector2(0,1),Vector2(1,1),Vector2(1,0.32),Vector2(0.65,0.32),Vector2(0.65,0.13),Vector2(0.5,0),Vector2(0.35,0.13),Vector2(0.35,0.32),Vector2(0,0.32)])
	var surface=SurfaceTool.new();surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in Geometry2D.triangulate_polygon(points):
		var uv=points[index];surface.set_uv(uv);surface.add_vertex(Vector3((0.5-uv.x)*width,(1-uv.y)*13,-depth/2-0.03))
	mesh_node(node,surface.commit(),texture_material(tex))
	box(node,Vector3(0,10.2,0),Vector3(2.7,3.6,3),wall_materials[kind])
	if kind==2:
		box(node,Vector3(0,13.0,0),Vector3(0.18,1.6,0.18),solid(Color("574434")))
		box(node,Vector3(0,13.2,0),Vector3(1,0.18,0.18),solid(Color("574434")))

func add_prop(parent: Node3D,pos: Vector3,index: int,height: float):
	var tex: Texture2D=prop_textures[index]
	var node=Sprite3D.new();node.texture=tex;node.pixel_size=height/tex.get_height()
	node.billboard=BaseMaterial3D.BILLBOARD_ENABLED;node.shaded=false
	node.position=pos+Vector3.UP*height/2;parent.add_child(node)

func make_layout(index: int) -> Dictionary:
	var node=Node3D.new();world.add_child(node);node.visible=false
	var layout={"node":node,"length":street_length(index),"pool":{},"jobs":[],"plaza_doors":[]}
	layout.total=maxi(9,int((layout.length-12)/SHOP_WIDTH)+1)
	layouts[index]=layout
	layout.jobs.append(func(): build_ground(layout))
	layout.jobs.append(func(): build_center(layout,index))
	for side in [-1,1]:
		for i in range(4):
			layout.jobs.append(func(): build_house(layout.node,Vector3(side*(15+i*8),0,layout.length+54),Vector3.FORWARD,posmod(i+index+3,8)))
		for i in range(3):
			layout.jobs.append(func(): build_house(layout.node,Vector3(side*30,0,layout.length+10+i*8),Vector3(-side,0,0),posmod(i+index,8)))
		# Real extra facades along the approach to the square provide valid entrances.
		for i in range(6):
			var z=(layout.total+i)*SHOP_WIDTH
			var kind=posmod(index+i+(4 if side>0 else 0),9)
			layout.jobs.append(func(): build_house(layout.node,Vector3(side*(FRONT_X+3),0,z),Vector3(-side,0,0),kind))
			layout.plaza_doors.append({"kind":kind,"s":z,"world":Vector3(side*(FRONT_X-0.06),0,z),"side":side,"plot":layout.total+i})
		layout.jobs.append(func():
			add_prop(layout.node,Vector3(side*10,0,layout.length+18),2,8)
			add_prop(layout.node,Vector3(side*14,0,layout.length+8),0,1.6)
			add_prop(layout.node,Vector3(side*9,0,layout.length+11),5,1.7))
	layout.jobs.append(func(): build_sky(layout))
	for plot in range(-3,mini(layout.total,int(ceil(minf(320,layout.length)/SHOP_WIDTH))+1)):
		layout.jobs.append(func(): build_row(layout,index,plot))
	return layout

func build_ground(layout: Dictionary):
	ground(layout.node,-200,200,-50,layout.length+160,-0.06,pavement_material)
	ground(layout.node,-4.8,4.8,-30,layout.length+45,0.01,road_material,6.0)
	for side in [-1,1]:
		ground(layout.node,side*4.8,side*FRONT_X,-30,layout.length+8,0.07,pavement_material,3)
		box(layout.node,Vector3(side*4.9,0.06,(layout.length-22)/2),Vector3(0.15,0.15,layout.length+38),solid(Color("b7a38a")))

func build_center(layout: Dictionary,index: int):
	var plaza_center=Vector3(0,0,layout.length+26)
	ground(layout.node,-34,34,layout.length+2,layout.length+60,0.03,pavement_material,4)
	# The roundabout is an actual circular island, approached head-on.
	var island=CylinderMesh.new();island.top_radius=8.5;island.bottom_radius=8.5;island.height=0.22;island.radial_segments=48
	mesh_node(layout.node,island,solid(Color("ddc7a6")),plaza_center+Vector3.UP*0.11)
	build_landmark(layout.node,plaza_center,index%3)

func build_sky(layout: Dictionary):
	# Painted skyline lives beyond the plaza in the same world, never a blank void.
	var backdrop_width=maxf(360,(layout.length+110)*1.7)
	var mesh=QuadMesh.new();mesh.size=Vector2(backdrop_width,backdrop_width/3)
	var skyline=mesh_node(layout.node,mesh,texture_material(horizon),Vector3(0,20,layout.length+110))
	skyline.rotation.y=PI

func build_row(layout: Dictionary,index: int,plot: int):
	if layout.pool.has(plot):return
	var row=Node3D.new();layout.node.add_child(row);layout.pool[plot]=row
	var z=plot*SHOP_WIDTH
	for side in [-1,1]:
		var kind=posmod(plot+(4 if side>0 else 0)+index,9)
		build_house(row,Vector3(side*(FRONT_X+3),0,z),Vector3(-side,0,0),kind)
		if plot%2==0:add_prop(row,Vector3(side*6.1,0,z+2),1,1.1)
		if plot%5==0:add_prop(row,Vector3(side*5.9,0,z-2),0,1.5)
		if plot%7==2:add_prop(row,Vector3(side*6.0,0,z+2),2,6.0)
		if plot%9==4:add_prop(row,Vector3(side*5.8,0,z+1),3 if side<0 else 4,0.7)

func rebuild(index: int):
	var layout=layouts.get(index,{})
	if layout.is_empty():layout=make_layout(index)
	# Only a new game / direct test jump needs synchronous completion.
	while not layout.jobs.is_empty():layout.jobs.pop_front().call()
	for key in layouts.keys():
		if key!=index:
			layouts[key].jobs.clear();layouts[key].node.visible=false;layouts[key].node.queue_free();layouts.erase(key)
	scenery=layout.node;scenery.visible=true
	street_index=index;length=layout.length;total_plots=layout.total;pool=layout.pool
	camera.far=maxf(1000,length+300)
	prepared_index=-1

func prepare_next():
	if fposmod(g.time,SECONDS_PER_STREET)<35.0:return
	var index=street_index+1
	if not layouts.has(index):make_layout(index)
	var layout=layouts[index]
	if not layout.jobs.is_empty():layout.jobs.pop_front().call()
	if layout.jobs.is_empty():prepared_index=index

func refresh_houses():
	var first=maxi(-3,int(floor((distance-22)/SHOP_WIDTH)))
	var last=mini(total_plots-1,int(ceil((distance+minf(320,length))/SHOP_WIDTH)))
	for key in pool.keys():
		if key<first or key>last:
			pool[key].free();pool.erase(key)
	doors.assign(layouts[street_index].plaza_doors)
	for plot in range(first,last+1):
		var s=plot*SHOP_WIDTH
		if not pool.has(plot):build_row(layouts[street_index],street_index,plot)
		for side in [-1,1]:
			var kind=posmod(plot+(4 if side>0 else 0)+street_index,9)
			doors.append({"kind":kind,"s":s,"world":Vector3(side*(FRONT_X-0.06),0,s),"side":side,"plot":plot})

func sync():
	if camera==null:return
	var index=maxi(0,int(g.time/SECONDS_PER_STREET))
	street_shift=0.0
	if index!=street_index:
		street_shift=length if street_index>=0 else 0.0
		rebuild(index)
	var start=index*SECONDS_PER_STREET
	var current=clampf(g.time,start,start+SECONDS_PER_STREET)
	distance=travel_between(start,current)
	camera.position=Vector3(0,8.5,distance-8)
	camera.look_at(Vector3(0,0,distance+14),Vector3.UP)
	refresh_houses()
	prepare_next()
	queue_redraw()

func project(pos: Vector3) -> Vector2:
	return camera.unproject_position(pos)

func actor_point(x: float,p: float) -> Vector2:
	return project(Vector3(-x*4.3,0,distance+(1-p)*30))

func visible_doors() -> Array:
	var result: Array=[]
	for door in doors:
		var ahead=door.s-distance
		if ahead<18 or ahead>38:continue
		var feet=project(door.world)
		if feet.x<20 or feet.x>700 or feet.y<260 or feet.y>950:continue
		var item=door.duplicate();item.p=1-ahead/30.0;item.x=-door.side*FRONT_X/4.3;item.feet=feet;item.world_z=door.s
		result.append(item)
	return result

func _draw():
	if viewport!=null:draw_texture_rect(viewport.get_texture(),Rect2(0,0,720,1280),false)

func _exit_tree():
	for layout in layouts.values():layout.jobs.clear()
