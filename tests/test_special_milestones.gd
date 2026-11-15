extends SceneTree
var failures=0
func check(ok: bool,msg: String):
	if not ok:failures+=1;printerr("FAIL: "+msg)
func _initialize():call_deferred("run")
func run():
	var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
	for points in [999,1000,1001,1999,2000,2999,3000,3001,4000,5000,5999,6000]:
		g.score=points;g.update_special_milestones()
		var expected=0
		if points in [1000,2000,4000,5000]:expected=1
		if points in [3000,6000]:expected=2
		check(g.pickups.size()==expected,"exact milestone %d"%points)
		if expected>0:check(g.pickups[0].kind=="dogs","dog at every thousand")
		if expected==2:
			check(g.pickups[1].kind=="storm","storm every three thousand")
			check(g.pickups[0].lane==g.pickups[1].lane and g.pickups[0].p>g.pickups[1].p,"both collectible on common milestone")
		g.pickups.clear();g.update_special_milestones()
		check(g.pickups.is_empty(),"missed gift never immediately respawns")
	g.start_game();g.collect_special("storm");g.score=1000;g.update_special_milestones()
	check(g.pickups.size()==1 and g.pickups[0].kind=="dogs","held lightning does not block dogs")
	g.collect_special("dogs");g.pickups.clear();g.score=3000;g.update_special_milestones()
	check(g.pickups.is_empty(),"held gifts block own scheduled replacement")
	check(g.special_slots.size()==3,"two lightning tabs and one dog tab")
	g.use_special(2);g.use_special(0)
	check(g.special_slots.size()==1,"one lightning use remains")
	g.update_special_milestones();check(g.pickups.is_empty(),"spent gifts do not replay skipped milestone")
	g.score=4000;g.update_special_milestones();check(g.pickups.size()==1 and g.pickups[0].kind=="dogs","dog returns next thousand")
	g.pickups.clear();g.score=6000;g.update_special_milestones()
	check(g.pickups.size()==1 and g.pickups[0].kind=="dogs","one lightning charge blocks lightning only")
	g.start_game();g.score=1000;g.update_special_milestones();g.score=2000;g.update_special_milestones()
	check(g.pickups.size()==1,"gift still on road blocks duplicate")
	g.pickups.clear();g.score=10000
	for i in range(100):g.spawn_gift()
	for gift in g.pickups:check(gift.kind=="mystery","ordinary gift never random special")
	g.start_game();g.time=99.99;g.update_game(0.02)
	check(g.score==1000 and g.pickups.size()==1 and g.pickups[0].kind=="dogs","game loop triggers first dog")
	g.finish(false);g.open_mock_ad("continue");g.close_mock_ad();g.pickups.clear();g.update_game(0.02)
	check(g.pickups.is_empty(),"continue never repeats same milestone")
	print("SPECIAL_MILESTONES_FAILURES=",failures)
	g.free();quit(1 if failures else 0)
