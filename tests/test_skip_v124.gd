extends SceneTree
func _initialize():call_deferred("run")
func run():
 var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true
 var n=g.notebook;n.save_path="user://skip124.cfg";n.coins=900;n.task_cursor=0;n.values={"first_steps":34}
 var prior=[n.coins,n.earned,n.spent,n.total_completed,n.done.duplicate(),n.round_coins]
 assert(n.skip_task());assert(n.task_cursor==1 and n.current_value()==0)
 assert(prior==[n.coins,n.earned,n.spent,n.total_completed,n.done,n.round_coins])
 var r=load("res://progression/notebook.gd").new();r.setup(g,n.save_path);assert(r.task_cursor==1 and r.coins==900)
 n.task_cursor=10;var cycle=n.cycle;assert(n.skip_task());assert(n.task_cursor==0 and n.cycle==cycle+1)
 n.save_path="/nonexistent123/skip.cfg";assert(not n.skip_task());assert(n.task_cursor==0)
 n.save_path="user://skip124.cfg";g.mode="pause";g.handle_press(Vector2(350,845));assert(g.mode=="play" and n.task_cursor==1)
 n.event("clean",40,true);assert(n.coins==1000 and n.total_completed==prior[3]+1)
 print("SKIP124_OK");g.free();quit()
