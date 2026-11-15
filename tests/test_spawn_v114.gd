extends SceneTree
var failures=0
func check(ok: bool,message: String):
	if not ok: failures+=1;printerr(message)
func _initialize():call_deferred('run')
func run():
	var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true
	g.start_game()
	for i in range(6):
		var before=g.spawn_base_interval()
		g.score=g.SLING_MILESTONES[i];g.update_slingshot_milestones()
		check(g.sling_level==0,'Missed weapons remain uncollected')
		check(is_equal_approx(g.spawn_base_interval(),before),'No abrupt acceleration')
		g.spawn_upgrade_age=8;check(is_equal_approx(g.spawn_base_interval(),before),'Eight second delay retained')
		g.spawn_upgrade_age=13;check(is_equal_approx(g.spawn_base_interval(),lerpf(before,g.SPAWN_INTERVALS[i+1],0.5)),'Ten second blend retained')
		g.spawn_upgrade_age=18;check(is_equal_approx(g.spawn_base_interval(),g.SPAWN_INTERVALS[i+1]),'Score drives cadence despite missed pickup')
	var interval=g.enemy_spawn_interval()
	g.collect_slingshot(1)
	check(is_equal_approx(interval,g.enemy_spawn_interval()),'Late collection does not change spawn cadence')
	check(g.spawn_upgrade_age==18,'Collection does not restart transition')
	check(g.max_active_enemies()==10,'Ten enemy ceiling at 25000')
	g.start_game();check(g.sling_event_index==0 and is_equal_approx(g.spawn_base_interval(),2.4),'New game resets progression')
	print('SPAWN_V114_FAILURES=',failures);g.free();quit(1 if failures else 0)
