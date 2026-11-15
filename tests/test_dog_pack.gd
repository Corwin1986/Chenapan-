extends SceneTree
var failures=0
func check(ok: bool,message: String):
 if not ok:failures+=1;printerr("FAIL: "+message)
func _initialize():call_deferred("run")
func run():
 var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
 g.time=300.1;g.score=3000;g.street.sync();g.shoot_clock=999;g.pickup_clock=999
 var victims=[]
 for kind in range(9):
  for variant in range(g.ENEMY_SPRITES[kind].size()):
   g.spawn_enemy(kind,0.05+0.04*victims.size(),-1 if kind%2==0 else 1,variant,kind==1)
   var e=g.enemies.back();e.hp=42.5 if e.boss else 7.25;e.frozen=3;e.slow=2
   victims.append(e)
 g.apply_pickup("fire");g.collect_special("storm");g.collect_special("dogs")
 var before=g.kills;g.use_special(2)
 check(g.enemies.is_empty(),"All actors removed immediately, including doors, distant targets and bosses")
 for e in victims:check(e.hp<=0,"Every profession and variant is defeated")
 check(g.kills==before+victims.size(),"Every kill counted exactly once")
 check(g.special_slots.size()==2 and g.special_slots[0]=="storm","One dog charge consumed, two lightning charges preserved")
 check(g.last_gift=="fire","Current normal gift preserved")
 var spawned=g.stats.spawned
 for i in range(25):
  g.update_game(0.1)
  check(g.enemies.is_empty() and g.stats.spawned==spawned,"No new attackers while pack crosses, even at 3000 points")
 # A late entrant from any future alternate spawn source is also caught.
 g.spawn_enemy(8,0.3,1,1);var late=g.enemies.back();g.update_game(0.01)
 check(late.hp<=0 and g.enemies.is_empty(),"Pack catches an unexpected late entrant")
 var final_kills=g.kills
 g.update_game(0.2)
 check(g.dogs_timer==0,"Pack ends normally")
 g.update_enemy_spawns(g.enemy_spawn_interval()+0.01)
 check(not g.enemies.is_empty(),"Normal arrivals resume after pack, without permanent spawn suppression")
 check(g.kills==final_kills,"No double counting on subsequent frames")
 # Lightning still grants two independent clears.
 g.use_special(0);check(g.enemies.is_empty() and g.special_slots.size()==1,"First lightning remains a full clear")
 g.spawn_enemy(0,0.5,-1,0);g.use_special(0)
 check(g.enemies.is_empty() and g.special_slots.is_empty(),"Second lightning remains available")
 g.start_game();check(g.dogs_timer==0,"New game resets pack")
 print("DOG_PACK_FAILURES=",failures)
 g.free();quit(1 if failures else 0)
