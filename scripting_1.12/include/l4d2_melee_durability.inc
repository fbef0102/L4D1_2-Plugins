#if defined  _l4d2_melee_durability_included_
 #endinput
#endif
#define _l4d2_melee_durability_included_



/**
 * Get the melee durability
 *
 * @param entity    	Entity index
 * @return          	Melee durability 
 * @error				Invalid Entity index or Entity index is not "weapon_melee"
 */
native int GetMeleeDurability(int entity);

/**
 * Set the melee durability
 *
 * @param entity    	Entity index to set melee durability
 * @param durability    Melee durability to Set
 * @error				Invalid Entity index or Entity index is not "weapon_melee"
 */
native void SetMeleeDurability(int entity, int durability);



public SharedPlugin __pl_l4d2_melee_durability =
{
	name = "l4d2_melee_durability",
	file = "l4d2_melee_durability.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_melee_durability_SetNTVOptional()
{
	MarkNativeAsOptional("Native_GetMeleeDurability");
	MarkNativeAsOptional("Native_SetMeleeDurability");
}
#endif