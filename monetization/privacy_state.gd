extends RefCounted
## Local, optional coarse profile. No birth date, identifier, or consent inference.
const PATH = "user://privacy.cfg"
var age_group = "unknown"
var ads_opt_out = true
var session_can_request_ads = false
var session_legal_basis_reviewed = false
var revision = 0
func load_local():
	var cfg = ConfigFile.new()
	if cfg.load(PATH)==OK:
		var value = str(cfg.get_value("privacy","age_group","unknown"))
		age_group=value if value in ["unknown","minor","adult"] else "unknown"
		ads_opt_out=bool(cfg.get_value("privacy","ads_opt_out",true))
	# Native consent permission must be refreshed, never trusted from our local storage.
	session_can_request_ads=false
	session_legal_basis_reviewed=false
func save_local():
	var cfg=ConfigFile.new()
	cfg.set_value("privacy","age_group",age_group)
	cfg.set_value("privacy","ads_opt_out",ads_opt_out)
	cfg.save(PATH)
func set_age_group(value: String):
	age_group=value if value in ["unknown","minor","adult"] else "unknown"
	invalidate()
func invalidate():
	revision+=1
	session_can_request_ads=false
	session_legal_basis_reviewed=false
func protected_audience() -> bool:
	return age_group!="adult"
func request_policy() -> Dictionary:
	# Privacy-first default: no behavioral personalization even for adults.
	return {"non_personalized":true,"tracking_allowed":false,"max_ad_content_rating":"G", "child_directed":protected_audience(),"under_age_of_consent":protected_audience(),"age_group":age_group,"revision":revision}
