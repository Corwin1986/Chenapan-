extends SceneTree
var g
var n
func _initialize():call_deferred("run")
func run():
 g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true
 # Migrate a pre-daily save without losing purchases, wallet or the active objective.
 var cfg=ConfigFile.new();cfg.set_value("collection","coins",600);cfg.set_value("collection","total_completed",6);cfg.set_value("collection","task_cursor",2);cfg.set_value("collection","value",7);cfg.set_value("collection","owned",["shoes_00"]);cfg.set_value("collection","equipped",{"shoes":"shoes_00"});assert(cfg.save("user://daily130.cfg")==OK)
 n=load("res://progression/notebook.gd").new();n.setup(g,"user://daily130.cfg");g.notebook=n
 assert(n.coins==600 and n.total_completed==6 and n.daily_completed==0 and n.rank_index()==0)
 assert(n.current_value()==7 and n.equipped.shoes=="shoes_00")
 n.ensure_day("2100-01-01");n.task_cursor=0;n.values={};n.wait_new_run=false;g.sling_level=0;g.score=0
 for i in 11:
  var t=n.task();n.event(t.event,t.goal,true)
 assert(n.daily_completed==11 and n.daily_bonus_claimed and n.coins==2500 and n.daily_earned==1900)
 assert(n.rank_index()==3 and n.task().id=="fire_master")
 var reloaded=load("res://progression/notebook.gd").new();reloaded.setup(g,n.save_path)
 assert(reloaded.daily_bonus_claimed and reloaded.coins==2500)
 n.event("fire_kills",23);n.begin_round();assert(n.current_value()==23)
 n.ensure_day("2100-01-02")
 assert(n.current_value()==23 and n.daily_completed==0 and n.coins==2500 and not n.daily_bonus_claimed)
 assert(n.rank_index()==0 and n.owned==["shoes_00"])
 n.ensure_day("2100-01-01");assert(n.daily_date=="2100-01-02")
 # Verify actual combat attribution, not the current equipped effect.
 g.spawn_enemy(0,0.5,1,0);var enemy=g.enemies[-1];enemy.hp=1
 g.element=2;g.hit_enemy(enemy,1,1);assert(n.current_value()==24)
 g.hit_enemy(enemy,1,1);assert(n.current_value()==24)
 g.spawn_enemy(0,0.5,1,0);enemy=g.enemies[-1];enemy.hp=1;g.damage_enemy(enemy,5);assert(n.current_value()==24)
 g.spawn_enemy(0,0.5,1,0);enemy=g.enemies[-1];enemy.hp=1;g.hit_enemy(enemy,2,1);assert(n.current_value()==24)
 n.event("fire_kills",26);assert(n.task().id=="ice_master" and n.coins==3000)
 n.event("ice_kills",50);assert(n.task().id=="electric_master" and n.coins==3500)
 n.event("electric_kills",50);assert(n.task().id=="egg_master" and n.coins==4000)
 n.event("egg_kills",99);n.ensure_day("2100-01-03");n.begin_round();assert(n.current_value()==99)
 g.spawn_enemy(0,0.5,1,0);enemy=g.enemies[-1];enemy.hp=1
 g.hit_enemy(enemy,4,1);assert(n.current_value()==99 and enemy.hp==0.5)
 g.hit_enemy(enemy,4,1);assert(n.task_cursor==0 and n.coins==4500 and n.daily_completed==1)
 var wallet=n.coins;assert(n.skip_task());assert(n.coins==wallet and n.daily_completed==1)
 # Second day bonus exactly once, including when challenges keep cycling.
 n.task_cursor=0;n.values={};n.wait_new_run=false;g.score=0;g.sling_level=0
 for i in 10:
  var t=n.task();n.event(t.event,t.goal,true)
 assert(n.daily_completed==11 and n.daily_bonus_claimed)
 wallet=n.coins;n.event("score",120000,true);assert(n.coins==wallet+200)
 g.score=555;n.tick(0.1);n.end_round();n.end_round();assert(n.daily_best==555 and n.daily_rounds==1)
 n.ensure_day("2100-01-04");assert(n.daily_best==0 and n.daily_rounds==0 and n.daily_completed==0)
 print("DAILY130_OK: migration, daily reset/restart, bonus once/day, skip no credit, four cumulative challenges, lethal projectile attribution")
 g.free();quit()
