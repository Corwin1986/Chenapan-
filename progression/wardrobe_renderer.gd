extends RefCounted
# Runtime wardrobe: source artwork stays immutable. Texture caches rebuild only on equipment changes.
var notebook_ref: WeakRef
var n:
 get:return notebook_ref.get_ref()
var textures={}
var images={}
var bounds={}
var hero_cache={}
var item_images={}
func setup(notebook):
 notebook_ref=weakref(notebook)
 for cat in n.CATEGORIES+["hats_worn","costumes_run"]:
  var image=load("res://assets/wardrobe/"+cat+".png").get_image()
  image.decompress();image.convert(Image.FORMAT_RGBA8)
  # Suppress negligible matte opacity from the generated atlas at render time.
  if cat in ["costumes","costumes_run","hats_worn"]:
   for y in image.get_height():
    for x in image.get_width():
     var c=image.get_pixel(x,y)
     if c.a<0.12:image.set_pixel(x,y,Color.TRANSPARENT)
  images[cat]=image;textures[cat]=ImageTexture.create_from_image(image)
func invalidate():hero_cache.clear()
func region(cat: String,index: int) -> Rect2i:
 var key=cat+str(index)
 if bounds.has(key):return bounds[key]
 var cols=2 if cat=="hats" else 4
 var rows=4 if cat=="backpacks" else 7 if cat in ["hats","hats_worn"] else 5
 var im=images[cat]
 # Boundaries computed independently avoid losing fractional last-column pixels.
 var x0=int((index%cols)*im.get_width()/float(cols))
 var y0=int((index/cols)*im.get_height()/float(rows))
 var x1=int((index%cols+1)*im.get_width()/float(cols))
 var y1=int((index/cols+1)*im.get_height()/float(rows))
 if cat=="hats_worn":
  var rows_y=[0,216,416,598,775,945,1112,1312]
  y0=rows_y[index/4];y1=rows_y[index/4+1]
 var box=Rect2i(x0,y0,x1-x0,y1-y0)
 var tile=im.get_region(box)
 var used=tile.get_used_rect()
 if cat=="hats_worn":
  var bitmap=BitMap.new();bitmap.create_from_image_alpha(tile,0.2)
  var largest=0.0
  for polygon in bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO,tile.get_size()),1.0):
   var b=Rect2(polygon[0],Vector2.ZERO)
   for point in polygon:b=b.expand(point)
   if b.get_area()>largest:largest=b.get_area();used=Rect2i(b.grow(1)).intersection(Rect2i(Vector2i.ZERO,tile.get_size()))
 if used.size.x<1 or used.size.y<1:used=Rect2i(0,0,box.size.x,box.size.y)
 bounds[key]=Rect2i(box.position+used.position,used.size)
 return bounds[key]
func item_image(item: Dictionary) -> Image:
 if not item_images.has(item.id):item_images[item.id]=images[item.category].get_region(region(item.category,item.sprite))
 return item_images[item.id]
func draw_item(item: Dictionary,rect: Rect2):
 if item.is_empty():return
 var cat=item.category
 var index=int(item.sprite)*(2 if cat=="costumes" else 1)
 var source=region(cat,index)
 var scale=minf(rect.size.x/source.size.x,rect.size.y/source.size.y)
 var size=Vector2(source.size)*scale
 n.g.draw_texture_rect_region(textures[cat],Rect2(rect.position+(rect.size-size)/2,size),source)
func garment_sample(item: Dictionary,u: float,v: float) -> Color:
 var im=item_image(item)
 # Sample the fabric interior, avoiding background around sleeves and shoe pairs.
 var q=Vector2(clampf(u,0,1),clampf(v,0,1))
 var lo=Vector2(0.24,0.32);var hi=Vector2(0.76,0.91)
 if item.category=="shorts":lo=Vector2(0.08,0.40);hi=Vector2(0.43,0.82)
 elif item.category=="shoes":lo=Vector2(0.12,0.40);hi=Vector2(0.49,0.79)
 var px=Vector2i(int(lerpf(im.get_width()*lo.x,im.get_width()*hi.x,q.x)),int(lerpf(im.get_height()*lo.y,im.get_height()*hi.y,q.y)))
 px.x=clampi(px.x,0,im.get_width()-1);px.y=clampi(px.y,0,im.get_height()-1)
 var color=im.get_pixelv(px)
 if color.a<0.7:color=im.get_pixel(int(im.get_width()*0.32),int(im.get_height()*0.62))
 return color
