#if defined  _l4d_zcs_included_
 #endinput
#endif
#define _l4d_zcs_included_

/**
* @brief Called whenever infected player changed zombie class via zcs
*
* @param client		The client index who changed zombie class
* @param new_zombieclass The new zombie class that client changed to
*
* @noreturn
*/
forward void L4D2_OnClientChangeZombieClass(int client, int new_zombieclass);

public SharedPlugin __pl_l4d_zcs =
{
	name = "l4d_zcs",
	file = "l4d_zcs.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_zcs_SetNTVOptional()
{
	
}
#endif