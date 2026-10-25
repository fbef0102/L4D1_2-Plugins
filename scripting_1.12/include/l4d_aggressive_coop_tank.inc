#if defined _l4d_aggressive_coop_tank_included
 #endinput
#endif
#define _l4d_aggressive_coop_tank_included

/**
 * @brief Force an AI Tank to become aggressive and approach Survivors.
 * @remarks Returns false when the Tank is attacking
 * 
 * @param	tank		Client index of an alive AI Tank.
 * 
 * @return	bool		True if the Tank is valid and idle, false otherwise.
 */
native bool ForceAITankAttack(int tank);

public SharedPlugin __pl_l4d_aggressive_coop_tank =
{
	name = "l4d_aggressive_coop_tank",
	file = "l4d_aggressive_coop_tank.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __ext_l4d_aggressive_coop_tank_SetNTVOptional()
{
	MarkNativeAsOptional("ForceAITankAttack");
}
#endif