func hero_texture(original: Texture2D,selection: Dictionary) -> Texture2D:
 if selection.shorts=="" and selection.tops=="" and selection.shoes=="" and selection.hats=="" and selection.get("backpacks","")=="":return original
 var key=selection.shorts+":"+selection.tops+":"+selection.shoes+":"+selection.hats+":"+selection.get("backpacks","")
 if hero_cache.has(key):return hero_cache[key]
 var im=original.get_image();im.decompress();im.convert(Image.FORMAT_RGBA8)
 var cell=Vector2i(im.get_width()/4,im.get_height()/3)
 for index in [0,1,11]:
  var origin=Vector2i(index%4,index/4)*cell
  for y in range(cell.y):
   for x in cell.x:
    var c=im.get_pixelv(origin+Vector2i(x,y))
    if c.a<0.1:continue
    var q=Vector2(float(x)/cell.x,float(y)/cell.y)
    if selection.hats!="" and q.y < (0.285 if index==1 else 0.335):
     im.set_pixelv(origin+Vector2i(x,y),Color.TRANSPARENT)
     continue
    # Recolour the original shoulder straps to match the selected bag.
    # The back-facing bag itself is rendered over the original pack below.
    if selection.get("backpacks","")!="" and q.y>0.36 and q.y<0.72 and c.h>0.08 and c.h<0.20 and c.s>0.45 and c.v>0.35:
     var bag_color=garment_sample(n.item_by_id(selection.backpacks),0.5,0.55)
     var shade=clampf(c.v/0.9,0.45,1.1)
     im.set_pixelv(origin+Vector2i(x,y),Color(bag_color.r*shade,bag_color.g*shade,bag_color.b*shade,c.a))
    var cat="";var uv=Vector2.ZERO
    if selection.tops!="" and q.y>=0.47 and q.y<0.73 and (c.h<0.065 or c.h>0.97) and c.s>0.35 and c.v>0.25:
     cat="tops";uv=Vector2((q.x-0.37)/0.29,(q.y-0.49)/0.19)
    elif selection.shorts!="" and q.y>=0.59 and q.y<0.82 and c.h>0.40 and c.h<0.57 and c.s>0.30 and c.v>0.15:
     cat="shorts";uv=Vector2((q.x-0.2)/0.6,(q.y-0.63)/0.16)
    elif selection.shoes!="" and q.y>0.73 and c.h>0.08 and c.h<0.20 and c.s>0.45 and c.v>0.35:
     cat="shoes";uv=Vector2(q.x,(q.y-0.76)/0.2)
    if cat!="":
     var color=garment_sample(n.item_by_id(selection[cat]),uv.x,uv.y)
     var shade=clampf(c.v/0.9,0.45,1.1)
     im.set_pixelv(origin+Vector2i(x,y),Color(color.r*shade,color.g*shade,color.b*shade,c.a))
 var texture=ImageTexture.create_from_image(im)
 # Bounded cache so browsing an entire wardrobe never accumulates hundreds of atlases.
 if hero_cache.size()>=6:hero_cache.clear()
 hero_cache[key]=texture
 return texture
