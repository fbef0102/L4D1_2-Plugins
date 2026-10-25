#if defined  _l4d2_ty_saveweapons_included_
 #endinput
#endif
#define _l4d2_ty_saveweapons_included_

/**
* @brief Called when restore and give weapons, health to a player (Post)
*
* @param client    the client who is given to.
*
* @noreturn
*/
forward void L4D2_OnSaveWeaponHxGiveC(int client);

/**
* @brief Called when save weapons and health on map transition (Post)
*
* @param client    the client who made it to saferoom.
*
* @noreturn
*/
forward void L4D2_OnSaveWeaponHxSaveC(int client);

public SharedPlugin __pl_l4d2_ty_saveweapons =
{
	name = "l4d2_ty_saveweapons",
	file = "l4d2_ty_saveweapons.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_ty_saveweapons_SetNTVOptional()
{
	
}
#endif