extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr('FAIL: '+msg)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
 for score in [0,1000,5000]:
  g.score=score
  check(is_equal_approx(g.player_speed(),0.7*2.4*g.progression_multiplier()),'30 percent slower at every score')
  g.last_gift='soda';check(is_equal_approx(g.player_speed(),0.7*1.4/1.5*g.progression_multiplier()),'Soda preserves same reduction');g.last_gift=''
 var intro=load('res://cinematics/intro_cinematic.gd').new();root.add_child(intro);intro.set_process(false)
 check(intro.CHILD_HEIGHT==290,'Children and cinematic hero use the same enlarged height')
 intro.begin();intro.advance(7.1);check(intro.segment()==1,'School timeline')
 intro.advance(10);check(intro.segment()==2,'Post timeline')
 intro.skip();check(not intro.active and not intro.visible,'Skip still works')
 intro.begin();intro.advance(intro.DURATION+0.1);check(not intro.active,'Intro ends normally')
 print('RELEASE_1_1_FAILURES=',failures)
 intro.free();g.free();quit(1 if failures else 0)