func draw_hero(index: int,feet: Vector2,height: float,tint: Color=Color.WHITE,angle: float=0.0,selection: Dictionary={},gait: float=-1.0):
 if selection.is_empty():selection=n.equipped
 var g=n.g
 g.draw_set_transform(feet,angle)
 if selection.costumes!="":
  var item=n.item_by_id(selection.costumes)
  # Same two-frame timing/index as the original hero (0 / 11).
  # Both frames are redrawn poses: arms, legs and right-hand slingshot.
  var running=gait>=0 and index!=1
  var cat="costumes_run" if running else "costumes"
  var source=run_region(item.sprite,index) if running else region(cat,item.sprite*2+(0 if index==1 else 1))
  var width=height*source.size.x/float(source.size.y)
  g.draw_texture_rect_region(textures[cat],Rect2(-width/2,-height,width,height),source,tint)

 else:
  var texture=hero_texture(g.character_tex,selection)
  var cell=texture.get_size()/Vector2(4,3)
  var source=Rect2(Vector2(index%4,int(index/4))*cell,cell)
  var width=height*cell.x/cell.y
  g.draw_texture_rect_region(texture,Rect2(-width/2,-height,width,height),source,tint)
  if selection.get("backpacks","")!="" and index!=1:
   var bag=n.item_by_id(selection.backpacks)
   var src=region("backpacks",bag.sprite)
   # Each original run pose retains its own body/arms; only replace the pack.
   var w=height*0.40
   var h=w*src.size.y/float(src.size.x)
   var pack_x=height*(0.025 if index==0 else 0.045)
   var pack_bottom=-height*0.29
   g.draw_texture_rect_region(textures.backpacks,Rect2(pack_x-w/2,pack_bottom-h,w,h),src,tint)
  if selection.hats!="":
   var hat=n.item_by_id(selection.hats)
   var src=region("hats_worn",hat.sprite*2+(0 if index==1 else 1))
   # Fit the head, not the surrounding hair silhouette. Side handles/ears can overhang.
   var widths=[0.66,0.59,0.65,0.60,0.62,0.62,0.71,0.73,0.60,0.60,0.60,0.62,0.62,0.65]
   var w=height*widths[hat.sprite]
   var h=w*src.size.y/float(src.size.x)
   var head_x=height*(0.01 if index==1 else -0.025 if index==0 else 0.035)
   var brim_y=-height*(0.70 if index==1 else 0.65)
   var anchor=1.0
   var hat_image=images.hats_worn
   for yy in range(src.size.y-1,-1,-1):
    if hat_image.get_pixel(src.position.x+src.size.x/2,src.position.y+yy).a>0.2:
     anchor=float(yy)/src.size.y;break
   g.draw_texture_rect_region(textures.hats_worn,Rect2(head_x-w/2,brim_y-h*anchor,w,h),src,tint)
 g.draw_set_transform(Vector2.ZERO)

var locked_cache={}
func draw_locked(item: Dictionary,rect: Rect2):
 # Deliberately destroy detail; neither design nor name is revealed before purchase.
 if not locked_cache.has(item.id):
  var im=item_image(item).duplicate()
  im.resize(3,3,Image.INTERPOLATE_LANCZOS)
  im.resize(64,64,Image.INTERPOLATE_BILINEAR)
  locked_cache[item.id]=ImageTexture.create_from_image(im)
 n.g.draw_texture_rect(locked_cache[item.id],rect,false,Color(1,1,1,0.18))

func run_region(costume: int,index: int) -> Rect2i:
 # A common crop for both poses prevents a change in scale or foot anchor.
 var first=costume*2
 var frame=first+(1 if index==11 else 0)
 var im=images.costumes_run
 var cell=Vector2i(im.get_width()/4,im.get_height()/5)
 var origin_a=Vector2i(first%4,first/4)*cell
 var origin_b=Vector2i((first+1)%4,(first+1)/4)*cell
 var key="run_pair"+str(costume)
 if not bounds.has(key):
  var a=im.get_region(Rect2i(origin_a,cell)).get_used_rect()
  var b=im.get_region(Rect2i(origin_b,cell)).get_used_rect()
  bounds[key]=a.merge(b)
 var local=bounds[key]
 return Rect2i(Vector2i(frame%4,frame/4)*cell+local.position,local.size)
