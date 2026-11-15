extends RefCounted
## Phase 1: all native advertising is disabled. No production IDs are stored.
var enabled = false
var test_ads_only = true
var interstitial_enabled = true
var rewarded_enabled = true
var banner_enabled = false
var interstitial_every_rounds = 4
var native_integration_verified = false
var child_contextual_ads_reviewed = false
var child_formats_reviewed = false
var ios_kids_category = false
var ios_kids_ads_reviewed = false
# These fields must be populated from the official test-ID documentation during native integration.
# Keeping them blank is intentional: missing configuration must never trigger a network request.
var ids = {
	"Android": {"app":"", "interstitial":"", "rewarded":"", "banner":""},
	"iOS": {"app":"", "interstitial":"", "rewarded":"", "banner":""}
}
func format_enabled(format: String) -> bool:
	return {"interstitial":interstitial_enabled,"rewarded":rewarded_enabled,"banner":banner_enabled}.get(format,false)
func configured(platform: String, format: String) -> bool:
	if not ids.has(platform): return false
	var app_id: String = ids[platform].app
	var unit_id: String = ids[platform].get(format,"")
	if app_id.is_empty() or unit_id.is_empty(): return false
	if test_ads_only:
		return app_id.begins_with("ca-app-pub-3940256099942544~") and unit_id.begins_with("ca-app-pub-3940256099942544/")
	# Release activation needs a separate integration review, not merely an ID change.
	return native_integration_verified
