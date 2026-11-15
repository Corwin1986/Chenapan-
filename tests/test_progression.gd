extends SceneTree
var failures=0
var g
func check(ok: bool,msg: String):
	if not ok:failures+=1;printerr("FAIL: "+msg)
func _initialize():call_deferred("run")
func run():
	g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true
	g.start_game()
	check(is_equal_approx(g.player_speed(),2.4),"player initially 1.5 times slower")
	check(is_equal_approx(g.enemy_spawn_interval(),6.8),"initial spawn frequency")
	for points in [199,200,399,400,1000]:
		g.score=points
		var factor=pow(1.5,int(points/200))
		check(is_equal_approx(g.player_speed(),2.4*factor),"player speed tier %d"%points)
		check(is_equal_approx(g.enemy_spawn_interval(),6.8/factor),"frequency multiplier without floor")
	g.apply_pickup("soda");check(is_equal_approx(g.player_speed(),1.4/1.5*pow(1.5,5)),"soda preserved at higher tier")
	g.start_game();g.apply_pickup("energy");g.gift_timer=9
	g.collect_special("storm")
	check(g.special_slots.size()==2 and g.last_gift=="energy" and g.gift_timer==9,"two lightning tabs preserve current gift")
	g.apply_pickup("trap");check(g.special_slots.size()==2,"ordinary gifts never remove specials")
	g.spawn_enemy(0,0.5,1,0);g.spawn_enemy(1,0.6,-1,1,true)
	g.use_special(0)
	check(g.special_slots.size()==1 and g.enemies[0].hp<=0 and g.enemies[1].hp<=0,"lightning kills all, consumes only one charge")
	g.enemies.clear();g.collect_special("dogs");g.spawn_enemy(0,0.5,1,0)
	g.use_special(1)
	check(g.dogs_timer>0 and g.enemies[0].hp<=0 and g.special_slots.size()==1,"dogs kill and preserve other charge")
	g.mode="menu";g.handle_press(Vector2(200,940));g.intro.skip()
	check(g.mode=="mock_ad" and g.mock_action=="start","home new game opens mock ad")
	g.handle_press(Vector2(655,60));check(g.mode=="play" and g.score==0 and g.continues_used==0,"immediate close starts game")
	g.time=123;g.score=1230;g.apply_pickup("fire");g.collect_special("storm")
	for i in range(2):
		g.life=0;g.finish(false);g.handle_press(Vector2(250,1030))
		check(g.mode=="mock_ad","optional continue opens mock ad")
		var score=g.score;var timer=g.time
		g._process(0.05)
		check(g.score==score and g.time==timer,"mock ad freezes simulation")
		g.handle_press(Vector2(655,60));g.close_mock_ad()
		check(g.mode=="play" and g.continues_used==i+1 and g.score==1230 and g.life==100,"resume exact score once with full life")
		check(g.special_slots.size()==2 and g.last_gift=="fire","resume preserves inventory and effect")
	g.life=0;g.finish(false);g.handle_press(Vector2(250,1030))
	check(g.mode=="end" and g.continues_used==2,"third continue unavailable")
	g.handle_press(Vector2(250,850))
	check(g.mode=="play" and g.score==0 and g.continues_used==0 and g.special_slots.is_empty(),"direct retry skips ad and resets run")
	g.mode="menu";g.handle_press(Vector2(200,940));g.intro.skip();check(g.mode=="mock_ad","returning home restores start ad")
	print("PROGRESSION_FAILURES=",failures)
	g.free();quit(1 if failures else 0)
