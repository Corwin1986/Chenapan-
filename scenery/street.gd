extends Node2D
var g
var fronts: Array=[]
var props
func _ready():
	for i in range(20):
		var f=preload("res://scenery/frontage.gd").new()
		f.g=g
		add_child(f)
		fronts.append(f)
	props=preload("res://scenery/props.gd").new()
	props.g=g
	add_child(props)
func sync():
	var first=int(floor(g.scroll/1.7))
	var index=0
	for plot in range(first+7,first-1,-1):
		var near_z=plot*1.7-g.scroll+0.55
		var far_z=near_z+1.7
		if far_z<0.55 or near_z>10.5:continue
		for side in [-1,1]:
			var f=fronts[index]
			f.visible=true
			f.configure(side,near_z,far_z,g.street_kind(plot,side))
			index+=1
	for i in range(index,fronts.size()):fronts[i].visible=false
	props.queue_redraw()
	queue_redraw()

func _draw():
	texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
	draw_rect(Rect2(0,0,720,1280),g.SKY)
	# Distant horizon stays stable; all nearby street edges move in perspective.
	var half=g.art_tex.get_size()/2
	draw_texture_rect_region(g.art_tex,Rect2(0,-200,720,720),Rect2(Vector2.ZERO,half))
	# Road texture never receives the g.scrolling distance.
	for band in range(100):
		var y0=260.0+band*10.2
		var y1=y0+10.2
		var z0=420.0/(y0-210)
		var z1=420.0/(y1-210)
		var road=PackedVector2Array([g.street_project(-1.12,z0),g.street_project(1.12,z0),g.street_project(1.12,z1),g.street_project(-1.12,z1)])
		var v0=0.28+(y0-260.0)/1020.0*0.72
		var v1=0.28+(y1-260.0)/1020.0*0.72
		var w0=minf(0.5,0.05+(v0-0.27)*0.9)*0.9
		var w1=minf(0.5,0.05+(v1-0.27)*0.9)*0.9
		var uv=PackedVector2Array([Vector2(0.5-w0,v0),Vector2(0.5+w0,v0),Vector2(0.5+w1,v1),Vector2(0.5-w1,v1)])
		draw_polygon(road,PackedColorArray([Color.WHITE]),uv,g.fixed_road_tex)
		for side in [-1,1]:
			var pavement=PackedVector2Array([g.street_project(side*1.12,z0),g.street_project(side*4,z0),g.street_project(side*4,z1),g.street_project(side*1.12,z1)])
			var pavement_uv=PackedVector2Array([Vector2(0,(z0+g.scroll)/2),Vector2(3,(z0+g.scroll)/2),Vector2(3,(z1+g.scroll)/2),Vector2(0,(z1+g.scroll)/2)])
			draw_polygon(pavement,PackedColorArray([Color(1.1,1.07,1.0)]),pavement_uv,g.sidewalk_tex)
	for side in [-1,1]:
		draw_line(g.street_project(side*1.12,8.4),g.street_project(side*1.12,0.39),Color("80694f"),4,true)
