extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr('FAIL: '+msg)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
 for pair in [[19999,1.0],[20000,1.2],[29999,1.2],[30000,1.5],[40000,1.5],[70000,1.5]]:
  g.score=pair[0]
  var base=1.0+1.8*g.score/(g.score+2500.0)
  check(is_equal_approx(g.enemy_speed_multiplier()/base,pair[1]),'Movement at '+str(g.score))
  check(g.max_active_enemies()==20 if g.score>=30000 else g.max_active_enemies()>0,'Cap threshold')
 for pair in [[39999,16],[40000,24],[50000,36],[60000,54],[70000,81]]:
  g.score=pair[0];g.spawn_group_remainder=0;var total=0
  for i in range(16):total+=g.next_enemy_group_size()
  check(total==pair[1],'Exact cumulative group average at '+str(g.score))
 g.start_game();g.score=40000;g.enemy_spawn_clock=0
 g.update_enemy_spawns(0.01);var n=g.enemies.size();check(n==1,'First fractional wave')
 g.enemy_spawn_clock=0;g.update_enemy_spawns(0.01)
 check(g.enemies.size()==n+2,'Two simultaneous entries in second wave')
 n=g.enemies.size();g.update_enemy_spawns(0.01);check(g.enemies.size()==n,'No burst between intervals')
 g.dogs_timer=1;g.update_enemy_spawns(100);check(g.enemies.size()==n,'Dogs pause groups')
 g.start_game();check(g.spawn_group_remainder==0,'New game resets fractions')
 print('PROGRESSION_V17_FAILURES=',failures);g.free();quit(1 if failures else 0)
