extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr('FAIL: '+msg)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
 # Movement assertions superseded by test_routes_v19.gd.
 g.enemies.clear();var lanes={}
 for i in range(30):
  var side=-1 if i%2 else 1
  var lane=g.choose_entry_lane(side)
  check(lane*side>=0,'Entry never crosses entire road')
  lanes[lane]=true;g.spawn_enemy(0,0.2,side,0);g.enemies.back().lane=lane;g.wave+=1
 check(lanes.size()==5,'Traffic distributed over all lanes')
 g.start_game();g.score=5000
 var old=g.enemy_spawn_interval();g.collect_slingshot(1)
 check(is_equal_approx(g.enemy_spawn_interval(),old),'Upgrade grace')
 g.spawn_upgrade_age=8;check(is_equal_approx(g.enemy_spawn_interval(),old),'Eight seconds grace')
 g.spawn_upgrade_age=13;var middle=g.enemy_spawn_interval()
 g.spawn_upgrade_age=18;check(g.enemy_spawn_interval()<middle and middle<old,'Ten second gradual ramp')
 var normal=g.enemy_spawn_interval();g.apply_pickup('energy');check(g.enemy_spawn_interval()==normal,'Energy does not increase spawns')
 g.start_game();g.score=29999
 for i in range(g.max_active_enemies()):g.spawn_enemy(0,0.2,-1,0)
 g.enemy_spawn_clock=0;var n=g.enemies.size();g.update_enemy_spawns(1)
 check(g.enemies.size()==n,'Count cap before 30000')
 g.score=30000;check(g.max_active_enemies()==20,'Cap remains at 30000')
 g.update_enemy_spawns(1);check(g.enemies.size()==n,'Full board blocks arrivals')
 g.enemies.pop_back();g.enemy_spawn_clock=0;g.update_enemy_spawns(1)
 check(g.enemies.size()==n,'Free place refilled')
 g.start_game();g.enemy_spawn_clock=10;g.update_enemy_spawns(0.01)
 check(g.enemy_spawn_clock<=1,'Empty screen refill within one second')
 for i in range(11):g.update_enemy_spawns(0.1)
 check(g.enemies.size()>0,'Empty screen gets an arrival')
 g.start_game();check(g.spawn_upgrade_age==18 and g.sling_level==0,'Reset difficulty')
 print('BALANCE_V16_FAILURES=',failures);g.free();quit(1 if failures else 0)
