extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr("FAIL: "+msg)
func _initialize():call_deferred("run")
func run():
 var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true
 var points_list=[0,499,500,501,749,750,999,1000,1250,3000]
 var limits=[3,3,3,3,3,4,4,5,6,13]
 for k in range(points_list.size()):
  g.start_game();g.score=points_list[k]
  check(g.max_active_enemies()==limits[k],"cap at %d"%g.score)
  for i in range(1100):g.update_enemy_spawns(0.1)
  check(g.enemies.size()==limits[k],"scheduler respects dynamic cap")
  g.enemies[0].hp=0
  var before=g.stats.spawned
  g.update_enemy_spawns(g.enemy_spawn_interval()+0.01)
  check(g.stats.spawned==before+1,"freed place replaced at current interval")
  g.enemies.clear();before=g.stats.spawned;g.update_enemy_spawns(60)
  check(g.stats.spawned==before+1,"long frame never dumps queued waves")
 g.score=600;var at600=g.enemy_spawn_interval()
 g.score=1000;check(g.enemy_spawn_interval()<at600 and g.enemy_spawn_interval()<2.5,"frequency accelerates past old floor")
 g.start_game();var peak=0
 for i in range(12000):
  g.life=100;g.invincible=10;g.update_game(1.0/60)
  var alive=0
  for e in g.enemies:
   if e.hp>0:alive+=1
  check(alive<=g.max_active_enemies(),"integration respects score cap")
  peak=maxi(peak,alive)
 check(peak>3,"actual play grows beyond original cap")
 g.start_game();check(g.max_active_enemies()==3,"new run resets limit")
 print("SPAWN_PACING_FAILURES=",failures," PEAK=",peak)
 g.free();quit(1 if failures else 0)
