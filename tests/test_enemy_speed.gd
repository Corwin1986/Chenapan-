extends SceneTree
var failures=0
func check(ok: bool,msg: String):
	if not ok:failures+=1;printerr("FAIL: "+msg)
func _initialize():call_deferred("run")
func run():
	var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true
	for points in [0,990,1000,1990,2000,3000,6000]:
		g.start_game();g.time=points/10.0;g.score=points;g.spawn_enemy(0,0.4,1,0)
		var e=g.enemies[0];e.entry_progress=1;e.x=0;e.lane=0.4
		var factor=pow(1.4,int(points/1000));var dt=0.001
		g.update_game(dt)
		check(is_equal_approx(e.p,0.4+dt*0.105*factor),"forward tier %d"%points)
		check(is_equal_approx(e.x,dt*factor),"lateral tier %d"%points)
		var before=e.p;e.slow=3;g.update_game(dt)
		check(is_equal_approx(e.p,before+dt*0.105*factor*0.5),"slow stacks with tier")
		before=e.p;var old_x=e.x;e.frozen=3;g.update_game(dt)
		check(e.p==before and e.x==old_x,"freeze still stops movement")
	g.start_game();g.time=99.99;g.spawn_enemy(0,0.4,1,0)
	var e=g.enemies[0];e.entry_progress=1;e.x=0;e.lane=0
	g.update_game(0.02)
	check(is_equal_approx(e.p,0.4+0.02*0.105*1.4),"existing enemy accelerates at crossing")
	g.start_game();check(g.enemy_speed_multiplier()==1,"new game resets speed")
	g.score=2000;g.spawn_enemy(0,0.4,1,0);g.time=200;g.update_game(0.1)
	check(is_equal_approx(g.enemies[0].entry_progress,0.196),"door exit also accelerated")
	print("ENEMY_SPEED_FAILURES=",failures)
	g.free();quit(1 if failures else 0)
