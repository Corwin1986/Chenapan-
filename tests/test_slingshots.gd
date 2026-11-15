extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr('FAIL: '+msg)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
 var base=g.shot_interval();var marks=[2000,5000,10000,15000,20000,25000]
 for missed in range(-1,6):
  g.start_game()
  for i in range(6):
   g.score=marks[i]-1;g.update_slingshot_milestones();check(g.pickups.is_empty(),'No early or replacement appearance')
   g.score=marks[i];g.update_slingshot_milestones();check(g.pickups.size()==1,'Exactly one appearance at milestone')
   check(g.pickups[0].level==g.sling_level+1,'Next missing color')
   if i!=missed:g.collect_slingshot(g.pickups[0].level)
   g.pickups.clear()
   check(is_equal_approx(g.shot_interval(),base/(g.sling_level+1)),'Cadence from original')
  g.score=100000;g.update_slingshot_milestones();check(g.pickups.is_empty(),'No appearance after final event')
  check(g.sling_level==(6 if missed==-1 else 5),'Any miss prevents gold')
 g.start_game();g.score=26000;g.update_slingshot_milestones();check(g.pickups.size()==6,'Large gain preserves six opportunities')
 for i in range(6):
  var p=g.pickups.pop_front();check(p.level==g.sling_level+1,'Pending colors follow acquisition');g.collect_slingshot(p.level)
 check(g.sling_level==6,'Gold from all six collections')
 g.apply_pickup('energy');check(is_equal_approx(g.shot_interval(),base/14),'Energy and gold stack')
 g.clear_effect();check(is_equal_approx(g.shot_interval(),base/7),'Gift expiry retains gold')
 g.mode='mock_ad';g.mock_action='continue';g.close_mock_ad();check(g.sling_level==6 and g.sling_event_index==6,'Continue preserves weapon and used opportunities')
 g.start_game();check(g.sling_level==0 and g.sling_event_index==0 and g.next_sling_score==2000,'New round resets')
 print('SLINGSHOT_FAILURES=',failures);g.free();quit(1 if failures else 0)
