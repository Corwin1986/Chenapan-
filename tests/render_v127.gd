extends SceneTree
var g
func _initialize():call_deferred("run")
func capture(name):
 g.queue_redraw();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/scratch/57088ccfaa20/dist127/"+name+".png")
func run():
 g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true;g.language="fr"
 var n=g.notebook
 for i in 10:
  var a=n.renderer.run_region(i,0);var b=n.renderer.run_region(i,11)
  assert(a.size==b.size and a.position!=b.position)
  assert(a.size.x>20 and a.size.y>20)
  assert(n.renderer.images.costumes_run.get_region(a).get_data()!=n.renderer.images.costumes_run.get_region(b).get_data())
 n.equip_item("costumes_00");g.start_game();g.anim=0.05
 await capture("renard_pose_a")
 g.anim=0.22
 await capture("renard_pose_b")
 n.equip_item("costumes_09");g.anim=0.05
 await capture("dragon_pose_a")
 g.anim=0.22
 await capture("dragon_pose_b")
 g.mode="notebook";n.selected_tab=2;n.dressing_open=true;n.category_index=4;n.dress_index=1
 n.preview_back=false
 await capture("vestiaire_face")
 n.handle_book(Vector2(450,805));assert(n.preview_back);assert(n.dress_index==1)
 await capture("vestiaire_dos")
 print("RUN127_OK: ten costumes with two distinct synchronized poses, face/back controls unchanged")
 g.free();quit()
