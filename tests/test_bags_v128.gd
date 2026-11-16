extends SceneTree
func _initialize():call_deferred("run")
func run():
 var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true
 var cfg=ConfigFile.new();cfg.set_value("collection","coins",1000);cfg.set_value("collection","owned",["hats_00"]);cfg.set_value("collection","equipped",{"hats":"hats_00"});assert(cfg.save("user://bags_normal128.cfg")==OK)
 var normal=GDScript.new();normal.source_code=FileAccess.get_file_as_string("res://progression/notebook.gd").replace("const TEST_ALL_CLOTHES=true","const TEST_ALL_CLOTHES=false");assert(normal.reload()==OK)
 var n=normal.new();n.setup(g,"user://bags_normal128.cfg");n.category_index=4
 assert(n.equipped.hats=="hats_00" and n.equipped.backpacks=="")
 assert(not n.shop_locked(n.item_by_id("backpacks_00")))
 assert(n.shop_locked(n.item_by_id("backpacks_01")))
 assert(not n.buy("backpacks_01"))
 assert(n.buy("backpacks_00"));assert(n.coins==500 and n.next_item("backpacks").id=="backpacks_01")
 assert(n.equip_item("backpacks_00"));assert(n.equipped.hats=="hats_00")
 assert(n.buy("backpacks_01"));assert(n.coins==0);assert(not n.buy("backpacks_02"))
 var restored=normal.new();restored.setup(g,"user://bags_normal128.cfg")
 assert(restored.equipped.backpacks=="backpacks_00" and restored.equipped.hats=="hats_00")
 assert(restored.coins==0 and restored.owned.size()==3)
 print("BAGS_ECONOMY128_OK: old-save migration, 500 coins, sequential locks, equip/reload")
 g.free();quit()
