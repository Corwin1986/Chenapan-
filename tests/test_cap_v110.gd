extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr('FAIL: '+msg)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true
 for points in [0,1000,5000,30000,80000,120000]:
  g.start_game();g.score=points
  var cap=g.max_active_enemies()
  check(cap<=15,'Absolute maximum')
  for i in range(cap-1):g.spawn_enemy(0,0.2,1,0)
  g.enemy_spawn_clock=0;g.update_enemy_spawns(10)
  check(g.enemies.size()==cap,'Group clipped to one free place at '+str(points))
  for i in range(4):g.update_enemy_spawns(10)
  check(g.enemies.size()==cap,'No overflow at '+str(points))
  g.enemies[0].hp=0;g.enemies[1].hp=0;g.enemy_spawn_clock=0
  g.update_enemy_spawns(10)
  var living=0
  for e in g.enemies:
   if e.hp>0:living+=1
  check(living<=cap,'Dead actors do not consume slots')
  if points>=80000:check(living==cap,'Exactly two arrivals, excess discarded')
  var n=g.enemies.size();g.update_enemy_spawns(0.01)
  check(g.enemies.size()==n,'No instant backlog')
 g.start_game();check(g.max_active_enemies()==3,'Initial cap preserved')
 print('CAP_V110_FAILURES=',failures);g.free();quit(1 if failures else 0)
