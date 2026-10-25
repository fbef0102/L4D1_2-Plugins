#if defined  _l4d_witch_target_forever_included_
 #endinput
#endif
#define _l4d_witch_target_forever_included_

/**
 * Get witch's initial target
 *
 * @param witch			witch entity index
 * @return          	Client index of initial target or 0 if not in game/not exist 
 */
native int GetWitchInitialTarget(int witch);

public SharedPlugin __pl_l4d_witch_target_forever =
{
	name = "l4d_witch_target_forever",
	file = "l4d_witch_target_forever.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_witch_target_forever_SetNTVOptional()
{
	MarkNativeAsOptional("GetWitchInitialTarget");
}
#endif