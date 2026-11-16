extends SceneTree
var g
func _initialize():call_deferred("run")
func capture(name):
 g.queue_redraw();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/scratch/57088ccfaa20/dist125/"+name+".png")
func run():
 g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true;g.language="fr"
 var n=g.notebook;g.mode="notebook";n.selected_tab=2;n.dressing_open=true;n.category_index=3;n.dress_index=1
 await capture("passoire")
 n.equip_item("hats_00");g.start_game()
 await capture("passoire_dos")
 g.mode="notebook";n.dress_index=9
 await capture("casquette")
 n.equipped={"shoes":"shoes_00","shorts":"shorts_03","tops":"tops_03","hats":"hats_08","costumes":""};n.category_index=2;n.dress_index=19
 await capture("vetements")
 n.equipped.tops="tops_00";n.dress_index=1
 await capture("oeuf")
 n.selected_tab=1;n.category_index=4;n.shop_index=0
 await capture("test_collection")
 g.free();print("RENDER125_OK");quit()
