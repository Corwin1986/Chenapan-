extends SceneTree
func _initialize():call_deferred("run")
func snapshot(g):
 var actors=[]
 for e in g.enemies:
  var copy=e.duplicate(true);copy.erase("bubble");actors.append(copy)
 return [g.mode,g.time,g.score,g.life,g.stones,g.element,g.sling_level,g.shot_interval(),g.enemy_spawn_clock,g.kills,g.stats,g.rng.state,g.pickups,actors,g.bullets,g.player_x,g.player_p,g.dogs_timer]
func run():
 var old=load("res://tests/original_main_v118.gd").new()
 var current=load("res://main.gd").new()
 root.add_child(old);root.add_child(current)
 for g in [old,current]:
  g.set_process(false);g.test_mode=true;g.start_game();g.rng.seed=123456;g.chatter_rng.seed=123
 current.notebook.save_path="user://balance_test.cfg"
 var failures=0
 for i in range(3600):
  for g in [old,current]:
   if i%100==0:g.player_x=g.LANES[(i/100)%5]
   if i in [500,1000,1500,2000,2500,3000]:g.collect_slingshot(g.sling_level+1)
   if i==800:g.apply_pickup("fire")
   if i==1800:g.apply_pickup("egg")
   if i==2200:g.collect_special("dogs");g.use_special(0)
   if g.life<30:g.life=100
   g.mode="play";g.update_game(0.05)
  current.notebook.tick(0.05)
  if snapshot(old)!=snapshot(current):
   failures+=1;printerr("Balance diverged on frame ",i);break
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(current.notebook.save_path+suffix):DirAccess.remove_absolute(current.notebook.save_path+suffix)
 print("BALANCE_FAILURES=",failures," frames=3600 seed=123456")
 old.queue_free();current.queue_free();await process_frame;quit(failures)
