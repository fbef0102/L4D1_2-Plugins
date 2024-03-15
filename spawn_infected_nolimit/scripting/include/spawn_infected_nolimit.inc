#if defined _spawn_infected_nolimit_included_
	#endinput
#endif
#define _spawn_infected_nolimit_included_

/**
* @brief 			   Spawn special infected without the director limits!
*
* @param zomb          	S.I. Name: 
*                             (L4D2) "tank", "smoker", "hunter", "boomer"," jockey", "charger", "spitter", "witch"
*                             (L4D1) "tank", "smoker", "hunter", "boomer", "witch"
* @param vecPos        	Vector coordinate where the special will be spawned
* @param vecAng        	QAngle where special will be facing
* @param variantModel  	The zombie variant model 
*                             (L4D2) Smoker: 	1=L4D2 Model, 2=L4D1 Model, 0=Random
*                             (L4D2) Boomer: 	1=L4D2 Model, 2=L4D1 Model, 3=Female Boomer, 0=Random
*                             (L4D2) Hunter: 	1=L4D2 Model, 2=L4D1 Model, 0=Random
*                             (L4D2) Tank: 		1=L4D2 Model, 2=DLC Model, 3=L4D1 Model, 0=Random
*                             (L4D1) Tank: 		1=L4D1 Model, 2=DLC Model, 0=Random
*
* @return               client index of the spawned special infected, -1 if fail to spawn
*/
native int NoLimit_CreateInfected(const char[] zomb, const float vecPos[3], const float vecAng[3], int variantModel = 1);

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
