extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr('FAIL: '+msg)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
 # Sweep all streets and actual entrance projections; no door drought at a plaza.
 var no_doors=0;var max_gap=0.0;var gap=0.0
 for i in range(1800):
  g.time=i*0.1;g.score=int(g.time)*10;g.street.sync()
  if g.visible_doors().is_empty():gap+=0.1;no_doors+=1
  else:gap=0
  max_gap=maxf(max_gap,gap)
  if i in [490,990,1490]:check(g.street.prepared_index==g.street.street_index+1,'Next street fully prepared before crossing')
 check(no_doors==0,'Continuous eligible real doors across all three places: '+str(no_doors))
 print('MAX_DOOR_GAP_SECONDS=',max_gap)
 # Keep a living entrant across the 500-point boundary without jumping backwards.
 g.start_game();g.time=49.95;g.score=490;g.street.sync();g.enemies.clear();g.shoot_clock=999;g.pickup_clock=999
 g.spawn_from_door(g.visible_doors()[0],0)
 var e=g.enemies.back();var before=g.enemy_pos(e);var old_p=e.p
 g.invincible=999;g.update_game(0.1)
 check(e.hp>0 and g.enemies.has(e),'Active entrant survives street switch')
 check(g.enemy_pos(e).distance_to(before)<100,'No teleport on change of street')
 check(e.p>old_p,'Enemy keeps approaching through the transition')
 # World motion and frozen gait, no persistent frozen animation bounce.
 var z=e.world_z;g.update_game(0.1);check(e.world_z<z,'Enemy actually advances in world coordinates')
 e.frozen=3;var phase=e.run_phase;z=e.world_z;g.update_game(0.1)
 check(is_equal_approx(e.world_z,z) and is_equal_approx(e.run_phase,phase),'Frozen enemy and gait stop together')
 # High score controls and scenery remain bounded; spawn respects spaced arrivals.
 g.score=100000;check(g.player_speed()<6.0,'Lateral motion remains controllable');check(g.street.speed_at(10000)<6.0,'Scenery speed bounded')
 g.time=10000;g.street.sync();g.enemies.clear();g.enemy_spawn_clock=0
 g.update_enemy_spawns(0.01);var spawned=g.stats.spawned
 g.update_enemy_spawns(0.1);check(g.stats.spawned==spawned,'No doorway burst below 0.32 seconds')
 print('FLOW_V27_FAILURES=',failures)
 g.free();quit(1 if failures else 0)
