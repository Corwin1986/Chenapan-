extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr(msg)
func _initialize():call_deferred("run")
func run():
 var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true
 var n=g.notebook
 n.save_path="user://test_notebook_v119.cfg"
 n.done=[];n.values={};n.equipped={"outfit":"","pack":"","sling":""};n.rounds=0
 g.start_game()
 check(n.active.size()==3,"Three initial tasks")
 n.event("kills",12)
 g.finish(false)
 check(n.values.first_steps==12,"Cumulative progress after defeat")
 var rounds=n.rounds
 g.finish(false)
 check(n.rounds==rounds,"Finish idempotent")
 g.start_game()
 check(n.values.first_steps==12,"Cumulative across rounds")
 n.event("kills",18)
 n.event("score",2000,true)
 n.event("clean",20,true)
 check(n.done.size()==3 and n.rank_index()==1,"First rank and missions")
 n.event("kills",1000)
 check(n.done.size()==3,"No mid-round cascading unlocks")
 n.equip(4);check(n.equipped.pack=="","Locked reward cannot equip")
 n.equip(1);check(n.equipped.pack=="pack_red","Unlocked reward equipped")
 var other=load("res://progression/notebook.gd").new();other.setup(g,n.save_path)
 check(other.done.size()==3 and other.equipped.pack=="pack_red","Save reload")
 g.start_game();check(n.active==["parcels","upgrade","dogs_first"],"Next trio")
 g.collect_slingshot(1);g.collect_slingshot(2)
 check(n.values.upgrade==2,"Actual sling collection hook")
 g.start_game();check(n.values.upgrade==0,"Per-round progress reset")
 for i in range(10):g.apply_pickup("double")
 g.special_slots.append("dogs");g.use_special(0)
 check(n.done.has("parcels") and n.done.has("dogs_first"),"Gift and dogs hooks")
 g.collect_slingshot(1);g.collect_slingshot(2);g.collect_slingshot(3)
 check(n.done.size()==6,"Second trio completed")
 g.start_game()
 n.clean_seconds=15.0;g.hurt();n.tick(0.1)
 check(n.clean_seconds<1.0,"Damage resets clean timer")
 n.clean_seconds=15.0;g.apply_pickup("trap");n.tick(0.1)
 check(n.clean_seconds<1.0,"Trap resets clean timer")
 var fingerprint=[g.BASE_SHOT_INTERVAL,g.shot_interval(),g.enemy_speed_multiplier(),g.max_active_enemies(),g.player_speed()]
 n.done=TASKS_ids();n.equip(3);n.equip(5)
 check(fingerprint==[g.BASE_SHOT_INTERVAL,g.shot_interval(),g.enemy_speed_multiplier(),g.max_active_enemies(),g.player_speed()],"Cosmetics never change power")
 n.refresh_active();check(n.active.is_empty() and n.rank_index()==3,"All challenges complete")
 g.mode="menu";n.intro_seen=true;g.begin_intro();check(g.mode=="play","Quick launch after intro")
 g.mode="menu";g.begin_intro(true);check(g.mode=="cinematic","Intro remains available")
 g.intro.skip();check(g.mode=="mock_ad","Existing cinematic end contract")
 for code in ["en","es","zh"]:
  g.language=code;g.mode="notebook"
  for task in n.TASKS:
   check(g.menu_translations.has(task.title.to_upper()),"Task title translated "+task.title)
   check(g.menu_translations.has(task.text),"Task text translated "+task.text)
  for reward in n.REWARDS:check(g.menu_translations.has(reward.title),"Reward translated")
 # Generated appearance leaves every non-hero cell byte-identical.
 var original=g.character_tex.get_image();original.decompress()
 var styled=n.hero_texture(g.character_tex).get_image()
 var cell=Vector2i(original.get_width()/4,original.get_height()/3)
 var head=Rect2i(Vector2i(cell.x,0),Vector2i(cell.x,int(cell.y*0.48)))
 check(original.get_region(head).get_data()==styled.get_region(head).get_data(),"Face unchanged by outfit")
 for id in range(2,11):
  var rect=Rect2i(Vector2i(id%4,id/4)*cell,cell)
  check(original.get_region(rect).get_data()==styled.get_region(rect).get_data(),"NPC unchanged "+str(id))
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(n.save_path+suffix):DirAccess.remove_absolute(n.save_path+suffix)
 print("NOTEBOOK_FAILURES=",failures)
 g.queue_free();await process_frame;quit(1 if failures else 0)
func TASKS_ids() -> Array:
 var result=[]
 for t in load("res://progression/notebook.gd").TASKS:result.append(t.id)
 return result
