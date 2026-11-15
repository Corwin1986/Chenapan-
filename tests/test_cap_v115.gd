extends SceneTree
var failures=0
func check(ok: bool,msg: String):
	if not ok:failures+=1;printerr(msg)
func _initialize():call_deferred('run')
func run():
	var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true
	for pair in [[0,3],[500,3],[750,4],[2250,10],[39999,10],[40000,12],[49999,12],[50000,15],[80000,15],[150000,15]]:
		g.start_game();g.score=pair[0];var cap=pair[1]
		check(g.max_active_enemies()==cap,'Boundary '+str(pair[0]))
		for i in range(cap):g.spawn_enemy(0,0.2,1,0)
		g.enemy_spawn_clock=0;g.update_enemy_spawns(10)
		check(g.enemies.size()==cap,'Full board rejects new arrivals')
		g.enemies[0].hp=0;g.update_enemy_spawns(10)
		var alive=0
		for e in g.enemies:
			if e.hp>0:alive+=1
		check(alive==cap,'Only available slot refilled')
	print('CAP_V115_FAILURES=',failures);g.free();quit(1 if failures else 0)
