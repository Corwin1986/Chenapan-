extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr(msg)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
 for points in [999,1000,4000,7000,10000]:
  g.pickups.clear();g.score=points;g.update_special_milestones()
  check(g.pickups.size()==(0 if points==999 else 1),'Expected dogs milestone')
  for p in g.pickups:check(p.kind=='dogs','No lightning gift')
 g.pickups.clear();g.score=12999;g.update_special_milestones();check(g.pickups.is_empty(),'No appearance before next 3000-point interval')
 g.collect_special('storm');check(g.special_slots.is_empty(),'Lightning cannot be stored')
 g.collect_special('dogs');g.score=13000;g.update_special_milestones();check(g.pickups.is_empty(),'Held dogs block appearance')
 g.use_special(0);g.update_special_milestones();check(g.pickups.is_empty(),'No second gift in same milestone')
 g.score=16000;g.update_special_milestones();check(g.pickups.size()==1,'Dogs return at next milestone')
 g.apply_pickup('electric');check(g.element==3,'Electric stones remain')
 print('DOGS_ONLY_FAILURES=',failures);g.free();quit(1 if failures else 0)
