extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr("FAIL: "+msg)
func _initialize():call_deferred("run")
func run():
 var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
 var town=g.street
 var last_length=0.0
 for index in range(7):
  g.time=index*50.0;g.score=index*500;town.sync()
  check(town.street_index==index and is_zero_approx(town.distance),"New straight street at every 500 points")
  check(town.length>last_length,"Faster runs have longer streets");last_length=town.length
  check(town.total_plots>=9,"Each street contains all establishments")
  var kinds={}
  for plot in range(town.total_plots):kinds[posmod(plot+index,9)]=true
  check(kinds.size()==9,"Nine establishment families per street")
  var heading=-town.camera.global_basis.z
  for second in [0.0,10.0,25.0,40.0,49.5]:
   g.time=index*50.0+second;g.score=int(g.time)*10;town.sync()
   check((-town.camera.global_basis.z).distance_to(heading)<0.00001,"No turning within streets")
   check(is_zero_approx(town.camera.position.x),"Camera centered on straight road")
   var player=g.road_point(0,1)
   check(player.x>320 and player.x<400 and player.y>800 and player.y<1170,"Player framed consistently")
   check(g.road_point(0.8,1).x>g.road_point(-0.8,1).x,"Finger right moves right")
   for door in g.visible_doors():
    g.spawn_from_door(door,0);var e=g.enemies.back()
    check(g.enemy_pos(e).distance_to(door.feet)<0.01,"Pursuer appears at actual door")
    check(g.ENEMY_SPRITES[door.kind].has(e.sprite),"Correct profession at door")
   g.enemies.clear()
  check(town.distance<town.length,"Street lasts full 500 points")
 g.time=50;g.score=500;town.sync();check(town.transition_alpha()>0.99,"Junction transition at 500")
 g.time=51;g.score=510;town.sync();check(town.transition_alpha()==0,"Brief transition then straight road")
 g.life=61;g.special_slots.clear();g.special_slots.append("dogs");g.time=100;g.score=1000;town.sync()
 check(g.life==61 and g.special_slots==["dogs"],"Junction does not reset health or gifts")
 check(town.destination_name(0)!=town.destination_name(1) and town.destination_name(0)==town.destination_name(3),"Mairie school church cycle")
 var before=town.distance;g.mode="pause";g._process(0.05);check(town.distance==before,"Pause freezes journey")
 print("STRAIGHT_STREETS_FAILURES=",failures)
 g.free();quit(1 if failures else 0)
