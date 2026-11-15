extends Node2D
var g
func _draw():
	var first=int(floor(g.scroll/1.7))
	for plot in range(first+6,first-1,-1):
		var z=plot*1.7-g.scroll+1.20
		if z<0.55 or z>9.5:continue
		for side in [-1,1]:draw_street_prop(side,z,posmod(plot+(2 if side>0 else 0),6))
func draw_street_prop(side: int,z: float,index: int):
	var regions=[Rect2(41,113,445,370),Rect2(577,91,377,381),Rect2(1053,16,448,473),Rect2(75,569,370,401),Rect2(621,552,302,425),Rect2(1074,559,379,421)]
	var source: Rect2=regions[index]
	var width=55.0/z*[1.25,0.60,1.6,0.60,0.48,0.60][index]
	var feet=g.street_project(side*1.31,z)
	var height=width*source.size.y/source.size.x
	draw_texture_rect_region(g.sidewalk_props_tex,Rect2(feet.x-width/2,feet.y-height,width,height),source)

