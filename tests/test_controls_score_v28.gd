extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr('FAIL: '+msg)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
 g.hurt();check(g.life==90,'Contact costs 10')
 g.spawn_enemy(0,0.4,1,0);var e=g.enemies.back();g.damage_enemy(e,99)
 check(g.score==100 and g.kill_points==100,'Kill grants exactly 100')
 g.damage_enemy(e,99);check(g.score==100,'Dead enemy cannot score twice')
 g.shoot_clock=999;g.pickup_clock=999;g.update_game(0.1)
 check(g.score==100,'Kill score persists on next frame')
 for i in range(7):g.spawn_enemy(0,0.4,1,0)
 var street_index=g.street.street_index;g.collect_special('dogs');g.use_special(0)
 check(g.score==800,'Dogs award 100 per victim')
 g.update_game(0.1);check(g.street.street_index==street_index,'Combat points do not teleport the street')
 g.start_game();g.shoot_clock=999;g.pickup_clock=999;g.handle_press(Vector2(360,1000))
 g.set_drag_position(Vector2(430,700));check(g.finger_depth<1 and g.finger_target>0,'Diagonal touch sets both axes')
 for i in range(20):g.update_game(0.05)
 check(g.player_p<0.9 and g.player_x>0,'Player advances and moves sideways')
 var forward=g.player_p;g.set_drag_position(Vector2(430,1100))
 for i in range(20):g.update_game(0.05)
 check(g.player_p>forward,'Player can retreat')
 g.player_p=0.7;g.finger_depth=0.7;g.player_x=0;g.finger_target=0;g.drag_active=false;g.enemies.clear();g.invincible=0;g.life=100
 g.spawn_enemy(0,0.7,1,0);e=g.enemies.back();e.x=0;e.lane=0;e.entry_progress=1
 g.update_game(0.01);check(g.life==90 and e.hp<=0,'Contact at forward position costs 10 once')
 g.update_game(0.01);check(g.life==90,'Same assailant cannot hit again')
 g.enemies.clear();g.spawn_enemy(0,1.16,1,0);e=g.enemies.back();e.x=0.8;e.entry_progress=1
 var score=g.score;g.update_game(0.01);check(g.score==score and g.life==90,'Missed enemy gives no bonus or damage')
 g.bullets.clear();g.fire_salvo();check(absf(g.bullets[0].pos.y-(g.road_point(g.player_x,g.player_p).y-82))<1,'Shots originate at moved player')
 g.pickups.clear();g.pickups.append({'p':0.7,'lane':2,'kind':'dogs','category':'bonus'});g.update_game(0.01)
 check(g.special_slots.has('dogs'),'Gift collected at forward depth')
 g.drag_active=true;g.finger_depth=1.0;var depth=g.player_p
 var release=InputEventScreenTouch.new();release.pressed=false;release.index=g.movement_finger;g._unhandled_input(release);g.update_game(0.01)
 check(g.player_p==depth,'Release stops vertical movement')
 var kept=g.score;g.mode='mock_ad';g.mock_action='continue';g.close_mock_ad();g.update_game(0.01)
 check(g.score>=kept and g.continues_used==1,'Continue preserves combat score')
 g.start_game();check(g.score==0 and g.kill_points==0 and g.player_p==1,'New round resets score and depth')
 print('CONTROLS_SCORE_V28_FAILURES=',failures)
 g.free();quit(1 if failures else 0)
