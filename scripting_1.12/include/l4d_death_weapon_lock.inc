#if defined  _l4d_death_weapon_lock_included_
 #endinput
#endif
#define _l4d_death_weapon_lock_included_

public SharedPlugin __pl_l4d_death_weapon_lock =
{
	name = "l4d_death_weapon_lock",
	file = "l4d_death_weapon_lock.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_death_weapon_lock_SetNTVOptional()
{
	MarkNativeAsOptional("Drop_WeaponLock");
}
#endif

/**
 * Lock the weapon so only the specific client can pick up
 * 
 * @param client	Client that can pick up the weapon, anyone else can't (don't input fake client)
 * @param weapon	Weapons that would be locked (must be on the ground)
 * 
 * @return		    True if suceed, false if not
 */
native bool Drop_WeaponLock(int client, int weapon);