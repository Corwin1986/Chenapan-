extends SceneTree
var failures=0
func check(ok: bool,msg: String):
	if not ok:failures+=1;printerr("FAIL: "+msg)
func _initialize():call_deferred("run")
func run():
	var g=load("res://main.gd").new()
	root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
	check(g.LANES.size()==5 and g.life==100,"five lanes and full health")
	g.handle_press(Vector2(360,700));g.set_lane(600);g.update_game(0.05)
	var normal=g.player_x
	g.start_game();g.apply_pickup("soda");g.handle_press(Vector2(360,700));g.set_lane(600);g.update_game(0.05)
	check(is_equal_approx(normal*1.4/3.6,g.player_x),"soda actual speed 1.4 versus 3.6")
	var release=InputEventScreenTouch.new();release.pressed=false;g._unhandled_input(release)
	var x=g.player_x;g.update_game(0.1);check(g.player_x==x,"release stops immediately")
	g.apply_pickup("double");check(g.stones==2 and g.slow_timer==0,"replacement removes soda")
	g.apply_pickup("triple");check(g.stones==3,"no multiplier stacking")
	g.apply_pickup("minus");check(g.stones==1,"minus two")
	g.start_game();g.apply_pickup("trap");check(g.life==80,"permanent trap")
	g.hurt();g.clear_effect();check(g.life==70,"no trap restoration")
	for kind in ["double","triple","fire","ice","electric","egg","soda","energy"]:
		g.start_game();g.apply_pickup(kind)
		check(g.gift_timer==15,"15 seconds "+kind)
		g.gift_timer=0.01;g.update_game(0.02)
		check(g.stones==1 and g.element==0 and not g.egg and g.slow_timer==0 and g.life==100 and g.last_gift=="","expiry "+kind)
	g.start_game();g.life=65;g.apply_pickup("heart");g.clear_effect();check(g.life==85,"heart permanent twenty")
	g.apply_pickup("heart");check(g.life==100,"heart cap")
	g.apply_pickup("trap");g.apply_pickup("double");check(g.life==80,"replacement never restores trap")

	g.life=60;g.apply_pickup("trap");check(is_equal_approx(g.life,48),"trap twenty percent remaining")
	g.apply_pickup("trap");check(is_equal_approx(g.life,38.4),"trap fractional proportional loss")
	g.clear_effect();check(is_equal_approx(g.life,38.4),"no trap refund")
	check(g.music_player.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD,"music loops")
	g.gift_categories.clear()
	for batch in range(100):
		var bonuses=0
		for i in range(10):
			if g.next_gift_category()=="bonus":bonuses+=1
		check(bonuses==5,"balanced shuffled gifts")
	g.start_game()
	for i in range(479):g.update_game(1.0/60)
	check(g.pickups.size()==0,"no gift before eight seconds")
	g.update_game(0.04);check(g.pickups.size()==1 and g.pickup_clock>=7.5 and g.pickup_clock<=8.5,"eight second gifts")
	for el in range(5):
		g.enemies.clear();g.spawn_enemy(0,0.5,-1,0)
		var e=g.enemies[0];e.hp=100;e.maxhp=100;e.age=2;e.entry_progress=1;e.x=0
		g.hit_enemy(e,el,1)
		check(is_equal_approx(e.hp,100-[1,3,1,2,0.5][el]),"damage element %d"%el)
		if el==2:
			var ep=e.p;var ex=e.x;g.update_game(0.1)
			check(e.p==ep and e.x==ex and e.frozen>2.8,"complete freeze")
		if el==3:check(e.slow==3,"electric slow")
	g.start_game();g.spawn_enemy(0,0.99,1,0)
	g.enemies[0].x=g.player_x;g.enemies[0].age=2;g.enemies[0].entry_progress=1
	g.update_game(0.01)
	check(g.life==90 and g.fallen.size()==1 and g.jump_timer>0,"contact bounce and fall")
	g.life=10;g.spawn_enemy(0,0.99,1,0);g.enemies[0].x=g.player_x;g.enemies[0].age=2;g.enemies[0].entry_progress=1;g.update_game(0.01)
	check(g.life==0 and g.mode=="caught","capture at zero only")
	g.start_game();g.stones=8;g.element=1
	for i in range(12000):
		g.life=100
		g.update_game(1.0/60)
	check(g.mode=="play" and g.time>199 and g.score==int(g.time)*10+g.kills*100,"endless time score")
	check(g.stats.spawned>30,"paced arrivals over a long run")
	print("SURVIVAL_FAILURES=",failures," SPAWNED=",g.stats.spawned)
	g.free();quit(1 if failures else 0)
