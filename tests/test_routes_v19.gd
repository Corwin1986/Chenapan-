extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr('FAIL: '+msg)
func _initialize():call_deferred('run')
func actor(g,x=-0.5,p=0.3):
 g.spawn_enemy(0,p,-1,0)
 var e=g.enemies.back();e.x=x;e.lane=x;e.entry_progress=1;e.route_velocity=0.2
 return e
func setup(g):
 g.start_game();g.player_x=0;g.player_p=1;g.shoot_clock=100;g.pickup_clock=100;g.enemy_spawn_clock=100
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true
 for points in [0,9999,10000,15000,30000,60000]:
  setup(g);g.score=points;var e=actor(g,-0.02)
  g.update_enemy_steering(e,0.2);check(e.x>0,'Crosses centre at '+str(points))
  var old=e.x;g.update_enemy_steering(e,0.2);check(e.x>old,'Continues beyond centre')
  var a=e.duplicate();var b=e.duplicate();g.player_x=-0.8;g.update_enemy_steering(a,0.2);g.player_x=0.8;g.update_enemy_steering(b,0.2)
  check(a.x==b.x,'No player attraction')
 setup(g);var e=actor(g,-0.7,0.8);g.update_enemy_steering(e,0.01)
 check(e.get('attack_state','')=='','No distant lateral charge')
 setup(g);e=actor(g,0.1,0.8);g.update_enemy_steering(e,0.01)
 check(e.get('attack_state','')=='warning','Nearby attack signalled')
 var target=e.attack_target;var old=e.x;g.update_enemy_steering(e,0.1)
 check(e.x>old,'Still runs during warning')
 g.player_x=0.8;g.update_enemy_attack(e,0.36);g.update_enemy_attack(e,0.36)
 check(e.attack_state=='done' and e.attack_target==target,'One locked charge')
 old=e.x;g.update_enemy_steering(e,0.1);check(e.x>old,'Resumes route after charge')
 setup(g);e=actor(g,-0.2,0.3);g.hit_enemy(e,0,1);old=e.x;g.update_enemy_steering(e,0.1)
 check(e.hp==2 and e.x>old,'Normal hit does not halt movement')
 e.frozen=1;old=e.x;g.update_enemy_steering(e,1);check(e.x==old,'Ice still freezes')
 for dodge in [false,true]:
  setup(g);e=actor(g,0.1,0.8);g.update_game(1.0/60)
  if dodge:g.player_x=0.8
  for i in range(60):g.update_game(1.0/60)
  check(g.life==(100 if dodge else 90),'Local charge collision/dodge '+str(dodge))
 print('ROUTES_V19_FAILURES=',failures);g.free();quit(1 if failures else 0)
