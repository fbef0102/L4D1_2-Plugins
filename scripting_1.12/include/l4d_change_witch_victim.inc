#if defined _l4d_change_witch_victim_included
 #endinput
#endif
#define _l4d_change_witch_victim_included

/**
 * @brief Change a Witch's target or force a Witch to attack a target.
 * 
 * @param	witch		Entity index of an alive Witch.
 * @param	target		Entity index of a desired target.
 * 
 * @error				Invalid entity index or world passed as a target.
 * @return	bool		True if the Witch is valid and alive, false otherwise.
 */
native bool ChangeWitchTarget(int witch, int target);

public SharedPlugin __pl_l4d_change_witch_victim =
{
	name = "l4d_change_witch_victim",
	file = "l4d_change_witch_victim.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __ext_l4d_change_witch_victim_SetNTVOptional()
{
	MarkNativeAsOptional("ChangeWitchTarget");
}
#endif