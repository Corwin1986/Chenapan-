extends SceneTree
var game
func _initialize():call_deferred("run")
func capture(name):
 game.queue_redraw()
 await process_frame;await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/scratch/57088ccfaa20/dist123/"+name+".png")
func run():
 game=load("res://main.gd").new();root.add_child(game);game.set_process(false);game.test_mode=true
 var n=game.notebook;n.save_path="user://render123.cfg";game.language="fr";game.mode="notebook";n.owned.clear();n.coins=1000
 n.selected_tab=1;n.category_index=0;n.shop_index=0
 await capture("grille")
 n.handle_book(n.shop_cell(1).get_center());assert(n.shop_index==0)
 n.handle_book(Vector2(350,1120));assert(n.modal=="buy");n.modal=""
 assert(n.buy(n.shop_item().id));assert(not n.shop_locked(n.items_for("shoes")[1]));assert(n.shop_locked(n.items_for("shoes")[2]))
 await capture("grille_apres_achat")
 game.mode="play";game.start_game();n.task_cursor=0;n.values.clear();n.event("kills",34)
 assert(n.current_value()==34)
 await capture("quete")
 game.free();print("UI123_OK");quit()
