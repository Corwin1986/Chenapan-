extends SceneTree
var game
func _initialize():call_deferred("run")
func capture(name: String):
 game.queue_redraw()
 await process_frame;await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/scratch/57088ccfaa20/dist121/"+name+".png")
func run():
 game=load("res://main.gd").new();root.add_child(game);game.set_process(false);game.test_mode=true
 var n=game.notebook;n.save_path="user://qa120.cfg";game.language="fr";game.mode="notebook"
 n.coins=6000;n.selected_tab=0
 await capture("defi")
 game.mode="menu"
 await capture("accueil")
 game.mode="notebook"
 n.selected_tab=1;n.category_index=3;n.shop_index=0
 await capture("boutique")
 for item in n.catalog:n.owned.append(item.id)
 n.selected_tab=2;n.category_index=4;n.dress_index=1
 await capture("renard")
 n.category_index=3;n.dress_index=10
 await capture("casquette")
 n.equipped.tops="tops_03";n.equipped.shorts="shorts_03";n.equipped.shoes="shoes_08";n.equipped.hats="hats_08"
 n.category_index=2;n.dress_index=19
 await capture("mix")
 game.mode="play";game.start_game();n.equipped.costumes="costumes_09";game.queue_redraw()
 await capture("dragon_jeu")
 game.mode="notebook";game.language="zh";n.selected_tab=1;n.category_index=4;n.shop_index=9
 await capture("boutique_zh")
 game.free();quit()
