
#if defined _weapon_action_api_included_
#endinput
#endif
#define _weapon_action_api_included_

/* Natives */

/**
 * Switch to weapon
 *
 * @param client    Client index
 * @param slot    Weapon/Item slot
 * @return          True if success, false otherwise.
 */
native bool Player_SwitchToWeapon(int client, int slot);

/**
 * When a client tries to switch weapon
 *
 * @param client    Client index
 * @param weapon    Weapon entity index
 * @param param    Dont know
 * @return          Plugin_Handled or Plugin_Stop to block player switch weapon, Plugin_Continue otherwise.
 */
forward Action Player_OnSwitchToWeapon(int client, int weapon, int param);

/**
 * When a client tries to switch weapon finished
 *
 * @param client    Client index
 * @param weapon    Weapon entity index
 * @param param    Dont know
 */
forward void Player_OnSwitchToWeapon_Post(int client, int weapon, int param);

public SharedPlugin:__pl_weapon_action_api =
{
    name = "weapon_action_api",
    file = "weapon_action_api.smx",
    #if defined REQUIRE_PLUGIN
    required = 1,
    #else
    required = 0,
    #endif
};

public void __pl_freecamera_SetNTVOptional()
{
    MarkNativeAsOptional("Player_SwitchToWeapon");
}