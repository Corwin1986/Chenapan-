extends SceneTree
var g
func _initialize():call_deferred("run")
func capture(name):
 g.queue_redraw();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/scratch/57088ccfaa20/dist126/"+name+".png")
func run():
 g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true;g.language="fr"
 var n=g.notebook;g.mode="notebook";n.selected_tab=2;n.dressing_open=true;n.category_index=4;n.dress_index=2
 await capture("essayage_face")
 n.handle_book(Vector2(450,805));assert(n.preview_back);assert(n.dress_index==2)
 await capture("essayage_dos")
 n.handle_book(Vector2(260,805));assert(not n.preview_back)
 n.equip_item("costumes_01");g.start_game();g.anim=PI/24
 await capture("course_a")
 g.anim=PI/8
 await capture("course_b")
 var r=n.renderer
 assert(r.costume_vertex(Vector2(0.3,0.2),120,164,PI/2)==r.costume_vertex(Vector2(0.3,0.2),120,164,3*PI/2))
 assert(r.costume_vertex(Vector2(0.3,0.95),120,164,PI/2).y!=r.costume_vertex(Vector2(0.3,0.95),120,164,3*PI/2).y)
 print("RUN_AND_TURN126_OK")
 g.free();quit()
