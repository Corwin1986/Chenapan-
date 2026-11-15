extends SceneTree
var game
func _initialize():call_deferred("run")
func capture(name):
 game.queue_redraw()
 await process_frame;await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/scratch/57088ccfaa20/dist122/"+name+".png")
func run():
 game=load("res://main.gd").new();root.add_child(game);game.set_process(false);game.test_mode=true
 var n=game.notebook;n.save_path="user://render122.cfg";game.language="fr";game.mode="notebook";n.owned.clear();n.coins=1000
 n.selected_tab=2
 await capture("vestiaire")
 n.handle_book(Vector2(350,950))
 assert(n.dressing_open)
 n.selected_tab=1;n.category_index=1;n.shop_index=0
 await capture("short")
 n.handle_book(Vector2(650,680));assert(n.shop_index==1)
 await capture("verrouille")
 n.handle_book(Vector2(350,980));assert(n.modal=="")
 n.shop_index=0;assert(n.buy(n.shop_item().id))
 n.shop_index=1
 await capture("debloque")
 n.selected_tab=2;n.dressing_open=true;n.dress_index=1
 await capture("equipement")
 assert(n.dress_options().size()==2)
 n.handle_book(Vector2(650,600));assert(n.dress_index==0)
 game.free();print("UI122_OK");quit()
