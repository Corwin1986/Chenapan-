extends SceneTree
func _initialize():call_deferred("run")
func run():
 var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true
 var cfg=ConfigFile.new();cfg.set_value("collection","coins",777);cfg.set_value("collection","owned",["shoes_00"]);cfg.set_value("collection","equipped",{"shoes":"shoes_00"});cfg.save("user://preview125.cfg")
 var n=load("res://progression/notebook.gd").new();n.setup(g,"user://preview125.cfg")
 assert(n.owned==["shoes_00"] and n.coins==777)
 for item in n.catalog:assert(n.can_wear(item.id));assert(n.equip_item(item.id));assert(not n.shop_locked(item))
 for i in n.CATEGORIES.size():n.category_index=i;assert(n.dress_options().size()==n.items_for(n.CATEGORIES[i]).size()+1)
 assert(n.coins==777 and n.owned==["shoes_00"]);assert(not n.buy("tops_00"))
 var normal=GDScript.new();normal.source_code=FileAccess.get_file_as_string("res://progression/notebook.gd").replace("const TEST_ALL_CLOTHES=true","const TEST_ALL_CLOTHES=false");assert(normal.reload()==OK)
 var restored=normal.new();restored.setup(g,"user://preview125.cfg")
 assert(restored.coins==777 and restored.owned==["shoes_00"])
 assert(restored.equipped.shoes=="shoes_00" and restored.equipped.hats=="")
 assert(not restored.can_wear("hats_00") and restored.next_item("shoes").id=="shoes_01")
 assert(not restored.buy("shoes_02"))
 assert(n.skip_task());assert(n.coins==777)
 print("PREVIEW125_OK: 84 articles accessibles, achats et pièces préservés, retour normal vérifié")
 g.free();quit()
