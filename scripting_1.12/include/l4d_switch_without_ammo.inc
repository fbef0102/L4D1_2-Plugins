#if defined _l4d_switch_without_ammo_included_
	#endinput
#endif
#define _l4d_switch_without_ammo_included_

/**
 * @brief Check if a weapon has no ammo.
 * @remarks Plugin hacks "m_iClip1" tp a non-zero as marker for no ammo when the weapon is not active for its owner.
 * 
 * @param weapon		Entity index.
 * 
 * @return bool			True if the weapon is out of ammo, false otherwise.
 */
native bool L4DSWA_WeaponHasNoAmmo(int weapon);

public SharedPlugin __pl_l4d_switch_without_ammo =
{
	name = "l4d_switch_without_ammo",
	file = "l4d_switch_without_ammo.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_switch_without_ammo_SetNTVOptional()
{
	MarkNativeAsOptional("L4DSWA_WeaponHasNoAmmo");
}
#endif