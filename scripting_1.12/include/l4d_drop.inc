#if defined  _l4d_drop_included_
 #endinput
#endif

#define _l4d_drop_included_

/**
 * @brief Called whenever weapon prepared to drop by plugin l4d_drop
 *
 * @param client		player index to be drop weapon
 * @param weapon		weapon index to be drop
 *
 * @return				Plugin_Continue to continuing dropping,
 * 						Plugin_Changed to change weapon target, otherwise to prevent weapon dropping.
 */
forward Action OnWeaponDrop(int client, int &weapon);

public SharedPlugin __pl_l4d_drop =
{
	name = "l4d_drop",
	file = "l4d_drop.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_drop_SetNTVOptional()
{
    
}
#endif