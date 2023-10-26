#if defined _spawn_infected_nolimit_included_
	#endinput
#endif
#define _spawn_infected_nolimit_included_

/**
* @brief 			   Spawn special infected without the director limits!
*
* @param zomb          S.I. Name: "tank", "smoker", "hunter", "boomer"," jockey", "charger", "spitter", "witch", "witch_bride"
* @param vecPos        Vector coordinate where the special will be spawned
* @param vecAng         QAngle where special will be facing
*
* @return              client index of the spawned special infected, -1 if fail to spawn
*/
native int NoLimit_CreateInfected(const char[] zomb, const float vecPos[3], const float vecAng[3]);

public SharedPlugin __pl_spawn_infected_nolimit =
{
	name = "spawn_infected_nolimit",
	file = "spawn_infected_nolimit.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_spawn_infected_nolimit_SetNTVOptional()
{
	MarkNativeAsOptional("NoLimit_CreateInfected");
}
#endif
