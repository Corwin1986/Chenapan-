extends SceneTree
var g
func _initialize():call_deferred("run")
func capture(name):
 g.queue_redraw();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/scratch/57088ccfaa20/dist128/"+name+".png")
func run():
 g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true;g.language="fr"
 var n=g.notebook;n.save_path="user://bags128_test.cfg";n.owned=[];n.coins=777;n.purchased_equipment=n.equipped.duplicate()
 assert(n.catalog.size()==98);assert(n.items_for("backpacks").size()==14)
 g.mode="notebook";n.selected_tab=1
 n.handle_book(n.category_rect(4).get_center());assert(n.category_index==4 and n.preview_back)
 n.shop_index=13;await capture("sacs_boutique")
 n.handle_book(Vector2(350,1115));assert(n.selected_tab==2 and n.dress_item().id=="backpacks_13")
 n.handle_book(Vector2(350,950));assert(n.equipped.backpacks=="backpacks_13")
 await capture("sac_champignon_dos")
 n.handle_book(Vector2(450,805));assert(not n.preview_back)
 await capture("sac_champignon_face")
 for i in 14:
  var id="backpacks_%02d"%i
  assert(n.equip_item(id));assert(n.equipped.backpacks==id);assert(n.coins==777 and n.owned.is_empty())
  assert(n.renderer.region("backpacks",i).size.x>20)
 assert(n.save_data())
 var cfg=ConfigFile.new();assert(cfg.load(n.save_path)==OK)
 assert(cfg.get_value("collection","coins")==777)
 assert(cfg.get_value("collection","owned").is_empty())
 assert(cfg.get_value("collection","equipped").get("backpacks","")=="")
 n.equip_item("backpacks_00");g.start_game();g.anim=0.05;await capture("sac_passoire_course_a")
 g.anim=0.22;await capture("sac_passoire_course_b")
 for lang in ["en","es","zh"]:
  g.language=lang;g.mode="notebook";n.selected_tab=1;await capture("boutique_"+lang)
 print("BAGS128_OK: 14 equippable bags, categories/hits, front-back, trial save isolated")
 g.free();quit()
