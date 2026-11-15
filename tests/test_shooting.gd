extends SceneTree
var failures=0
var g
func check(ok: bool,msg: String):
	if not ok: failures+=1; printerr("FAIL: "+msg)
func _initialize():call_deferred("run")
func reset():
	g.start_game();g.buildings.clear();g.building_clock=999;g.pickup_clock=999
func advance(seconds: float):
	for i in range(int(round(seconds*100))):g.update_game(0.01)
func enemy(p: float,x: float) -> Dictionary:
	g.spawn_enemy(0,p,1,0)
	var e=g.enemies.back()
	# Align targets to a screen firing line; a bent street has a different centerline.
	var desired=g.road_point(x,1.0).x
	var low=-4.0;var high=4.0
	for i in range(24):
		var mid=(low+high)/2
		if g.road_point(mid,p).x<desired:low=mid
		else:high=mid
	e.x=(low+high)/2;e.lane=e.x;e.age=2;e.entry_progress=1;e.speed=0;e.frozen=100
	return e
func run():
	g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true
	reset();advance(0.49);check(g.stats.shots==0,"slightly slower initial cadence")
	advance(0.01);check(g.stats.shots==1,"first automatic shot at 0.50 seconds")
	advance(1.5);check(g.stats.shots==4,"two salvos per second without enemies")
	reset();g.apply_pickup("energy");advance(2)
	check(g.stats.shots==8,"energy precisely doubles cadence")
	check(g.stones==1 and g.element==0,"energy does not multiply projectiles or damage")
	g.apply_pickup("fire");check(is_equal_approx(g.shot_interval(),0.5),"another gift cancels rapid fire")
	g.apply_pickup("energy");g.gift_timer=0.01;advance(0.02)
	check(g.last_gift=="" and is_equal_approx(g.shot_interval(),0.5),"expiry restores normal cadence")
	reset();g.apply_pickup("energy");g.apply_pickup("soda")
	check(g.slow_timer==15 and g.shot_interval()==0.5,"soda replaces energy")
	g.apply_pickup("energy");check(g.slow_timer==0,"energy replaces soda")
	reset();g.fire_salvo();var projectile=g.bullets[0];var original_x=projectile.pos.x
	g.player_x=0.8;enemy(0.7,-0.7);g.update_projectiles(0.1)
	check(projectile.pos.x==original_x and projectile.pos.y<988,"fired rock stays straight as player and targets move")
	check(g.enemies[0].hp==3,"off-axis enemy unharmed")
	reset();var farther=enemy(0.55,0);var nearer=enemy(0.75,0)
	g.fire_salvo();g.update_projectiles(0.5)
	check(nearer.hp==2 and farther.hp==3,"segment hits nearest body only even across a long step")
	check(g.bullets.is_empty(),"rock consumed on first impact")
	reset();var e=enemy(0.65,0)
	for i in range(3):g.fire_salvo();g.update_projectiles(0.6)
	check(e.hp<=0,"three normal straight shots defeat a classic enemy")
	for kind in ["double","triple"]:
		reset();g.apply_pickup(kind);g.fire_salvo()
		check(g.bullets.size()==(2 if kind=="double" else 3),"projectile count preserved "+kind)
		var xs=[]
		for shot in g.bullets:xs.append(shot.pos.x)
		g.update_projectiles(0.05)
		for i in range(xs.size()):check(g.bullets[i].pos.x==xs[i],"all bonus projectiles parallel")
	for el in range(5):
		reset();e=enemy(0.7,0);g.element=el if el<4 else 0;g.egg=el==4
		g.fire_salvo();g.update_projectiles(0.4)
		check(is_equal_approx(e.hp,3-[1.0,3.0,1.0,2.0,0.5][el]),"straight projectile element damage %d"%el)
	reset();e=enemy(0.65,0)
	g.handle_press(g.enemy_pos(e)-Vector2(0,70),0)
	check(g.stats.shots==0 and g.drag_active,"touching enemy now controls movement, not firing")
	g.set_lane(500);g.update_game(0.05)
	var release=InputEventScreenTouch.new();release.index=0;release.pressed=false;g._unhandled_input(release)
	var x=g.player_x;g.update_game(0.1);check(g.player_x==x,"release stops movement")
	g.mode="pause";var before=g.stats.shots
	for i in range(20):g._process(0.05)
	check(g.stats.shots==before,"pause prevents firing")
	g.mode="caught";g.fire_salvo();check(g.stats.shots==before,"capture prevents firing")
	reset();g.rng.seed=47;var found=false
	for i in range(200):
		g.apply_pickup("mystery","bonus")
		if g.last_gift=="energy":found=true
	check(found,"energy obtainable in mystery gifts")
	for i in range(100):
		g.apply_pickup("mystery","malus")
		check(g.last_gift!="energy","energy never replaces a malus draw")
	print("SHOOTING_FAILURES=",failures)
	g.free();quit(1 if failures else 0)
