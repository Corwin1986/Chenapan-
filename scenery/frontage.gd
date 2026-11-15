extends Node2D
## A single quad with perspective-correct UV interpolation: no sliced facade.
var g
var points=PackedVector2Array()
var uv=PackedVector2Array()
var texture=preload("res://assets/facades_v23.png")
func _ready():
	texture_repeat=CanvasItem.TEXTURE_REPEAT_DISABLED
	texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	var mat=ShaderMaterial.new()
	mat.shader=preload("res://scenery/frontage.gdshader")
	material=mat
func configure(side: int, near_z: float,far_z: float,kind: int):
	var n=maxf(0.25,near_z)
	var height=385.0
	points=PackedVector2Array([g.street_project(side*1.53,n,height),g.street_project(side*1.53,far_z,height),g.street_project(side*1.53,far_z),g.street_project(side*1.53,n)])
	var original_t=(n-near_z)/(far_z-near_z)
	var u0=(float(kind%4)+(original_t if side<0 else 1.0-original_t))/4.0
	var u1=(float(kind%4)+(1.0 if side<0 else 0.0))/4.0
	var v0=float(kind/4)/2.0
	var v1=v0+0.5
	uv=PackedVector2Array([Vector2(u0,v0),Vector2(u1,v0),Vector2(u1,v1),Vector2(u0,v1)])
	queue_redraw()
func _draw():
	if points.size()==4:draw_polygon(points,PackedColorArray([Color.WHITE]),uv,texture)
