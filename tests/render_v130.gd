extends SceneTree
var g
func _initialize():call_deferred("run")
func capture(name):
 g.queue_redraw();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/scratch/57088ccfaa20/dist130/"+name+".png")
func run():
 g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true;g.language="fr"
 var n=g.notebook;n.save_path="user://daily130_visual.cfg";g.mode="notebook";n.selected_tab=3
 n.daily_completed=6;n.daily_earned=600;n.daily_best=53700;n.daily_rounds=2;n.coins=600;n.daily_bonus_claimed=false
 await capture("palmares_quotidien")
 n.daily_completed=11;n.daily_bonus_claimed=true;n.daily_earned=1900;n.coins=1900
 await capture("bonus_quotidien")
 n.selected_tab=0;n.task_cursor=14;n.values={"egg_master":34}
 await capture("defi_oeufs")
 g.mode="play";g.start_game();n.task_cursor=11;n.values={"fire_master":24}
 await capture("suivi_feu")
 g.mode="notebook";n.selected_tab=3;g.language="en";await capture("daily_en")
 print("DAILY_RENDER130_OK")
 g.free();quit()
