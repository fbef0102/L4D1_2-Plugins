/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2024  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#if defined _mutanttanks_included
	#endinput
#endif
#define _mutanttanks_included

#include <sdkhooks>
#include <sdktools>

// Core plugin information
#define MT_NAME "[L4D & L4D2] Mutant Tanks"
#define MT_AUTHOR "Psyk0tik"
#define MT_AUTHOR2 "Crasher_3637"
#define MT_DESCRIPTION "Mutant Tanks enhances the fun and excitement players get from Tank fights by creating a unique experience with every Tank."
#define MT_VERSION "9.1"
#define MT_URL "https://forums.alliedmods.net/showthread.php?t=302140"
#define MT_URL2 "https://github.com/Psykotikism/Mutant_Tanks"

public SharedPlugin __pl_mutanttanks =
{
	name = "mutant_tanks",
	file = "mutant_tanks.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_mutanttanks_SetNTVOptional()
{
	MarkNativeAsOptional("MT_CanTypeSpawn");
	MarkNativeAsOptional("MT_DeafenPlayer");
	MarkNativeAsOptional("MT_DetonateTankRock");
	MarkNativeAsOptional("MT_DoesSurvivorHaveRewardType");
	MarkNativeAsOptional("MT_DoesTypeRequireHumans");
	MarkNativeAsOptional("MT_GetAccessFlags");
	MarkNativeAsOptional("MT_GetCombinationSetting");
	MarkNativeAsOptional("MT_GetConfigColors");
	MarkNativeAsOptional("MT_GetCurrentFinaleWave");
	MarkNativeAsOptional("MT_GetGlowRange");
	MarkNativeAsOptional("MT_GetGlowType");
	MarkNativeAsOptional("MT_GetImmunityFlags");
	MarkNativeAsOptional("MT_GetMaxType");
	MarkNativeAsOptional("MT_GetMinType");
	MarkNativeAsOptional("MT_GetPropColors");
	MarkNativeAsOptional("MT_GetRecordedTankType");
	MarkNativeAsOptional("MT_GetRunSpeed");
	MarkNativeAsOptional("MT_GetScaledDamage");
	MarkNativeAsOptional("MT_GetSpawnType");
	MarkNativeAsOptional("MT_GetTankColors");
	MarkNativeAsOptional("MT_GetTankName");
	MarkNativeAsOptional("MT_GetTankType");
	MarkNativeAsOptional("MT_HasAdminAccess");
	MarkNativeAsOptional("MT_HasChanceToSpawn");
	MarkNativeAsOptional("MT_HideEntity");
	MarkNativeAsOptional("MT_IsAdminImmune");
	MarkNativeAsOptional("MT_IsCorePluginEnabled");
	MarkNativeAsOptional("MT_IsCustomTankSupported");
	MarkNativeAsOptional("MT_IsFinaleType");
	MarkNativeAsOptional("MT_IsGlowEnabled");
	MarkNativeAsOptional("MT_IsGlowFlashing");
	MarkNativeAsOptional("MT_IsNonFinaleType");
	MarkNativeAsOptional("MT_IsTankIdle");
	MarkNativeAsOptional("MT_IsTankSupported");
	MarkNativeAsOptional("MT_IsTypeEnabled");
	MarkNativeAsOptional("MT_LogMessage");
	MarkNativeAsOptional("MT_RespawnSurvivor");
	MarkNativeAsOptional("MT_SetTankType");
	MarkNativeAsOptional("MT_ShoveBySurvivor");
	MarkNativeAsOptional("MT_SpawnTank");
	MarkNativeAsOptional("MT_StaggerPlayer");
	MarkNativeAsOptional("MT_TankMaxHealth");
	MarkNativeAsOptional("MT_UnvomitPlayer");
	MarkNativeAsOptional("MT_VomitPlayer");
}
#endif

// Chat tags
#define MT_TAG "[MT]"
#define MT_TAG2 "\x04[MT]\x01"
#define MT_TAG3 "\x04[MT]\x03"
#define MT_TAG4 "\x04[MT]\x04"
#define MT_TAG5 "\x04[MT]\x05"

// Constants
#define MT_MAXABILITIES 100
#define MT_MAXTYPES 500
#define MT_MAXHEALTH 1000000
#define MT_MAX_HEALTH_REDUCTION -1000000

// Buttons
#define MT_MAIN_KEY IN_USE
#define MT_SUB_KEY IN_RELOAD
#define MT_SPECIAL_KEY IN_ZOOM
#define MT_SPECIAL_KEY2 IN_DUCK

// Client check flags
#define MT_CHECK_INDEX (1 << 0) // check 0 < client <= MaxClients
#define MT_CHECK_CONNECTED (1 << 1) // check IsClientConnected(client)
#define MT_CHECK_INGAME (1 << 2) // check IsClientInGame(client)
#define MT_CHECK_ALIVE (1 << 3) // check IsPlayerAlive(client)
#define MT_CHECK_INKICKQUEUE (1 << 4) // check IsClientInKickQueue(client)
#define MT_CHECK_FAKECLIENT (1 << 5) // check IsFakeClient(client)

// Attack flags
#define MT_ATTACK_CLAW (1 << 0) // weapon_tank_claw/tank_rock
#define MT_ATTACK_MELEE (1 << 1) // weapon_melee
#define MT_ATTACK_RANGE (1 << 2) // range ability

// Combination types
#define MT_COMBO_MAINRANGE 0 // main/range ability
#define MT_COMBO_MELEEHIT 1 // weapon_tank_claw/weapon_melee
#define MT_COMBO_ROCKTHROW 2 // when rock is thrown
#define MT_COMBO_ROCKBREAK 3 // tank_rock; when rock breaks
#define MT_COMBO_POSTSPAWN 4 // after spawning
#define MT_COMBO_UPONDEATH 5 // when dying
#define MT_COMBO_UPONINCAP 6 // when incapacitated

// Fade effects
#define MT_FADE_IN 0x0001
#define MT_FADE_OUT 0x0002
#define MT_FADE_MODULATE 0x0004
#define MT_FADE_STAYOUT 0x0008
#define MT_FADE_PURGE 0x0010

// Logging flags
#define MT_LOG_LIFE (1 << 0) // spawned or died
#define MT_LOG_CHANGE (1 << 1) // mutant type changed
#define MT_LOG_ABILITY (1 << 2) // ability activated
#define MT_LOG_SERVER (1 << 3) // server notifications/confirmations
#define MT_LOG_CUSTOM (1 << 4) // custom message

// Message flags
#define MT_MESSAGE_MELEE (1 << 0) // weapon_tank_claw/tank_rock/weapon_melee
#define MT_MESSAGE_RANGE (1 << 1) // range ability
#define MT_MESSAGE_SPECIAL (1 << 2) // special ability
#define MT_MESSAGE_SPECIAL2 (1 << 3) // special ability #2

// Reward flags
#define MT_REWARD_HEALTH (1 << 0) // health reward
#define MT_REWARD_SPEEDBOOST (1 << 1) // speed boost reward
#define MT_REWARD_DAMAGEBOOST (1 << 2) // damage boost reward
#define MT_REWARD_ATTACKBOOST (1 << 3) // attack boost reward
#define MT_REWARD_AMMO (1 << 4) // ammo reward
#define MT_REWARD_ITEM (1 << 5) // item reward
#define MT_REWARD_GODMODE (1 << 6) // god mode reward
#define MT_REWARD_REFILL (1 << 7) // refill reward
#define MT_REWARD_RESPAWN (1 << 8) // respawn reward
#define MT_REWARD_INFAMMO (1 << 9) // infinite primary ammo reward
#define MT_REWARD_DEVELOPER (1 << 10) // access level 1
#define MT_REWARD_DEVELOPER2 (1 << 11) // access level 2
#define MT_REWARD_DEVELOPER3 (1 << 12) // access level 3
#define MT_REWARD_DEVELOPER4 (1 << 13) // access level 4
#define MT_REWARD_DEVELOPER5 (1 << 14) // access level 5
#define MT_REWARD_DEVELOPER6 (1 << 15) // access level 6
#define MT_REWARD_DEVELOPER7 (1 << 16) // access level 7
#define MT_REWARD_DEVELOPER8 (1 << 17) // access level 8
#define MT_REWARD_DEVELOPER9 (1 << 18) // access level 9
#define MT_REWARD_DEVELOPER10 (1 << 19) // access level 10
#define MT_REWARD_DEVELOPER11 (1 << 20) // access level 11
#define MT_REWARD_DEVELOPER12 (1 << 21) // access level 12

// Special ammo types
#define MT_UPGRADE_INCENDIARY (1 << 0) // incendiary ammo
#define MT_UPGRADE_EXPLOSIVE (1 << 1) // explosive ammo
#define MT_UPGRADE_LASERSIGHT (1 << 2) // laser sight

// Entity mask information
#define MAX_EDICT_BITS 11
#define NUM_ENT_ENTRY_BITS (MAX_EDICT_BITS + 1)
#define NUM_ENT_ENTRIES (1 << NUM_ENT_ENTRY_BITS)
#define ENT_ENTRY_MASK (NUM_ENT_ENTRIES - 1)
#define INVALID_EHANDLE_INDEX 0xFFFFFFFF

// Forwards
/**
 * Called every second to trigger a Mutant Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param tank			Client index of the Tank.
 **/
forward void MT_OnAbilityActivated(int tank);

/**
 * Called before the config file is read.
 * Use this forward to store the different formats of the ability's section name.
 *
 * @param list			List to store the first format.
 * @param list2			List to store the second format.
 * @param list3			List to store the third format.
 * @param list4			List to store the fourth format.
 **/
forward void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4);

/**
 * Called when a human-controlled Mutant Tank presses a button.
 * Use this forward to trigger abilities manually.
 *
 * @param tank			Client index of the Tank.
 * @param button		Button pressed.
 **/
forward void MT_OnButtonPressed(int tank, int button);

/**
 * Called when a human-controlled Mutant Tank releases a button.
 * Use this forward to trigger abilities manually.
 *
 * @param tank			Client index of the Tank.
 * @param button		Button released.
 **/
forward void MT_OnButtonReleased(int tank, int button);

/**
 * Called when a Mutant Tank changes types.
 * Use this forward to trigger any features/abilities/settings when a Mutant Tank changes types.
 *
 * @param tank			Client index of the Tank.
 * @param oldType		The Tank's previous Mutant Tank type.
 * @param newType		The Tank's new Mutant Tank type.
 * @param revert		True if reverting to a normal Tank, false otherwise.
 **/
forward void MT_OnChangeType(int tank, int oldType, int newType, bool revert);

/**
 * Called when a Mutant Tank's abilities are combined.
 * Use this forward to trigger any combinations.
 *
 * @param tank			Client index of the Tank.
 * @param type			0 = Main/range abilities, 1 = Hit abilities, 2 = Rock throw abilities, 3 = Rock break abilities,
 * 					4 = Post-spawn abilities, 5 = Upon-death abilities, 6 = Upon-incap abilities
 * @param random		Random value to check against for chance to trigger combination.
 * @param combo			String containing the list of abilities to combine.
 * @param survivor		Client index of the survivor, if any.
 * @param weapon		Entity index of the weapon, if any.
 * @param classname		String containing the weapon classname, if any.
 **/
forward void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname);

/**
 * Called when the config file is about to load.
 * Use this forward to set default values for settings for the plugin.
 *
 * @param mode			1 = Load general settings, 2 = 1 + load type settings, 3 = Load admin settings
 **/
forward void MT_OnConfigsLoad(int mode);

/**
 * Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param subsection		The subsection the config parser is currently on.
 * @param key			The key the config parser is currently on.
 * @param value			The value the config parser is currently on.
 * @param type			The Mutant Tank type the config parser is currently on. (Used for Mutant Tank-specific settings.)
 * @param admin			Client index of an admin. (Used for admin-specific settings.)
 * @param mode			1 = Load general settings, 2 = 1 + load type settings, 3 = Load admin settings
 * @param special		True if reading a special infected setting, false otherwise.
 * @param specsection		The special section the config parser is currently on.
 **/
forward void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection);

/**
 * Called when the Tank is passed on to another player or bot.
 * Use this forward to copy over any stats for the Tank's new owner.
 *
 * @param oldTank		Client index of the previous owner.
 * @param newTank		Client index of the new owner.
 **/
forward void MT_OnCopyStats(int oldTank, int newTank);

/**
 * Called when a player uses the "sm_st_info" command.
 * Use this forward to add menu items.
 *
 * @param menu			Handle to the menu.
 **/
forward void MT_OnDisplayMenu(Menu menu);

/**
 * Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 * @param dontBroadcast		True if event was not broadcast to clients, false otherwise.
 **/
forward void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast);

/**
 * Called when a survivor is falling in a fatal zone.
 * Use this forward to check if the current map has death fall cameras (fatal falls).
 *
 * @param survivor		Client index of the survivor.
 *
 * @return			Plugin_Handled to prevent the death fall camera from triggering, Plugin_Continue to allow.
 **/
forward Action MT_OnFatalFalling(int survivor);

/**
 * Called when the core plugin is hooking/unhooking events.
 * Use this forward to hook/unhook events.
 *
 * @param hooked		True if event was hooked, false otherwise.
 **/
forward void MT_OnHookEvent(bool hooked);

/**
 * Called when a message is about to be logged.
 * Use this forward to intercept a message.
 *
 * @param type			Type of message being logged.
 * @param message		Buffer containing the message.
 *
 * @return			Plugin_Handled to prevent the message from being logged, Plugin_Continue to allow.
 **/
forward Action MT_OnLogMessage(int type, const char[] message);

/**
 * Called when an item from the "Mutant Tanks Information" menu is displayed.
 * Use this forward to translate an item. The menu callback will redraw the item after this forward is called if the buffer isn't empty.
 *
 * @param client		Client index of the player the item is being displayed to.
 * @param info			String containing the name of the item.
 * @param buffer		String to store the translated item.
 * @param size			Size of the buffer.
 **/
forward void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size);

/**
 * Called when a player selects an item from the "Mutant Tanks Information" menu.
 * Use this forward to do anything when an item is selected.
 *
 * @param client		Client index of the player selecting the item.
 * @param info			String containing the name of the item.
 **/
forward void MT_OnMenuItemSelected(int client, const char[] info);

/**
 * Called right before a player dies.
 * Use this forward to do anything before the player dies.
 *
 * @param victim		Client index of the dying player.
 * @param attacker		Client index of the killer.
 **/
forward void MT_OnPlayerEventKilled(int victim, int attacker);

/**
 * Called right before a player is hit by a bile bomb (vomit jar).
 * Use this forward to do anything before the player is hit.
 *
 * @param player		Client index of the hit player.
 * @param thrower		Client index of the survivor that threw the bile bomb (vomit jar).
 *
 * @return			Plugin_Handled to prevent the player from being hit, Plugin_Continue to allow.
 **/
forward Action MT_OnPlayerHitByVomitJar(int player, int thrower);

/**
 * Called right before a player is shoved by a survivor.
 * Use this forward to do anything before the player is shoved.
 * Note: L4D2 only calls this for special infected.
 *
 * @param player		Client index of the player.
 * @param survivor		Client index of the survivor.
 * @param direction		Direction of the shove.
 *
 * @return			Plugin_Handled to prevent the player from being shoved, Plugin_Continue to allow.
 **/
forward Action MT_OnPlayerShovedBySurvivor(int player, int survivor, const float direction[3]);

/**
 * Called before the config file is read.
 * Use this forward to officially register an ability's plugin.
 *
 * @param list			List to store plugin's name in.
 **/
forward void MT_OnPluginCheck(ArrayList list);

/**
 * Called when the core plugin is unloaded.
 * Use this forward to remove any modifications to Tanks or survivors.
 **/
forward void MT_OnPluginEnd();

/**
 * Called when the core plugin is updated.
 * Use this forward to reload abilities.
 * Requires "Updater": https://github.com/Teamkiller324/Updater
 **/
forward void MT_OnPluginUpdate();

/**
 * Called after a Mutant Tank spawns.
 * Use this forward for any post-spawn actions.
 * If you plan on using this to activate an ability, use MT_OnAbilityActivated() instead.
 *
 * @param tank			Client index of the Tank.
 **/
forward void MT_OnPostTankSpawn(int tank);

/**
 * Called when timers have been reset.
 * Use this forward for resetting repeating timers that use intervals set by config files.
 *
 * @param mode			0 = No client index required, 1 = Client index required
 * @param tank			Client index of a Tank.
 **/
forward void MT_OnResetTimers(int mode, int tank);

/**
 * Called when a survivor is rewarded or their reward ends.
 * Use this forward to reward survivors or to reset their rewards.
 *
 * @param survivor		Client index of the survivor.
 * @param tank			Client index of the Tank.
 * @param type			1 = Health, 2 = Damage boost, 4 = Speed boost, 8 = Ammo, 16 = Item, 32 = God mode, 64 = Health and ammo refill, 128 = Respawn,
 * 					255 = All eight rewards, 256-2147483647 = Reserved for third-party plugins
 * @param priority		0 = Killer, 1 = Assistant who did most damage, 2 = Teammate who helped, 3 = Assistant killer
 * @param duration		The duration of the reward.
 * @param apply			True if the reward is given, false otherwise.
 *
 * @return			Plugin_Handled to prevent giving or ending rewards, Plugin_Continue to allow.
 **/
forward Action MT_OnRewardSurvivor(int survivor, int tank, int &type, int priority, float &duration, bool apply);

/**
 * Called when a Mutant Tank's rock breaks.
 * Use this forward for any after-effects.
 *
 * @param tank			Client index of the Tank.
 * @param rock			Entity index of the rock.
 **/
forward void MT_OnRockBreak(int tank, int rock);

/**
 * Called when a Mutant Tank throws a rock.
 * Use this forward for any throwing abilities.
 *
 * @param tank			Client index of the Tank.
 * @param rock			Entity index of the rock.
 **/
forward void MT_OnRockThrow(int tank, int rock);

/**
 * Called when all settings are cached.
 * Use this forward to cache settings for each player.
 *
 * @param tank			Client index of the Tank.
 * @param apply			True if player is a Tank and has access to the Mutant Tank type, and needs settings to be applied, false otherwise.
 * @param type			Mutant Tank type, 0 otherwise.
 **/
forward void MT_OnSettingsCached(int tank, bool apply, int type);

/**
 * Called when a Mutant Tank type has been chosen.
 * Use this forward to check or change the chosen type.
 *
 * @param type			Type chosen.
 * @param tank			Client index of the Tank if the type chosen is being applied directly, 0 otherwise.
 *
 * @return			Plugin_Handled to choose another type, Plugin_Stop to prevent the Tank from mutating,
 * 					Plugin_Changed to change the chosen type, Plugin_Continue to allow.
 **/
forward Action MT_OnTypeChosen(int &type, int tank);

// Natives
/**
 * Returns if a certain Mutant Tank type can spawn.
 *
 * @param type			Mutant Tank type.
 * @param specType		Special Infected type.
 *
 * @return			True if the type can spawn, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_CanTypeSpawn(int type, int specType);

/**
 * Deafens a player.
 *
 * @param player		Client index of the player.
 *
 * @error			Invalid client index, client is not in-game, or client is dead.
 **/
native void MT_DeafenPlayer(int player);

/**
 * Detonates a Tank rock on the next frame.
 *
 * @param rock			Entity index of the rock.
 *
 * @error			Invalid entity index.
 **/
native void MT_DetonateTankRock(int rock);

/**
 * Returns if a certain survivor has a reward type active.
 *
 * @param survivor		Client index of the survivor.
 * @param type			1 = Health, 2 = Damage boost, 4 = Speed boost, 8 = Ammo, 16 = Item, 32 = God mode, 64 = Health and ammo refill,
 * 					128 = Respawn, 255 = All eight rewards, 256-2147483647 = Reserved for third-party plugins
 *
 * @return			True if the survivor has the reward type active, false otherwise.
 * @error			Invalid client index, client is not in-game, or type is 0 or less.
 **/
native bool MT_DoesSurvivorHaveRewardType(int survivor, int type);

/**
 * Returns if a certain Mutant Tank type requires human-controlled survivors to be present to be effective.
 *
 * @param type			Mutant Tank type.
 * @param tank			Client index of the Tank if the type chosen is being applied directly, 0 otherwise.
 *
 * @return			True if the type requires human-controlled survivors to be present, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_DoesTypeRequireHumans(int type, int tank = 0);

/**
 * Returns the current access flags set by the core plugin.
 *
 * @param mode			1 = Global flags, 2 = Type-specific flags, 3 = Global admin flags, 4 = Type-specific admin flags
 * @param type			Mutant Tank type. (Optional)
 * @param admin			Client index of an admin. (Optional)
 *
 * @return			The current access flags.
 * @error			Invalid client index, client is not in-game, client is a bot, or type is 0 or less.
 **/
native int MT_GetAccessFlags(int mode, int type = 0, int admin = -1);

/**
 * Returns the value of a combination setting based on a position.
 *
 * @param tank			Client index of the Tank.
 * @param type			1 = Chance, 2 = Cooldown, 3 = Damage, 4 = Delay, 5 = Duration, 6 = Interval, 7 = Min radius, 8 = Max radius, 9 = Range, 10 = Range chance,
 * 					11 = Range cooldown, 12 = Death range, 13 = Death range chance, 14 = Rock chance, 15 = Rock cooldown, 16 = Speed
 * @param pos			The position in the setting's array to retrieve the value from. (0-9)
 *
 * @return			The value stored in the setting.
 * @error			Invalid client index or client is not in-game.
 **/
native float MT_GetCombinationSetting(int tank, int type, int pos);

/**
 * Returns the colors set in the config file.
 *
 * @param buffer		Buffer to store the colors in.
 * @param size			Size of the buffer.
 * @param value			Value set in the config file.
 *
 * @error			Empty value or buffer is too small.
 **/
native void MT_GetConfigColors(char[] buffer, int size, const char[] value);

/**
 * Returns the current finale wave.
 *
 * @return			The current finale wave.
 **/
native int MT_GetCurrentFinaleWave();

/**
 * Returns a Mutant Tank's glow outline range.
 *
 * @param tank			Client index of the Tank.
 * @param mode			True if looking for max range, false otherwise.
 *
 * @return			The glow outline range of the Tank.
 * @error			Invalid client index or client is not in-game.
 **/
native int MT_GetGlowRange(int tank, bool mode);

/**
 * Returns a Mutant Tank's glow outline type.
 *
 * @param tank			Client index of the Tank.
 *
 * @return			The glow outline type of the Tank.
 * @error			Invalid client index or client is not in-game.
 **/
native int MT_GetGlowType(int tank);

/**
 * Returns the current immunity flags set by the core plugin.
 *
 * @param mode			1 = Global flags, 2 = Type-specific flags, 3 = Global admin flags, 4 = Type-specific admin flags
 * @param type			Mutant Tank type. (Optional)
 * @param admin			Client index of an admin. (Optional)
 *
 * @return			The current immunity flags.
 * @error			Invalid client index, client is not in-game, client is a bot, or type is 0 or less.
 **/
native int MT_GetImmunityFlags(int mode, int type = 0, int admin = -1);

/**
 * Returns the maximum value of the "Type Range" setting.
 *
 * @return			The maximum value of the "Type Range" setting.
 **/
native int MT_GetMaxType();

/**
 * Returns the minimum value of the "Type Range" setting.
 *
 * @return			The minimum value of the "Type Range" setting.
 **/
native int MT_GetMinType();

/**
 * Returns the RGBA colors given to a Mutant Tank's props.
 *
 * @param tank			Client index of the Tank.
 * @param type			1 = Light color, 2 = Oxygen tank color, 3 = Oxygen tank flames color, 4 = Rock color,
 * 					5 = Tire color, 6 = Propane tank color, 7 = Flashlight color, 8 = Crown color
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 *
 * @error			Invalid client index, client is not in-game, or type is less than 1 or greater than 8.
 **/
native void MT_GetPropColors(int tank, int type, int &red, int &green, int &blue, int &alpha);

/**
 * Returns the recorded type of a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param type			Mutant Tank type. (Optional)
 *
 * @return			The Tank's recorded Mutant Tank type.
 * @error			Invalid client index or client is not in-game.
 **/
native int MT_GetRecordedTankType(int tank, int type = 0);

/**
 * Returns a Mutant Tank's run speed.
 *
 * @param tank			Client index of the Tank.
 *
 * @return			The run speed of the Tank.
 * @error			Invalid client index or client is not in-game.
 **/
native float MT_GetRunSpeed(int tank);

/**
 * Returns the scaled damage based on difficulty.
 *
 * @param damage		Base damage to scale.
 *
 * @return			The scaled damage based on difficulty.
 **/
native float MT_GetScaledDamage(float damage);

/**
 * Returns a Mutant Tank's spawn type.
 *
 * @param tank			Client index of the Tank.
 * @param type			Mutant Tank type.
 * @param specType		Special Infected type.
 *
 * @return			The spawn type of the Tank.
 * 					0 = Normal, 1 = Boss, 2 = Randomized, 3 = Transformation, 4 = Combined abilities
 * @error			Invalid client index, client is not in-game, or client is human.
 **/
native int MT_GetSpawnType(int tank, int type = 0, int specType = 0);

/**
 * Returns the RGB colors given to a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param type			1 = Skin color, 2 = Glow outline color
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 *
 * @error			Invalid client index, client is not in-game, or type is less than 1 or greater than 2.
 **/
native void MT_GetTankColors(int tank, int type, int &red, int &green, int &blue, int &alpha);

/**
 * Returns the custom name given to a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param buffer		Buffer to store the custom name in.
 *
 * @error			Invalid client index or client is not in-game.
 **/
native void MT_GetTankName(int tank, char[] buffer);

/**
 * Returns the type of a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param type			Recorded Mutant Tank type. (Optional)
 *
 * @return			The Tank's Mutant Tank type.
 * @error			Invalid client index or client is not in-game.
 **/
native int MT_GetTankType(int tank, int type = 0);

/**
 * Returns if a human player has access to a Mutant Tank type.
 *
 * @param admin			Client index of the admin.
 *
 * @return			True if the human player has access, false otherwise.
 * @error			Invalid client index, client is not in-game, or client is a bot.
 **/
native bool MT_HasAdminAccess(int admin);

/**
 * Returns if a certain Mutant Tank type has a chance of spawning.
 *
 * @param type			Mutant Tank type.
 * @param tank			Client index of the Tank.
 *
 * @return			True if the type has a chance of spawning, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_HasChanceToSpawn(int type, int tank);

/**
 * Hooks/unhooks any entity to/from the core plugin's SetTransmit callback.
 *
 * @param entity		Entity index of the entity.
 * @param mode			True if hooking entity, false otherwise.
 *
 * @error			Invalid entity index.
 **/
native void MT_HideEntity(int entity, bool mode);

/**
 * Returns if a human survivor is immune to a Mutant Tank's attacks.
 *
 * @param survivor		Client index of the survivor.
 * @param tank			Client index of the Tank.
 *
 * @return			True if the human survivor is immune, false otherwise.
 * @error			Invalid survivor index, survivor is not in-game, survivor is dead, survivor is a bot, survivor is idle,
 * 					invalid Tank index, or Tank is not in-game.
 **/
native bool MT_IsAdminImmune(int survivor, int tank);

/**
 * Returns if the core plugin is enabled.
 *
 * @return			True if core plugin is enabled, false otherwise.
 **/
native bool MT_IsCorePluginEnabled();

/**
 * Returns if a custom Tank is allowed to be a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 *
 * @return			True if the custom Tank is allowed to be a Mutant Tank, false otherwise.
 * @error			Invalid client index, client is not in-game, or client is dead.
 **/
native bool MT_IsCustomTankSupported(int tank);

/**
 * Returns if a certain Mutant Tank type is only available on finale maps.
 *
 * @param type			Mutant Tank type.
 * @param tank			Client index of the Tank.
 *
 * @return			True if the type is available, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_IsFinaleType(int type, int tank);

/**
 * Returns if a Mutant Tank type has a glow outline.
 *
 * @param tank			Client index of the Tank.
 *
 * @return			True if the Tank has a glow outline, false otherwise.
 * @error			Invalid client index or client is not in-game.
 **/
native bool MT_IsGlowEnabled(int tank);

/**
 * Returns if a Mutant Tank type's glow outline is flashing.
 *
 * @param tank			Client index of the Tank.
 *
 * @return			True if the Tank's glow outline is flashing, false otherwise.
 * @error			Invalid client index or client is not in-game.
 **/
native bool MT_IsGlowFlashing(int tank);

/**
 * Returns if a certain Mutant Tank type is only available on non-finale maps.
 *
 * @param type			Mutant Tank type.
 * @param tank			Client index of the Tank.
 *
 * @return			True if the type is available, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_IsNonFinaleType(int type, int tank);

/**
 * Returns if a Tank is idle.
 *
 * @param tank			Client index of the Tank.
 * @param type			Idle mode of the Tank. 0 = Both, 1 = Idle (waiting for survivors), 2 = Bugged (no behavior)
 *
 * @return			True if the Tank is idle, false otherwise.
 * @error			Invalid client index, client is not in-game, client is dead, or type is less than 0 or greater than 2.
 **/
native bool MT_IsTankIdle(int tank, int type = 0);

/**
 * Returns if a Tank is allowed to be a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param flags			Checks to run.
 * 					MT_CHECK_INDEX = client index, MT_CHECK_CONNECTED = connection, MT_CHECK_INGAME = in-game status,
 * 					MT_CHECK_ALIVE = life state, MT_CHECK_INKICKQUEUE = kick status, MT_CHECK_FAKECLIENT = bot check
 * 					Default: MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE
 *
 * @return			True if the Tank is allowed to be a Mutant Tank, false otherwise.
 * @error			Invalid client index, client is not in-game, or client is dead.
 **/
native bool MT_IsTankSupported(int tank, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE);

/**
 * Returns if a certain Mutant Tank type is enabled.
 *
 * @param type			Mutant Tank type.
 * @param tank			Client index of the Tank.
 *
 * @return			True if the type is enabled, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_IsTypeEnabled(int type, int tank);

/**
 * Logs a message.
 *
 * @param type			Type of message to be logged.
 * @param message		Buffer containing the message.
 * @param ...			Variable number of format parameters.
 **/
native void MT_LogMessage(int type = MT_LOG_CUSTOM, const char[] message, any ...);

/**
 * Respawns a survivor.
 *
 * @param survivor		Client index of the survivor.
 *
 * @error			Invalid client index, client is not in-game, or client is dead.
 **/
native void MT_RespawnSurvivor(int survivor);

/**
 * Sets a Tank's Mutant Tank type.
 *
 * @param tank			Client index of the Tank.
 * @param type			Mutant Tank type.
 * @param mode			True if the Tank should transform physically into the new Mutant Tank type, false otherwise.
 *
 * @error			Invalid client index, client is not in-game, client is dead, or type is 0 or less.
 **/
native void MT_SetTankType(int tank, int type, bool mode);

/**
 * Shoves a player toward a certain direction.
 *
 * @param player		Client index of the player.
 * @param survivor		Client index of the survivor.
 * @param direction		Direction of the shove.
 *
 * @error			Invalid client index, client is not in-game, or client is dead.
 **/
native void MT_ShoveBySurvivor(int player, int survivor, float direction[3]);

/**
 * Spawns a Tank with the specified Mutant Tank type.
 *
 * @param tank			Client index of the Tank.
 * @param type			Mutant Tank type.
 *
 * @error			Invalid client index, client is not in-game, or type is 0 or less.
 **/
native void MT_SpawnTank(int tank, int type);

/**
 * Staggers a player from a certain direction.
 *
 * @param player		Client index of the player.
 * @param pusher		Client index of the pusher.
 * @param direction		Direction of the stagger.
 *
 * @error			Invalid client index, client is not in-game, or client is dead.
 **/
native void MT_StaggerPlayer(int player, int pusher, float direction[3]);

/**
 * Gets or sets a Tank's max health.
 *
 * @param tank			Client index of the Tank.
 * @param mode			1 = Get the Tank's max health, 2 = Get the Tank's stored max health,
 * 					3 = Set the Tank's max health without storing it, 4 = Set the Tank's max health and store it
 * @param newHealth		The Tank's new max health.
 **/
native int MT_TankMaxHealth(int tank, int mode, int newHealth = 0);

/**
 * Removes the vomit effect on a player.
 *
 * @param player		Client index of the player.
 *
 * @error			Invalid client index, client is not in-game, or client is dead.
 **/
native void MT_UnvomitPlayer(int player);

/**
 * Sets the vomit effect on a player.
 *
 * @param player		Client index of the player.
 * @param boomer		Client index of the Boomer.
 *
 * @error			Invalid client index, client is not in-game, or client is dead.
 **/
native void MT_VomitPlayer(int player, int boomer);

/**
 * Called every second to trigger the Super Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param client		Client index of the Tank.
 **/
#pragma deprecated Use the MT_OnAbilityActivated() forward instead.
forward void ST_Ability(int client);

/**
 * Called when a Tank is about to throw a rock.
 * Use this forward to trigger anything when
 * the Tank is gonna throw a rock.
 *
 * @param client		Client index of the Tank.
 **/
#pragma deprecated Use the MT_OnRockThrow() forward instead.
forward void ST_AbilityThrow(int client);

/**
 * Called when the Super Tank evolves.
 * Use this forward to trigger any features/abilities/settings
 * when a Super Tank evolves.
 *
 * @param client		Client index of the Tank.
 **/
#pragma deprecated Use the MT_OnChangeType() forward instead.
forward void ST_BossStage(int client);

/**
 * Called when the Super Tank changes types.
 * Use this forward to trigger any features/abilities/settings when a Super Tank changes types.
 *
 * @param tank			Client index of the Tank.
 **/
#pragma deprecated Use the MT_OnChangeType() forward instead.
forward void ST_ChangeType(int tank);

/**
 * Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param savepath		The savepath of the config.
 * @param limit			The limit for how many Super Tank types' settings to check for.
 * @param main			Checks whether the main config or a custom config is being used.
 **/
#pragma deprecated Use the MT_OnConfigsLoaded() forward instead.
forward void ST_Configs(char[] savepath, int limit, bool main);

/**
 * Called when someone dies.
 * Use this forward to execute anything when
 * a survivor or Tank dies.
 * Use ST_Death2 if you also want to get the attacker's ID.
 *
 * @param client		Client index of the victim.
 **/
#pragma deprecated Use the MT_OnEventFired() forward instead.
forward void ST_Death(int client);

/**
 * Called when someone dies.
 * Use this forward to execute anything when
 * a survivor or Tank dies.
 * Use ST_Death if you just want to get the victim's ID.
 *
 * @param enemy			Client index of the attacker.
 * @param client		Client index of the victim.
 **/
#pragma deprecated Use the MT_OnEventFired() forward instead.
forward void ST_Death2(int enemy, int client);

/**
 * Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 **/
#pragma deprecated Use the MT_OnEventFired() forward instead.
forward void ST_Event(Event event, const char[] name);

/**
 * Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 * @param dontBroadcast		True if event was not broadcast to clients, false otherwise.
 **/
#pragma deprecated Use the MT_OnEventFired() forward instead.
forward void ST_EventHandler(Event event, const char[] name, bool dontBroadcast);

/**
 * Called when a Tank is incapacitated.
 * Use this forward to execute anything when
 * a Tank is about to die.
 *
 * @param client		Client index of the Tank.
 **/
#pragma deprecated Use the MT_OnEventFired() forward instead.
forward void ST_Incap(int client);

/**
 * Called when the Tank spawns.
 * Use this forward for any on-spawn presets.
 * If you plan on using this to activate an ability, use ST_Ability() instead.
 *
 * @param tank			Client index of the Tank.
 **/
#pragma deprecated Use the MT_OnPostTankSpawn() forward instead.
forward void ST_OnPreset(int tank);

/**
 * Called when the Tank spawns.
 * Use this forward for any on-spawn presets.
 * If you plan on using this to activate an ability, use ST_Ability() instead.
 *
 * @param tank			Client index of the Tank.
 **/
#pragma deprecated Use the MT_OnPostTankSpawn() forward instead.
forward void ST_Preset(int tank);

/**
 * Called when the Tank's rock breaks.
 * Use this forward for any after-effects.
 *
 * @param client		Client index of the Tank.
 * @param entity		Entity index of the rock.
 **/
#pragma deprecated Use the MT_OnRockBreak() forward instead.
forward void ST_RockBreak(int client, int entity);

/**
 * Called when the Tank throws a rock.
 * Use this forward for any throwing abilities.
 *
 * @param client		Client index of the Tank.
 * @param entity		Entity index of the rock.
 **/
#pragma deprecated Use the MT_OnRockThrow() forward instead.
forward void ST_RockThrow(int client, int entity);

/**
 * Called when the round starts.
 * Use this forward for setting something when
 * the round starts.
 **/
#pragma deprecated Use the MT_OnEventFired() forward instead.
forward void ST_RoundStart();

/**
 * Called when the Tank spawns.
 * Use this forward for any one-time abilities
 * or on-spawn presets.
 *
 * @param client		Client index of the Tank.
 **/
#pragma deprecated Use the MT_OnPostTankSpawn() forward instead.
forward void ST_Spawn(int client);

/**
 * Returns if a certain Mutant Tank type can spawn.
 *
 * @param type			Mutant Tank type.
 *
 * @return			True if the type can spawn, false otherwise.
 * @error			Type is 0.
 **/
#pragma deprecated Use the MT_CanTypeSpawn() native instead.
stock bool MT_CanTankSpawn(int type)
{
	return MT_CanTypeSpawn(type, (bIsSecondGame() ? 8 : 5));
}

/**
 * Returns if a certain Mutant Tank type is only available on finale maps.
 *
 * @param type			Mutant Tank type.
 *
 * @return			True if the type is available, false otherwise.
 * @error			Type is 0.
 **/
#pragma deprecated Use the MT_IsFinaleType() native instead.
stock bool MT_IsFinaleTank(int type)
{
	return MT_IsFinaleType(type, 0);
}

/**
 * Returns the value of the "Maximum Types" setting.
 *
 * @return			The value of the "Maximum Types" setting.
 **/
#pragma deprecated Use the MT_GetMaxType() native instead.
stock int ST_MaxTypes()
{
	return MT_GetMaxType();
}

/**
 * Returns the maximum value of the "Type Range" setting.
 *
 * @return			The maximum value of the "Type Range" setting.
 **/
#pragma deprecated Use the MT_GetMaxType() native instead.
stock int ST_MaxType()
{
	return MT_GetMaxType();
}

/**
 * Returns the minimum value of the "Type Range" setting.
 *
 * @return			The minimum value of the "Type Range" setting.
 **/
#pragma deprecated Use the MT_GetMinType() native instead.
stock int ST_MinType()
{
	return MT_GetMinType();
}

/**
 * Returns the status of the core plugin.
 *
 * @return			True on success, false if core plugin is disabled.
 **/
#pragma deprecated Use the MT_IsCorePluginEnabled() native instead.
stock bool ST_PluginEnabled()
{
	return MT_IsCorePluginEnabled();
}

/**
 * Returns the RGBA colors given to a Tank's props.
 *
 * @param tank			Client index of the Tank.
 * @param mode			1 = Light color, 2 = Oxygen tank color, 3 = Oxygen tank flames color,
 * 					4 = Rock color, 5 = Tire color
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 *
 * @error			Invalid client index.
 **/
#pragma deprecated Use the MT_GetPropColors() native instead.
stock void ST_PropsColors(int tank, int mode, int &red, int &green, int &blue, int &alpha)
{
	MT_GetPropColors(tank, mode, red, green, blue, alpha);
}

/**
 * Returns if a certain Super Tank type can be spawned.
 *
 * @param type			Super Tank type.
 *
 * @return			True if the type can be spawned, false otherwise.
 * @error			Type is 0.
 **/
#pragma deprecated Use the MT_CanTypeSpawn() native instead.
stock bool ST_SpawnEnabled(int type)
{
	return MT_CanTypeSpawn(type, (bIsSecondGame() ? 8 : 5));
}

/**
 * Returns the status of the "Human Super Tanks" setting.
 *
 * @param client		Client index of the Tank.
 *
 * @return			True on success, false if the setting is disabled.
 **/
#pragma deprecated Use the MT_IsTankSupported() native instead.
stock bool ST_TankAllowed(int client)
{
	return MT_IsTankSupported(client);
}

/**
 * Returns if a certain Super Tank type has a chance of spawning.
 *
 * @param type			Super Tank type.
 *
 * @return			True if the type has a chance of spawning, false otherwise.
 * @error			Type is 0.
 **/
#pragma deprecated Use the MT_HasChanceToSpawn() native instead.
stock bool ST_TankChance(int type)
{
	return MT_HasChanceToSpawn(type, 0);
}

/**
 * Returns the RGB colors given to a Tank.
 *
 * @param tank			Client index of the Tank.
 * @param mode			1 = Skin color, 2 = Glow outline color
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 *
 * @error			Invalid client index.
 **/
#pragma deprecated Use the MT_GetTankColors() native instead.
stock void ST_TankColors(int tank, int mode, int &red, int &green, int &blue, int &alpha)
{
	MT_GetTankColors(tank, mode, red, green, blue, alpha);
}

/**
 * Returns the custom name given to a Tank.
 *
 * @param tank			Client index of the Tank.
 * @param buffer		Buffer to store the custom name in.
 *
 * @error			Invalid client index.
 **/
#pragma deprecated Use the MT_GetTankName() native instead.
stock void ST_TankName(int tank, char[] buffer)
{
	MT_GetTankName(tank, buffer);
}

/**
 * Returns the Super Tank type of the Tank.
 *
 * @param client		Client index of the Tank.
 *
 * @return			The Tank's Super Tank type.
 * @error			Invalid client index.
 **/
#pragma deprecated Use the MT_GetRecordedTankType() native instead.
stock int ST_TankType(int client)
{
	return MT_GetRecordedTankType(client);
}

/**
 * Returns the current finale wave.
 *
 * @return			The current finale wave.
 **/
#pragma deprecated Use the MT_GetCurrentFinaleWave() native instead.
stock int ST_TankWave()
{
	return MT_GetCurrentFinaleWave();
}

/**
 * Returns if a certain Super Tank type is enabled.
 *
 * @param type			Super Tank type.
 *
 * @return			True if the type is enabled, false otherwise.
 * @error			Type is 0.
 **/
#pragma deprecated Use the MT_IsTypeEnabled() native instead.
stock bool ST_TypeEnabled(int type)
{
	return MT_IsTypeEnabled(type, 0);
}

// Functions
stock void vAttachParticle(int entity, const char[] particlename, float duration = 0.0, float origin = 0.0, bool teleport = true)
{
	if (bIsValidClient(entity) || bIsValidEntity(entity))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (bIsValidEntity(iParticle))
		{
			DispatchKeyValue(iParticle, "effect_name", particlename);

			if (teleport)
			{
				float flPos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
				flPos[2] += origin;
				TeleportEntity(iParticle, flPos);
			}

			vSetEntityParent(iParticle, entity);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Start");
			vSetEdictFlags(iParticle, FL_EDICT_ALWAYS, true);

			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, duration);
		}
	}
}

stock void vAttachParticle2(float pos[3], float angles[3], const char[] particlename, float duration = 0.0)
{
	int iParticle = CreateEntityByName("info_particle_system");
	if (bIsValidEntity(iParticle))
	{
		DispatchKeyValue(iParticle, "effect_name", particlename);
		TeleportEntity(iParticle, pos, angles);
		DispatchSpawn(iParticle);
		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "Start");
		vSetEdictFlags(iParticle, FL_EDICT_ALWAYS, true);

		iParticle = EntIndexToEntRef(iParticle);
		vDeleteEntity(iParticle, duration);
	}
}

stock void vCheatCommand(int player, const char[] command, const char[] arguments = "")
{
	if (bIsValidClient(player, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		int iFlagBits = GetUserFlagBits(player), iCmdFlags = GetCommandFlags(command);
		SetUserFlagBits(player, ADMFLAG_ROOT);
		SetCommandFlags(command, iCmdFlags & ~FCVAR_CHEAT);
		FakeClientCommand(player, "%s %s", command, arguments);
		SetUserFlagBits(player, iFlagBits);
		SetCommandFlags(command, iCmdFlags);
	}
}

stock void vCopyVector(float source[3], float target[3])
{
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2];
}

stock void vCreateConfigFile(const char[] folder, const char[] filename, any ...)
{
	char sConfig[PLATFORM_MAX_PATH], sFilename[PLATFORM_MAX_PATH], sOutput[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	VFormat(sFilename, sizeof sFilename, filename, 3);
	FormatEx(sConfig, sizeof sConfig, "%s.cfg", sFilename);
	BuildPath(Path_SM, sPath, sizeof sPath, "%s%s", folder, sConfig);
	if (MT_FileExists(folder, sConfig, sPath, sOutput, sizeof sOutput))
	{
		RenameFile(sOutput, sPath);

		return;
	}

	File fFilename = OpenFile(sPath, "w+");
	if (fFilename != null)
	{
		fFilename.WriteLine("// This config file was auto-generated for and by \"%s\" (v%s)\n", MT_NAME, MT_VERSION);
		fFilename.WriteLine("\"Mutant Tanks\"");
		fFilename.WriteLine("{");
		fFilename.WriteLine("\t// Override settings in here.");
		fFilename.WriteLine("}");

		delete fFilename;
	}
}

stock void vDamagePlayer(int victim, int attacker, float damage, const char[] damagetype = "0")
{
	int iPointHurt = CreateEntityByName("point_hurt");
	if (bIsValidEntity(iPointHurt))
	{
		char sTargetName[32];
		FormatEx(sTargetName, sizeof sTargetName, "mt_target_%i", GetClientUserId(victim));
		DispatchKeyValue(victim, "targetname", sTargetName);

		DispatchKeyValueFloat(iPointHurt, "Damage", damage);
		DispatchKeyValue(iPointHurt, "DamageTarget", sTargetName);
		DispatchKeyValue(iPointHurt, "DamageType", damagetype);

		DispatchSpawn(iPointHurt);
		AcceptEntityInput(iPointHurt, "Hurt", attacker);
		RemoveEntity(iPointHurt);
	}
}

stock void vDeleteEntity(int ref, float duration = 0.1)
{
	if (bIsValidEntRef(ref))
	{
		int iObject = EntRefToEntIndex(ref);
		if (bIsValidEntity(iObject))
		{
			char sVariant[64];
			FormatEx(sVariant, sizeof sVariant, "OnUser1 !self:ClearParent::%f:-1", duration);
			SetVariantString(sVariant);
			AcceptEntityInput(iObject, "AddOutput");
			AcceptEntityInput(iObject, "FireUser1");

			FormatEx(sVariant, sizeof sVariant, "OnUser1 !self:Kill::%f:-1", duration + 0.1);
			SetVariantString(sVariant);
			AcceptEntityInput(iObject, "AddOutput");
			AcceptEntityInput(iObject, "FireUser1");
		}
	}
}

stock void vExecuteVScriptCode(const char[] code)
{
	int iLogicScript = CreateEntityByName("logic_script");
	if (bIsValidEntity(iLogicScript))
	{
		DispatchSpawn(iLogicScript);
		SetVariantString(code);
		AcceptEntityInput(iLogicScript, "RunScriptCode");
		RemoveEntity(iLogicScript);
	}
}

stock void vExternalView(int player, float time)
{
	if (bIsSecondGame() && bIsValidClient(player, MT_CHECK_FAKECLIENT) && GetEntPropFloat(player, Prop_Send, "m_TimeForceExternalView") != 99999.3)
	{
		SetEntPropFloat(player, Prop_Send, "m_TimeForceExternalView", GetGameTime() + time);
	}
}

stock void vFixPlayerPosition(int client, bool noVelocity = true)
{
	if (bIsPlayerStuck(client))
	{
		float flPosZ = 0.1;
		while (flPosZ <= 200.0 && !bIsPlayerPositionFixed(client, 10.0, flPosZ, noVelocity))
		{
			flPosZ = -flPosZ;
			if (flPosZ > 0.0)
			{
				flPosZ += 20.0;
			}
		}
	}
	else
	{
		float flOrigin[3], flAngles[3];
		GetClientAbsOrigin(client, flOrigin);
		flAngles[0] = 90.0;

		Handle hTrace = TR_TraceRayFilterEx(flOrigin, flAngles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndSolid);
		if (hTrace != null)
		{
			if (TR_DidHit(hTrace))
			{
				TR_GetEndPosition(flOrigin, hTrace);
				flOrigin[2] += 10.0;
				TeleportEntity(client, flOrigin, .velocity = (noVelocity ? view_as<float>({0.0, 0.0, -300.0}) : NULL_VECTOR));
			}

			delete hTrace;
		}
	}
}

stock void vForceVocalize(int survivor, const char[] voiceline)
{
	switch (bIsSecondGame())
	{
		case true: FakeClientCommand(survivor, "vocalize %s #%i", voiceline, RoundToNearest(GetGameTime() * 10.0));
		case false: FakeClientCommand(survivor, "vocalize %s", voiceline);
	}
}

stock void vMultiTargetFilters(bool toggle)
{
	switch (toggle)
	{
		case true:
		{
			AddMultiTargetFilter("@smokers", bSmokerFilter, "all Smokers", false);
			AddMultiTargetFilter("@boomers", bBoomerFilter, "all Boomers", false);
			AddMultiTargetFilter("@hunters", bHunterFilter, "all Hunters", false);
			AddMultiTargetFilter("@spitters", bSpitterFilter, "all Spitters", false);
			AddMultiTargetFilter("@jockeys", bJockeyFilter, "all Jockeys", false);
			AddMultiTargetFilter("@chargers", bChargerFilter, "all Chargers", false);
			AddMultiTargetFilter("@tanks", bTankFilter, "all Tanks", false);
			AddMultiTargetFilter("@special", bSpecialFilter, "all Special Infected", false);
			AddMultiTargetFilter("@infected", bInfectedFilter, "all Infected", false);
			AddMultiTargetFilter("@mutants", bMutantFilter, "all Mutant Infected", false);
			AddMultiTargetFilter("@mtanks", bMutantTankFilter, "all Mutant Tanks", false);
			AddMultiTargetFilter("@psytanks", bMutantTankFilter, "all Mutant Tanks", false);
			AddMultiTargetFilter("@msmokers", bMutantSmokerFilter, "all Mutant Smokers", false);
			AddMultiTargetFilter("@psysmokers", bMutantSmokerFilter, "all Mutant Smokers", false);
			AddMultiTargetFilter("@mboomers", bMutantBoomerFilter, "all Mutant Boomers", false);
			AddMultiTargetFilter("@psyboomers", bMutantBoomerFilter, "all Mutant Boomers", false);
			AddMultiTargetFilter("@mhunters", bMutantHunterFilter, "all Mutant Hunters", false);
			AddMultiTargetFilter("@psyhunters", bMutantHunterFilter, "all Mutant Hunters", false);
			AddMultiTargetFilter("@mspitters", bMutantSpitterFilter, "all Mutant Spitters", false);
			AddMultiTargetFilter("@psyspitters", bMutantSpitterFilter, "all Mutant Spitters", false);
			AddMultiTargetFilter("@mjockeys", bMutantJockeyFilter, "all Mutant Jockeys", false);
			AddMultiTargetFilter("@psyjockeys", bMutantJockeyFilter, "all Mutant Jockeys", false);
			AddMultiTargetFilter("@mchargers", bMutantChargerFilter, "all Mutant Chargers", false);
			AddMultiTargetFilter("@psychargers", bMutantChargerFilter, "all Mutant Chargers", false);
		}
		case false:
		{
			RemoveMultiTargetFilter("@smokers", bSmokerFilter);
			RemoveMultiTargetFilter("@boomers", bBoomerFilter);
			RemoveMultiTargetFilter("@hunters", bHunterFilter);
			RemoveMultiTargetFilter("@spitters", bSpitterFilter);
			RemoveMultiTargetFilter("@jockeys", bJockeyFilter);
			RemoveMultiTargetFilter("@chargers", bChargerFilter);
			RemoveMultiTargetFilter("@tanks", bTankFilter);
			RemoveMultiTargetFilter("@special", bSpecialFilter);
			RemoveMultiTargetFilter("@infected", bInfectedFilter);
			RemoveMultiTargetFilter("@mutants", bMutantFilter);
			RemoveMultiTargetFilter("@mtanks", bMutantTankFilter);
			RemoveMultiTargetFilter("@psytanks", bMutantTankFilter);
			RemoveMultiTargetFilter("@msmokers", bMutantSmokerFilter);
			RemoveMultiTargetFilter("@psysmokers", bMutantSmokerFilter);
			RemoveMultiTargetFilter("@mboomers", bMutantBoomerFilter);
			RemoveMultiTargetFilter("@psyboomers", bMutantBoomerFilter);
			RemoveMultiTargetFilter("@mhunters", bMutantHunterFilter);
			RemoveMultiTargetFilter("@psyhunters", bMutantHunterFilter);
			RemoveMultiTargetFilter("@mspitters", bMutantSpitterFilter);
			RemoveMultiTargetFilter("@psyspitters", bMutantSpitterFilter);
			RemoveMultiTargetFilter("@mjockeys", bMutantJockeyFilter);
			RemoveMultiTargetFilter("@psyjockeys", bMutantJockeyFilter);
			RemoveMultiTargetFilter("@mchargers", bMutantChargerFilter);
			RemoveMultiTargetFilter("@psychargers", bMutantChargerFilter);
		}
	}
}

stock void vPushNearbyEntities(int tank, float pos[3], float magnitude = 600.0, float radius = 200.0)
{
	int iPointPush = CreateEntityByName("point_push");
	if (bIsValidEntity(iPointPush))
	{
		DispatchKeyValueFloat(iPointPush, "magnitude", magnitude);
		DispatchKeyValueFloat(iPointPush, "radius", radius);
		DispatchKeyValue(iPointPush, "spawnflags", "8");

		TeleportEntity(iPointPush, pos);
		DispatchSpawn(iPointPush);
		SetEntPropEnt(iPointPush, Prop_Data, "m_hOwnerEntity", tank);
		AcceptEntityInput(iPointPush, "Enable");

		iPointPush = EntIndexToEntRef(iPointPush);
		vDeleteEntity(iPointPush, 0.5);
	}
}

stock void vRemoveWeapons(int survivor)
{
	int iWeapon = -1;
	for (int iSlot = 0; iSlot < 5; iSlot++)
	{
		iWeapon = GetPlayerWeaponSlot(survivor, iSlot);
		if (iWeapon > MaxClients)
		{
			RemovePlayerItem(survivor, iWeapon);
			RemoveEntity(iWeapon);
		}
	}
}

stock void vScreenEffect(int survivor, int tank, int mode, int flags = MT_ATTACK_MELEE|MT_ATTACK_CLAW, int red = -1, int green = -1, int blue = -1, int alpha = -1, int type1 = MT_FADE_IN, int type2 = MT_FADE_PURGE)
{
	if (mode & flags)
	{
		int iColor[4];
		MT_GetTankColors(tank, MT_GetRandomInt(1, 2), iColor[0], iColor[1], iColor[2], iColor[3]);
		iColor[0] = (0 <= red <= 255) ? red : iColor[0];
		iColor[1] = (0 <= green <= 255) ? green : iColor[1];
		iColor[2] = (0 <= blue <= 255) ? blue : iColor[2];
		iColor[3] = (0 <= alpha <= 255) ? alpha : 150;

		Handle hFadeTarget = StartMessageOne("Fade", survivor);
		if (hFadeTarget != null)
		{
			BfWrite bfWrite = UserMessageToBfWrite(hFadeTarget);
			bfWrite.WriteShort(800);
			bfWrite.WriteShort(300);
			bfWrite.WriteShort(type1|type2);

			for (int iPos = 0; iPos < (sizeof iColor); iPos++)
			{
				bfWrite.WriteByte(iColor[iPos]);
			}

			EndMessage();
		}
	}
}

stock void vSetAdrenalineTime(int survivor, float duration)
{
	if (!bIsSecondGame())
	{
		return;
	}

	static int iTimerAddress = -1;
	if (iTimerAddress == -1)
	{
		iTimerAddress = FindSendPropInfo("CTerrorPlayer", "m_bAdrenalineActive") - 12;
	}

	SetEntDataFloat(survivor, (iTimerAddress + 4), duration);
	SetEntDataFloat(survivor, (iTimerAddress + 8), (GetGameTime() + duration));
	SetEntProp(survivor, Prop_Send, "m_bAdrenalineActive", (duration <= 0.0 ? 0 : 1), 1);
}

stock void vSetEdictFlags(int edict, int flags, bool remove)
{
	int iFlags = GetEdictFlags(edict);
	if (remove && (iFlags & flags))
	{
		SetEdictFlags(edict, (iFlags & ~flags));
	}
	else if (!remove && !(iFlags & flags))
	{
		SetEdictFlags(edict, iFlags|flags);
	}
}

stock void vSetEntityParent(int entity, int parent, bool owner = false)
{
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", parent);

	if (owner)
	{
		SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", parent);
	}
}

stock void vSetTempHealth(int survivor, float health)
{
	SetEntPropFloat(survivor, Prop_Send, "m_healthBuffer", (health < 0.0) ? 0.0 : health);
	SetEntPropFloat(survivor, Prop_Send, "m_healthBufferTime", GetGameTime());
}

stock void vSetVector(float target[3], float xAxis, float yAxis, float zAxis)
{
	target[0] = xAxis;
	target[1] = yAxis;
	target[2] = zAxis;
}

stock void vSetWounds(int common, int type = -1)
{
	if (!bIsCommonInfected(common))
	{
		return;
	}

	if (bIsSecondGame() && HasEntProp(common, Prop_Send, "m_iRequestedWound1"))
	{
		SetEntProp(common, Prop_Send, "m_iRequestedWound1", type);
		SetEntProp(common, Prop_Send, "m_iRequestedWound2", type);
	}
	else if (HasEntProp(common, Prop_Send, "m_nBody"))
	{
		SetEntProp(common, Prop_Send, "m_nBody", ((type < 0) ? 0 : type));
	}
}

stock void vSpawnBreakProp(int tank, float pos[3], float offset, const char[] model)
{
	int iProp = CreateEntityByName("prop_physics");
	if (bIsValidEntity(iProp))
	{
		DispatchKeyValue(iProp, "disableshadows", "1");
		SetEntityModel(iProp, model);

		pos[2] += offset;
		TeleportEntity(iProp, pos);
		DispatchSpawn(iProp);

		SetEntPropEnt(iProp, Prop_Data, "m_hOwnerEntity", tank);
		SetEntPropEnt(iProp, Prop_Data, "m_hPhysicsAttacker", tank);
		SetEntPropFloat(iProp, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());

		SetEntProp(iProp, Prop_Send, "m_CollisionGroup", 1);
		SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iProp, 0, 0, 0, 0);

		DataPack dpProp = new DataPack();
		dpProp.WriteCell(EntIndexToEntRef(iProp));
		dpProp.WriteCell(GetClientUserId(tank));
		RequestFrame(vBreakProp, dpProp);
	}
}

void vBreakProp(DataPack pack)
{
	pack.Reset();
	int iProp = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	delete pack;

	if (bIsValidEntity(iProp) && bIsInfected(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		AcceptEntityInput(iProp, "Break", iTank);
	}
}

stock void vShakePlayerScreen(int player, float duration = 1.0)
{
	Handle hTarget = StartMessageOne("Shake", player);
	if (hTarget != null)
	{
		BfWrite bfWrite = UserMessageToBfWrite(hTarget);
		bfWrite.WriteByte(0);
		bfWrite.WriteFloat(16.0);
		bfWrite.WriteFloat(0.5);
		bfWrite.WriteFloat(duration);

		EndMessage();
	}
}

stock void vStopSound(int client, const char[] sound)
{
	StopSound(client, SNDCHAN_REPLACE, sound);
	StopSound(client, SNDCHAN_AUTO, sound);
	StopSound(client, SNDCHAN_WEAPON, sound);
	StopSound(client, SNDCHAN_VOICE, sound);
	StopSound(client, SNDCHAN_ITEM, sound);
	StopSound(client, SNDCHAN_BODY, sound);
	StopSound(client, SNDCHAN_STREAM, sound);
	StopSound(client, SNDCHAN_STATIC, sound);
	StopSound(client, SNDCHAN_VOICE_BASE, sound);
	StopSound(client, SNDCHAN_USER_BASE, sound);
}

// Stocks
stock void MT_LoadPlugin(Handle plugin = null)
{
	char sFilename[64];
	GetPluginFilename(plugin, sFilename, sizeof sFilename);
	ServerCommand("sm plugins load %s", sFilename);
}

stock void MT_PrintToChat(int client, const char[] message, any ...)
{
	if (!bIsValidClient(client, MT_CHECK_INDEX))
	{
		ThrowError("Invalid client index %i", client);
	}

	if (!bIsValidClient(client, MT_CHECK_INGAME))
	{
		ThrowError("Client %i is not in game", client);
	}

	char sBuffer[1024], sMessage[1024];
	SetGlobalTransTarget(client);
	FormatEx(sMessage, sizeof sMessage, "\x01%s", message);
	VFormat(sBuffer, sizeof sBuffer, sMessage, 3);
	MT_ReplaceChatPlaceholders(sBuffer, sizeof sBuffer, false);
	PrintToChat(client, sBuffer);
}

stock void MT_PrintToChatAll(const char[] message, any ...)
{
	char sBuffer[1024];
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
		{
			SetGlobalTransTarget(iPlayer);
			VFormat(sBuffer, sizeof sBuffer, message, 2);
			MT_PrintToChat(iPlayer, sBuffer);
		}
	}
}

stock void MT_PrintToConsole(int client, const char[] message, any ...)
{
	char sBuffer[1024];
	SetGlobalTransTarget(client);
	VFormat(sBuffer, sizeof sBuffer, message, 3);
	MT_ReplaceChatPlaceholders(sBuffer, sizeof sBuffer, true);
	PrintToConsole(client, sBuffer);
}

stock void MT_PrintToServer(const char[] message, any ...)
{
	char sBuffer[1024];
	SetGlobalTransTarget(LANG_SERVER);
	VFormat(sBuffer, sizeof sBuffer, message, 2);
	MT_ReplaceChatPlaceholders(sBuffer, sizeof sBuffer, true);
	PrintToServer(sBuffer);
}

stock void MT_ReplaceChatPlaceholders(char[] buffer, int size, bool empty)
{
	ReplaceString(buffer, size, "{default}", (empty ? "" : "\x01"));
	ReplaceString(buffer, size, "{mint}", (empty ? "" : "\x03"));
	ReplaceString(buffer, size, "{yellow}", (empty ? "" : "\x04"));
	ReplaceString(buffer, size, "{olive}", (empty ? "" : "\x05"));
	ReplaceString(buffer, size, "{percent}", "%%");

	if (empty)
	{
		ReplaceString(buffer, size, "\x01", "");
		ReplaceString(buffer, size, "\x03", "");
		ReplaceString(buffer, size, "\x04", "");
		ReplaceString(buffer, size, "\x05", "");
	}
}

stock void MT_ReloadPlugin(Handle plugin = null)
{
	char sFilename[64];
	GetPluginFilename(plugin, sFilename, sizeof sFilename);
	ServerCommand("sm plugins reload %s", sFilename);
}

stock void MT_ReplyToCommand(int client, const char[] message, any ...)
{
	char sBuffer[1024];
	SetGlobalTransTarget(client);
	VFormat(sBuffer, sizeof sBuffer, message, 3);

	if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		MT_ReplaceChatPlaceholders(sBuffer, sizeof sBuffer, true);

		switch (client == 0)
		{
			case true: PrintToServer(sBuffer);
			case false: PrintToConsole(client, sBuffer);
		}
	}
	else
	{
		MT_PrintToChat(client, sBuffer);
	}
}

stock void MT_TE_SetupParticleAttachment(int particle, int attachment, int entity, bool follow = false)
{
	static bool bSecondGame = false;
	static EngineVersion evEngine = Engine_Unknown;
	if (evEngine == Engine_Unknown)
	{
		evEngine = GetEngineVersion();
		bSecondGame = (evEngine == Engine_Left4Dead2);
	}

	TE_Start("EffectDispatch");

	static float flDummy[3] = {0.0, 0.0, 0.0};
	TE_WriteFloat((bSecondGame ? "m_vOrigin.x" : "m_vOrigin[0]"), flDummy[0]);
	TE_WriteFloat((bSecondGame ? "m_vOrigin.y" : "m_vOrigin[1]"), flDummy[1]);
	TE_WriteFloat((bSecondGame ? "m_vOrigin.z" : "m_vOrigin[2]"), flDummy[2]);
	TE_WriteFloat((bSecondGame ? "m_vStart.x" : "m_vStart[0]"), flDummy[0]);
	TE_WriteFloat((bSecondGame ? "m_vStart.y" : "m_vStart[1]"), flDummy[1]);
	TE_WriteFloat((bSecondGame ? "m_vStart.z" : "m_vStart[2]"), flDummy[2]);

	static int iEffect = INVALID_STRING_INDEX;
	if (iEffect < 0)
	{
		iEffect = MT_FindStringIndex(FindStringTable("EffectDispatch"), "ParticleEffect");
		if (iEffect == INVALID_STRING_INDEX)
		{
			return;
		}
	}

	TE_WriteNum("m_iEffectName", iEffect);
	TE_WriteNum("m_nHitBox", particle);
	TE_WriteNum("entindex", entity);
	TE_WriteNum("m_nAttachmentIndex", attachment);
	TE_WriteNum("m_fFlags", 1);
	TE_WriteVector("m_vAngles", flDummy);
	TE_WriteFloat("m_flMagnitude", 0.0);
	TE_WriteFloat("m_flScale", 1.0);
	TE_WriteFloat("m_flRadius", 0.0);

	switch (bSecondGame)
	{
		case true: TE_WriteNum("m_nDamageType", (follow ? 5 : 4));
		case false: TE_WriteNum("m_nDamageType", (follow ? 4 : 3));
	}
}

stock void MT_TE_SetupStopAllParticles(int entity)
{
	static bool bSecondGame = false;
	static EngineVersion evEngine = Engine_Unknown;
	if (evEngine == Engine_Unknown)
	{
		evEngine = GetEngineVersion();
		bSecondGame = (evEngine == Engine_Left4Dead2);
	}

	TE_Start("EffectDispatch");

	static float flDummy[3] = {0.0, 0.0, 0.0};
	TE_WriteFloat((bSecondGame ? "m_vOrigin.x" : "m_vOrigin[0]"), flDummy[0]);
	TE_WriteFloat((bSecondGame ? "m_vOrigin.y" : "m_vOrigin[1]"), flDummy[1]);
	TE_WriteFloat((bSecondGame ? "m_vOrigin.z" : "m_vOrigin[2]"), flDummy[2]);
	TE_WriteFloat((bSecondGame ? "m_vStart.x" : "m_vStart[0]"), flDummy[0]);
	TE_WriteFloat((bSecondGame ? "m_vStart.y" : "m_vStart[1]"), flDummy[1]);
	TE_WriteFloat((bSecondGame ? "m_vStart.z" : "m_vStart[2]"), flDummy[2]);

	static int iEffect = INVALID_STRING_INDEX;
	if (iEffect < 0)
	{
		iEffect = MT_FindStringIndex(FindStringTable("EffectDispatch"), "ParticleEffectStop");
		if (iEffect == INVALID_STRING_INDEX)
		{
			return;
		}
	}

	TE_WriteNum("m_iEffectName", iEffect);
	TE_WriteNum("m_nHitBox", 0);
	TE_WriteNum("entindex", entity);
	TE_WriteNum("m_nAttachmentIndex", 0);
	TE_WriteNum("m_fFlags", 1);
	TE_WriteVector("m_vAngles", flDummy);
	TE_WriteFloat("m_flMagnitude", 0.0);
	TE_WriteFloat("m_flScale", 0.0);
	TE_WriteFloat("m_flRadius", 0.0);
	TE_WriteNum("m_nDamageType", 0);
}

stock void MT_TeleportPlayerAhead(int player, const float origin[3], const float angles[3], const float velocity[3], const float direction[3], const float distance)
{
	float flPos[3];
	flPos[0] = origin[0] + (direction[0] * distance);
	flPos[1] = origin[1] + (direction[1] * distance);
	flPos[2] = origin[2];

	TeleportEntity(player, flPos, angles, velocity);
	vFixPlayerPosition(player, false);
}

stock void MT_UnloadPlugin(Handle plugin = null)
{
	char sFilename[64];
	GetPluginFilename(plugin, sFilename, sizeof sFilename);
	ServerCommand("sm plugins unload %s", sFilename);
}

stock bool MT_FileExists(const char[] folder, const char[] filename, const char[] path, char[] output, int size, bool use_valve_fs = false, const char[] valve_path_id = "GAME")
{
	if (FileExists(path, use_valve_fs, valve_path_id))
	{
		char sDirectory[PLATFORM_MAX_PATH], sOutput[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sDirectory, sizeof sDirectory, folder);
		vGetMatchingFilename(sDirectory, filename, sOutput, sizeof sOutput);
		if (!StrEqual(filename, sOutput))
		{
			char sTemp[PLATFORM_MAX_PATH];
			FormatEx(sTemp, sizeof sTemp, "%s%s", sDirectory, sOutput);
			strcopy(output, size, sTemp);
		}

		return true;
	}

	return false;
}

stock bool MT_TE_CreateParticle(float startPos[3] = {0.0, 0.0, 0.0}, float endPos[3] = {0.0, 0.0, 0.0}, int particle = -1, int entity = 0, float delay = 0.0, bool all = true, char name[64] = "", int attachment = 0, float angles[3] = {0.0, 0.0, 0.0}, int flags = 0, int damageType = 0, float magnitude = 0.0, float scale = 1.0, float radius = 0.0)
{
	static bool bSecondGame = false;
	static EngineVersion evEngine = Engine_Unknown;
	if (evEngine == Engine_Unknown)
	{
		evEngine = GetEngineVersion();
		bSecondGame = (evEngine == Engine_Left4Dead2);
	}

	TE_Start("EffectDispatch");

	TE_WriteFloat((bSecondGame ? "m_vOrigin.x" : "m_vOrigin[0]"), startPos[0]);
	TE_WriteFloat((bSecondGame ? "m_vOrigin.y" : "m_vOrigin[1]"), startPos[1]);
	TE_WriteFloat((bSecondGame ? "m_vOrigin.z" : "m_vOrigin[2]"), startPos[2]);
	TE_WriteFloat((bSecondGame ? "m_vStart.x" : "m_vStart[0]"), endPos[0]);
	TE_WriteFloat((bSecondGame ? "m_vStart.y" : "m_vStart[1]"), endPos[1]);
	TE_WriteFloat((bSecondGame ? "m_vStart.z" : "m_vStart[2]"), endPos[2]);

	static int iEffect = INVALID_STRING_INDEX;
	if (iEffect < 0)
	{
		iEffect = MT_FindStringIndex(FindStringTable("EffectDispatch"), "ParticleEffect");
		if (iEffect == INVALID_STRING_INDEX)
		{
			return false;
		}
	}

	TE_WriteNum("m_iEffectName", iEffect);

	if (particle < 0)
	{
		static int iParticleString = INVALID_STRING_INDEX;
		iParticleString = MT_FindStringIndex(iEffect, name);
		if (iParticleString == INVALID_STRING_INDEX)
		{
			return false;
		}

		TE_WriteNum("m_nHitBox", iParticleString);
	}
	else
	{
		TE_WriteNum("m_nHitBox", particle);
	}

	TE_WriteNum("entindex", entity);
	TE_WriteNum("m_nAttachmentIndex", attachment);
	TE_WriteVector("m_vAngles", angles);
	TE_WriteNum("m_fFlags", flags);
	TE_WriteFloat("m_flMagnitude", magnitude);
	TE_WriteFloat("m_flScale", scale);
	TE_WriteFloat("m_flRadius", radius);
	TE_WriteNum("m_nDamageType", damageType);

	if (all)
	{
		TE_SendToAll(delay);
	}

	return true;
}

stock float MT_GetRandomFloat(float min, float max)
{
	return (GetURandomFloat() * (max - min)) + min;
}

stock int MT_AddCommasToFloat(float number, char[] output, int size)
{
	int iPos = 0, iPos2 = 0, iSize = 0;
	if (number < 0.0)
	{
		output[iPos++] = '-';
		number = -number;
	}

	char sTemp[18], sSet[2][18];
	FormatEx(sTemp, sizeof sTemp, "%.2f", number);
	ExplodeString(sTemp, ".", sSet, sizeof sSet, sizeof sSet[]);

	iSize = strlen(sSet[0]);
	if (iSize <= 3)
	{
		iPos += strcopy(output[iPos], size, sTemp);
	}
	else
	{
		while (iPos2 < iSize && iPos < size)
		{
			output[iPos++] = sSet[0][iPos2++];

			if ((iSize - iPos2) && !((iSize - iPos2) % 3))
			{
				output[iPos++] = ',';
			}
		}

		output[iPos] = '\0';
		Format(output, size, "%s.%s", output, sSet[1]);
	}

	return iPos;
}

stock int MT_AddCommasToInt(int number, char[] output, int size)
{
	int iPos = 0, iPos2 = 0, iSize = 0;
	if (number < 0)
	{
		output[iPos++] = '-';
		number = (number ^ (number >> 31)) - (number >> 31);
	}

	char sTemp[15];
	iSize = IntToString(number, sTemp, sizeof sTemp);
	if (iSize <= 3)
	{
		iPos += strcopy(output[iPos], size, sTemp);
	}
	else
	{
		while (iPos2 < iSize && iPos < size)
		{
			output[iPos++] = sTemp[iPos2++];

			if ((iSize - iPos2) && !((iSize - iPos2) % 3))
			{
				output[iPos++] = ',';
			}
		}

		output[iPos] = '\0';
	}

	return iPos;
}

stock int MT_FindStringIndex(int index, const char[] search)
{
	char sBuffer[1024];
	int iStrings = GetStringTableNumStrings(index);
	for (int iPos = 0; iPos < iStrings; iPos++)
	{
		ReadStringTable(index, iPos, sBuffer, sizeof sBuffer);

		if (StrEqual(sBuffer, search))
		{
			return iPos;
		}
	}

	return INVALID_STRING_INDEX;
}

stock int MT_GetParticleIndex(const char[] particlename)
{
	static int iTable = INVALID_STRING_TABLE;
	if (iTable == INVALID_STRING_TABLE)
	{
		iTable = FindStringTable("ParticleEffectNames");
		if (iTable == INVALID_STRING_TABLE)
		{
			return INVALID_STRING_TABLE;
		}
	}

	int iParticleString = MT_FindStringIndex(iTable, particlename);
	if (iParticleString == INVALID_STRING_INDEX)
	{
		iParticleString = iPrecacheParticle(particlename);
	}

	return iParticleString;
}

stock int MT_GetRandomInt(int min, int max)
{
	return RoundToNearest(GetURandomFloat() * float(max - min)) + min;
}

// Checks
stock bool bHasAdminAccess(int admin, int flags, int flags2)
{
	if (!bIsValidClient(admin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iTypePlayerFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin),
		iPlayerFlags = MT_GetAccessFlags(3, 0, admin),
		iAdminFlags = GetUserFlagBits(admin),
		iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin)),
		iGlobalFlags = MT_GetAccessFlags(1);

	if ((flags != 0 && ((!(flags & flags2) && !(flags2 & flags)) || (!(flags & iTypePlayerFlags) && !(iTypePlayerFlags & flags)) || (!(flags & iPlayerFlags) && !(iPlayerFlags & flags)) || (!(flags & iAdminFlags) && !(iAdminFlags & flags))))
		|| (iTypeFlags != 0 && !(iTypeFlags & flags2) && !(flags2 & iTypeFlags)) || (iGlobalFlags != 0 && !(iGlobalFlags & flags2) && !(flags2 & iGlobalFlags)))
	{
		return false;
	}

	return true;
}

stock bool bHasIdlePlayer(int survivor)
{
	if (bIsBotSurvivor(survivor))
	{
		int iSpectatorUserId = GetEntProp(survivor, Prop_Send, "m_humanSpectatorUserID");
		if (iSpectatorUserId > 0)
		{
			int iIdler = GetClientOfUserId(iSpectatorUserId);
			return iIdler > 0 && bIsValidClient(iIdler, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && GetClientTeam(iIdler) != 2;
		}
	}

	return false;
}

stock bool bIsAdminImmune(int admin, int type, int flags, int flags2)
{
	if (!bIsHumanSurvivor(admin))
	{
		return false;
	}

	int iTypePlayerFlags = MT_GetImmunityFlags(4, type, admin),
		iPlayerFlags = MT_GetImmunityFlags(3, 0, admin),
		iAdminFlags = GetUserFlagBits(admin),
		iTypeFlags = MT_GetImmunityFlags(2, type),
		iGlobalFlags = MT_GetImmunityFlags(1);

	return (flags != 0 && ((flags2 != 0 && ((flags & flags2) || (flags2 & flags))) || (iTypePlayerFlags != 0 && ((flags & iTypePlayerFlags) || (iTypePlayerFlags & flags)))
		|| (iPlayerFlags != 0 && ((flags & iPlayerFlags) || (iPlayerFlags & flags))) || (iAdminFlags != 0 && ((flags & iAdminFlags) || (iAdminFlags & flags)))))
		|| (iTypeFlags != 0 && ((iTypeFlags & flags2) || (flags2 & iTypeFlags))) || (iGlobalFlags != 0 && ((iGlobalFlags & flags2) || (flags2 & iGlobalFlags)));
}

stock bool bIsAreaNarrow(int tank = 0, float range = 150.0, float pos[3] = {0.0, 0.0, 0.0})
{
	if (range > 0.0)
	{
		float flOrigin[3], flAngles[3];
		flAngles[0] = -89.0;

		switch (tank > 0)
		{
			case true: GetClientEyePosition(tank, flOrigin);
			case false: vCopyVector(pos, flOrigin);
		}

		Handle hTrace = TR_TraceRayFilterEx(flOrigin, flAngles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, tank);
		if (hTrace != null)
		{
			if (TR_DidHit(hTrace))
			{
				float flPos[3];
				TR_GetEndPosition(flPos, hTrace);

				if (GetVectorDistance(flPos, flOrigin) <= range)
				{
					delete hTrace;
					return true;
				}
			}

			delete hTrace;
		}
	}

	return false;
}

stock bool bIsAreaWide(int tank = 0, float range = 500.0, float pos[3] = {0.0, 0.0, 0.0})
{
	if (range > 0.0)
	{
		float flOrigin[3], flAngles[3];
		flAngles[0] = -89.0;

		switch (tank > 0)
		{
			case true: GetClientEyePosition(tank, flOrigin);
			case false: vCopyVector(pos, flOrigin);
		}

		Handle hTrace = TR_TraceRayFilterEx(flOrigin, flAngles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, tank);
		if (hTrace != null)
		{
			if (TR_DidHit(hTrace))
			{
				float flPos[3];
				TR_GetEndPosition(flPos, hTrace);

				if (GetVectorDistance(flPos, flOrigin) >= range)
				{
					delete hTrace;
					return true;
				}
			}

			delete hTrace;
		}
	}

	return false;
}

stock bool bIsBoomer(int boomer, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsInfected(boomer, flags) && GetEntProp(boomer, Prop_Send, "m_zombieClass") == 2;
}

stock bool bIsBotIdle(int bot, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsSurvivor(bot, flags) && !bIsValidClient(bot, MT_CHECK_FAKECLIENT) && bHasIdlePlayer(bot);
}

stock bool bIsBotIdleSurvivor(int bot, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsSurvivor(bot, flags) && !bIsValidClient(bot, MT_CHECK_FAKECLIENT) && !bHasIdlePlayer(bot);
}

stock bool bIsBotSurvivor(int bot, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	char sClassname[32];
	GetEntityNetClass(bot, sClassname, sizeof sClassname);
	return bIsSurvivor(bot, flags) && !bIsValidClient(bot, MT_CHECK_FAKECLIENT) && StrEqual(sClassname, "SurvivorBot");
}

stock bool bIsCharger(int charger, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsInfected(charger, flags) && bIsSecondGame() && GetEntProp(charger, Prop_Send, "m_zombieClass") == 6;
}

stock bool bIsCommonInfected(int common)
{
	if (bIsValidEntity(common))
	{
		char sClassname[32];
		GetEntityClassname(common, sClassname, sizeof sClassname);
		return StrEqual(sClassname, "infected");
	}

	return false;
}

stock bool bIsEntityGrounded(int entity)
{
	int iGround = GetEntPropEnt(entity, Prop_Send, "m_hGroundEntity");
	return bIsValidEntity(iGround, true, -1);
}

stock bool bIsFinalMap()
{
	return (FindEntityByClassname(-1, "info_changelevel") == -1 && FindEntityByClassname(-1, "trigger_changelevel") == -1) || FindEntityByClassname(-1, "trigger_finale") != -1 || FindEntityByClassname(-1, "finale_trigger") != -1;
}

stock bool bIsGunWeapon(int survivor)
{
	int iWeapon = GetEntPropEnt(survivor, Prop_Send, "m_hActiveWeapon");
	if (iWeapon > MaxClients)
	{
		int iSlot = GetPlayerWeaponSlot(survivor, 0),
			iSlot2 = GetPlayerWeaponSlot(survivor, 1);
		if (iSlot > MaxClients && iSlot == iWeapon)
		{
			return true;
		}
		else if (iSlot2 > MaxClients && iSlot2 == iWeapon)
		{
			char sWeapon[32];
			GetEntityClassname(iWeapon, sWeapon, sizeof sWeapon);
			if (!strncmp(sWeapon[7], "pistol", 6) || StrEqual(sWeapon[7], "chainsaw"))
			{
				return true;
			}
		}
	}

	return false;
}

stock bool bIsHumanInfected(int infected, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsInfected(infected, flags|MT_CHECK_FAKECLIENT);
}

stock bool bIsHumanSurvivor(int survivor, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsSurvivor(survivor, flags|MT_CHECK_FAKECLIENT) && !bHasIdlePlayer(survivor) && !bIsPlayerIdle(survivor);
}

stock bool bIsHunter(int hunter, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsInfected(hunter, flags) && GetEntProp(hunter, Prop_Send, "m_zombieClass") == 3;
}

stock bool bIsIdlePlayer(int bot, int survivor, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT)
{
	return bIsValidClient(survivor, flags) && GetClientTeam(bot) == 2;
}

stock bool bIsInfected(int infected, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsValidClient(infected, flags) && GetClientTeam(infected) == 3;
}

stock bool bIsInfectedGhost(int infected)
{
	return !!GetEntProp(infected, Prop_Send, "m_isGhost");
}

stock bool bIsJockey(int jockey, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsInfected(jockey, flags) && bIsSecondGame() && GetEntProp(jockey, Prop_Send, "m_zombieClass") == 5;
}

stock bool bIsNormalMap()
{
	return FindEntityByClassname(-1, "info_changelevel") != -1 || FindEntityByClassname(-1, "trigger_changelevel") != -1 || (FindEntityByClassname(-1, "trigger_finale") == -1 && FindEntityByClassname(-1, "finale_trigger") == -1);
}

stock bool bIsPlayerBurning(int player)
{
	return GetEntPropFloat(player, Prop_Send, "m_burnPercent") > 0.0 || (GetEntProp(player, Prop_Data, "m_fFlags") & FL_ONFIRE);
}

stock bool bIsPlayerIdle(int survivor)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!bIsSurvivor(iPlayer) || !bIsBotSurvivor(iPlayer))
		{
			continue;
		}

		int iSpectatorUserId = GetEntProp(iPlayer, Prop_Send, "m_humanSpectatorUserID");
		if (iSpectatorUserId > 0)
		{
			return GetClientOfUserId(iSpectatorUserId) == survivor;
		}
	}

	return false;
}

stock bool bIsPlayerIncapacitated(int player)
{
	return !!GetEntProp(player, Prop_Send, "m_isIncapacitated", 1);
}

stock bool bIsPlayerInThirdPerson(int player, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT)
{
	if (bIsTank(player, flags))
	{
		switch (GetEntProp(player, Prop_Send, "m_nSequence"))
		{
			case 28, 29, 30, 31, 47, 48, 49, 50, 51, 73, 74, 75, 76, 77: return true;
		}
	}
	else if (bIsSurvivor(player, flags))
	{
		char sModel[32];
		GetEntPropString(player, Prop_Data, "m_ModelName", sModel, sizeof sModel);
		int iSequence = GetEntProp(player, Prop_Send, "m_nSequence");
		if (bIsSecondGame())
		{
			switch (sModel[29])
			{
				case 'b': // Nick
				{
					return iSequence == 626 || iSequence == 625 || iSequence == 624 || iSequence == 623 || iSequence == 622 || iSequence == 621 || iSequence == 661
						|| iSequence == 662 || iSequence == 664 || iSequence == 665 || iSequence == 666 || iSequence == 667 || iSequence == 668 || iSequence == 670
						|| iSequence == 671 || iSequence == 672 || iSequence == 673 || iSequence == 674 || iSequence == 620 || iSequence == 680 || iSequence == 616;
				}
				case 'd': // Rochelle
				{
					return iSequence == 674 || iSequence == 678 || iSequence == 679 || iSequence == 630 || iSequence == 631 || iSequence == 632 || iSequence == 633 || iSequence == 634
						|| iSequence == 668 || iSequence == 677 || iSequence == 681 || iSequence == 680 || iSequence == 676 || iSequence == 675 || iSequence == 673
						|| iSequence == 672 || iSequence == 671 || iSequence == 670 || iSequence == 687 || iSequence == 629 || iSequence == 625 || iSequence == 616;
				}
				case 'c': // Coach
				{
					return iSequence == 656 || iSequence == 622 || iSequence == 623 || iSequence == 624 || iSequence == 625 || iSequence == 626 || iSequence == 663
						|| iSequence == 662 || iSequence == 661 || iSequence == 660 || iSequence == 659 || iSequence == 658 || iSequence == 657 || iSequence == 654
						|| iSequence == 653 || iSequence == 652 || iSequence == 651 || iSequence == 621 || iSequence == 620 || iSequence == 669 || iSequence == 615;
				}
				case 'h': // Ellis
				{
					return iSequence == 625 || iSequence == 675 || iSequence == 626 || iSequence == 627 || iSequence == 628 || iSequence == 629 || iSequence == 630 || iSequence == 631
						|| iSequence == 678 || iSequence == 677 || iSequence == 676 || iSequence == 575 || iSequence == 674 || iSequence == 673 || iSequence == 672 || iSequence == 671
						|| iSequence == 670 || iSequence == 669 || iSequence == 668 || iSequence == 667 || iSequence == 666 || iSequence == 665 || iSequence == 684 || iSequence == 621;
				}
				case 'v': // Bill
				{
					return iSequence == 528 || iSequence == 759 || iSequence == 763 || iSequence == 764 || iSequence == 529 || iSequence == 530 || iSequence == 531 || iSequence == 532
						|| iSequence == 533 || iSequence == 534 || iSequence == 753 || iSequence == 676 || iSequence == 675 || iSequence == 761 || iSequence == 758 || iSequence == 757
						|| iSequence == 756 || iSequence == 755 || iSequence == 754 || iSequence == 527 || iSequence == 772 || iSequence == 762 || iSequence == 522;
				}
				case 'n': // Zoey
				{
					return iSequence == 537 || iSequence == 819 || iSequence == 823 || iSequence == 824 || iSequence == 538 || iSequence == 539 || iSequence == 540 || iSequence == 541
						|| iSequence == 542 || iSequence == 543 || iSequence == 813 || iSequence == 828 || iSequence == 825 || iSequence == 822 || iSequence == 821 || iSequence == 820
						|| iSequence == 818 || iSequence == 817 || iSequence == 816 || iSequence == 815 || iSequence == 814 || iSequence == 536 || iSequence == 809 || iSequence == 572;
				}
				case 'e': // Francis
				{
					return iSequence == 532 || iSequence == 533 || iSequence == 534 || iSequence == 535 || iSequence == 536 || iSequence == 537 || iSequence == 769 || iSequence == 768
						|| iSequence == 767 || iSequence == 766 || iSequence == 765 || iSequence == 764 || iSequence == 763 || iSequence == 762 || iSequence == 761 || iSequence == 760
						|| iSequence == 759 || iSequence == 758 || iSequence == 757 || iSequence == 756 || iSequence == 531 || iSequence == 530 || iSequence == 775 || iSequence == 525;
				}
				case 'a': // Louis
				{
					return iSequence == 529 || iSequence == 530 || iSequence == 531 || iSequence == 532 || iSequence == 533 || iSequence == 534 || iSequence == 766 || iSequence == 765
						|| iSequence == 764 || iSequence == 763 || iSequence == 762 || iSequence == 761 || iSequence == 760 || iSequence == 759 || iSequence == 758 || iSequence == 757
						|| iSequence == 756 || iSequence == 755 || iSequence == 754 || iSequence == 753 || iSequence == 527 || iSequence == 772 || iSequence == 528 || iSequence == 522;
				}
			}
		}
		else
		{
			switch (sModel[29])
			{
				case 'v': return iSequence == 535 || iSequence == 537 || iSequence == 539 || iSequence == 540 || iSequence == 541; // Bill
				case 'n': return iSequence == 517 || iSequence == 519 || iSequence == 521 || iSequence == 522 || iSequence == 523; // Zoey
				case 'e': return iSequence == 536 || iSequence == 538 || iSequence == 540 || iSequence == 541 || iSequence == 542; // Francis
				case 'a': return iSequence == 535 || iSequence == 537 || iSequence == 539 || iSequence == 540 || iSequence == 541; // Louis
			}
		}
	}

	return bIsPlayerIncapacitated(player) || (bIsSecondGame() && GetEntPropFloat(player, Prop_Send, "m_TimeForceExternalView") > GetGameTime()) || GetEntPropFloat(player, Prop_Send, "m_staggerTimer", 1) > -1.0 || GetEntPropEnt(player, Prop_Send, "m_hViewEntity") > 0;
}

stock bool bIsPlayerPositionFixed(int client, float radius, float zAxis, bool noVelocity = true)
{
	float flDegreeAngle, flPos[3], flOrigin[3], flAngles[3];
	GetClientAbsOrigin(client, flOrigin);
	GetClientEyeAngles(client, flAngles);
	flPos[2] = flOrigin[2] + zAxis;

	flDegreeAngle = -180.0;
	while (flDegreeAngle < 180.0)
	{
		flPos[0] = (flOrigin[0] + (radius * Cosine(flDegreeAngle * (FLOAT_PI / 180))));
		flPos[1] = (flOrigin[1] + (radius * Sine(flDegreeAngle * (FLOAT_PI / 180))));
		TeleportEntity(client, flPos, flAngles, .velocity = (noVelocity ? view_as<float>({0.0, 0.0, -300.0}) : NULL_VECTOR));

		if (!bIsPlayerStuck(client))
		{
			return true;
		}

		flDegreeAngle += 10.0;
	}

	TeleportEntity(client, flOrigin, flAngles, .velocity = (noVelocity ? view_as<float>({0.0, 0.0, -300.0}) : NULL_VECTOR));

	if (radius <= 200.0)
	{
		return bIsPlayerPositionFixed(client, (radius + 20.0), zAxis, noVelocity);
	}

	return false;
}

stock bool bIsPlayerStuck(int client = 0, float min[3] = {0.0, 0.0, 0.0}, float max[3] = {0.0, 0.0, 0.0}, float pos[3] = {0.0, 0.0, 0.0})
{
	float flMin[3], flMax[3], flOrigin[3];
	if (client > 0)
	{
		GetClientMins(client, flMin);
		GetClientMaxs(client, flMax);
		GetClientAbsOrigin(client, flOrigin);
	}
	else
	{
		vCopyVector(min, flMin);
		vCopyVector(max, flMax);
		vCopyVector(pos, flOrigin);
	}

	TR_TraceHullFilter(flOrigin, flOrigin, flMin, flMax, MASK_PLAYERSOLID, bTraceRayDontHitSelfAndSolid);
	return TR_GetEntityIndex() != -1;
}

stock bool bIsPlayerStuckInEntity(int entity, int client = 0, float min[3] = {0.0, 0.0, 0.0}, float max[3] = {0.0, 0.0, 0.0}, float pos[3] = {0.0, 0.0, 0.0})
{
	float flMin[3], flMax[3], flOrigin[3];
	if (client > 0)
	{
		GetClientMins(client, flMin);
		GetClientMaxs(client, flMax);
		GetClientAbsOrigin(client, flOrigin);
	}
	else
	{
		vCopyVector(min, flMin);
		vCopyVector(max, flMax);
		vCopyVector(pos, flOrigin);
	}

	TR_TraceHullFilter(flOrigin, flOrigin, flMin, flMax, MASK_ALL, bTraceRayHitEntity, entity);
	return TR_DidHit();
}

stock bool bIsSecondGame()
{
	static EngineVersion evEngine = Engine_Unknown;
	if (evEngine == Engine_Unknown)
	{
		evEngine = GetEngineVersion();
	}

	return evEngine == Engine_Left4Dead2;
}

stock bool bIsSmoker(int smoker, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsInfected(smoker, flags) && GetEntProp(smoker, Prop_Send, "m_zombieClass") == 1;
}

stock bool bIsSpecialInfected(int infected, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsSmoker(infected, flags) || bIsBoomer(infected, flags) || bIsHunter(infected, flags) || bIsSpitter(infected, flags) || bIsJockey(infected, flags) || bIsCharger(infected, flags);
}

stock bool bIsSpectator(int spectator, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	return bIsValidClient(spectator, flags) && GetClientTeam(spectator) == 1;
}

stock bool bIsSpitter(int spitter, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsInfected(spitter, flags) && bIsSecondGame() && GetEntProp(spitter, Prop_Send, "m_zombieClass") == 4;
}

stock bool bIsSurvivor(int survivor, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE, bool both = false)
{
	return bIsValidClient(survivor, flags) && (GetClientTeam(survivor) == 2 || (both && GetClientTeam(survivor) == 4));
}

stock bool bIsSurvivorCaught(int survivor)
{
	int iSpecial = GetEntPropEnt(survivor, Prop_Send, "m_pounceAttacker");
	iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_tongueOwner") : iSpecial;
	if (bIsSecondGame())
	{
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_pummelAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_carryAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_jockeyAttacker") : iSpecial;
	}

	return iSpecial > 0;
}

stock bool bIsSurvivorDisabled(int survivor)
{
	return bIsSurvivorHanging(survivor) || bIsPlayerIncapacitated(survivor);
}

stock bool bIsSurvivorHanging(int survivor)
{
	return !!GetEntProp(survivor, Prop_Send, "m_isHangingFromLedge") || !!GetEntProp(survivor, Prop_Send, "m_isFallingFromLedge");
}

stock bool bIsTank(int tank, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	int iClass = bIsSecondGame() ? 8 : 5;
	return bIsInfected(tank, flags) && GetEntProp(tank, Prop_Send, "m_zombieClass") == iClass;
}

stock bool bIsTankInStasis(int tank)
{
	return bIsSecondGame() && !!GetEntProp(tank, Prop_Data, "m_bIsInStasis");
}

stock bool bIsTankVisible(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsVisibleToPlayer(iSurvivor, tank, 1))
		{
			return true;
		}
	}

	return false;
}

stock bool bIsValidClient(int player, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	if (((flags & MT_CHECK_INDEX) && (player <= 0 || player > MaxClients)) || ((flags & MT_CHECK_CONNECTED) && !IsClientConnected(player))
		|| ((flags & MT_CHECK_INGAME) && !IsClientInGame(player)) || ((flags & MT_CHECK_ALIVE) && !IsPlayerAlive(player))
		|| ((flags & MT_CHECK_INKICKQUEUE) && IsClientInKickQueue(player)) || ((flags & MT_CHECK_FAKECLIENT) && IsFakeClient(player)))
	{
		return false;
	}

	return true;
}

stock bool bIsValidEntity(int entity, bool override = false, int start = 0)
{
	int iIndex = override ? start : MaxClients;
	return entity > iIndex && IsValidEntity(entity);
}

stock bool bIsValidEntRef(int ref)
{
	return ref && EntRefToEntIndex(ref) != INVALID_ENT_REFERENCE;
}

stock bool bIsVisiblePosition(float pos1[3], float pos2[3], int entity, int type)
{
	Handle hTrace = null;

	switch (type)
	{
		case 1: hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndSurvivor, entity);
		case 2: hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndInfected, entity);
		case 3: hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndCommons, entity);
		case 4: hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndPlayer, entity);
	}

	if (hTrace != null)
	{
		if (TR_DidHit(hTrace))
		{
			delete hTrace;
			return false;
		}

		delete hTrace;
	}

	return true;
}

stock bool bIsVisibleToPlayer(int player, int target, int type, float playerPos[3] = NULL_VECTOR, float targetPos[3] = NULL_VECTOR, float range = 0.0, float threshold = 0.73)
{
	bool bReturn = true;

	switch (type)
	{
		case 0: return true;
		case 1, 2, 3, 4, 5:
		{
			float flPlayerPos[3], flTargetPos[3];

			switch (IsNullVector(playerPos))
			{
				case true: GetClientEyePosition(player, flPlayerPos);
				case false: vCopyVector(playerPos, flPlayerPos);
			}

			switch (IsNullVector(targetPos))
			{
				case true: GetClientEyePosition(target, flTargetPos);
				case false: vCopyVector(targetPos, flTargetPos);
			}

			if (2 <= type <= 3)
			{
				float flPlayerAngles[3];
				GetClientEyeAngles(player, flPlayerAngles);
				flPlayerAngles[0] = flPlayerAngles[2] = 0.0;

				float flPlayerDirection[3], flDistance[3];
				GetAngleVectors(flPlayerAngles, flPlayerDirection, NULL_VECTOR, NULL_VECTOR);
				flDistance[0] = flTargetPos[0] - flPlayerPos[0];
				flDistance[1] = flTargetPos[1] - flPlayerPos[1];
				flDistance[2] = 0.0;
				if (range != 0.0 && ((flDistance[0] * flDistance[0]) + (flDistance[1] * flDistance[1])) >= (range * range))
				{
					return false;
				}

				float flTargetDirection[3];
				NormalizeVector(flDistance, flTargetDirection);

				switch (GetVectorDotProduct(flPlayerDirection, flTargetDirection) < threshold)
				{
					case true: return type == 3;
					case false: bReturn = type == 2;
				}
			}
			else if (4 <= type <= 5)
			{
				float flPlayerAngles[3];
				GetClientEyeAngles(target, flPlayerAngles);
				flPlayerAngles[0] = flPlayerAngles[2] = 0.0;

				float flPlayerDirection[3], flDistance[3];
				GetAngleVectors(flPlayerAngles, flPlayerDirection, NULL_VECTOR, NULL_VECTOR);
				flDistance[0] = flPlayerPos[0] - flTargetPos[0];
				flDistance[1] = flPlayerPos[1] - flTargetPos[1];
				flDistance[2] = 0.0;
				if (range != 0.0 && ((flDistance[0] * flDistance[0]) + (flDistance[1] * flDistance[1])) >= (range * range))
				{
					return false;
				}

				float flTargetDirection[3];
				NormalizeVector(flDistance, flTargetDirection);

				switch (GetVectorDotProduct(flPlayerDirection, flTargetDirection) < threshold)
				{
					case true: return type == 5;
					case false: bReturn = type == 4;
				}
			}

			Handle hTrace = TR_TraceRayFilterEx(flPlayerPos, flTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, bTraceRayDontHitSelfAndPlayer);
			if (hTrace != null)
			{
				if (TR_DidHit(hTrace))
				{
					delete hTrace;
					return false;
				}

				delete hTrace;
			}
		}
	}

	return bReturn;
}

stock bool bIsVisibleToPosition(int entity, float pos1[3], float pos2[3], float range)
{
	float flPos[3], flAngles[3];
	MakeVectorFromPoints(pos1, pos2, flPos);
	GetVectorAngles(flPos, flAngles);

	Handle hTrace = TR_TraceRayFilterEx(pos1, flAngles, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndSolid, entity);
	if (hTrace != null)
	{
		if (TR_DidHit(hTrace))
		{
			TR_GetEndPosition(flPos, hTrace);

			if (GetVectorDistance(flPos, pos2) <= range)
			{
				delete hTrace;
				return true;
			}
		}

		delete hTrace;
	}

	return false;
}

stock bool bIsWitch(int witch)
{
	if (bIsValidEntity(witch))
	{
		char sClassname[32];
		GetEntityClassname(witch, sClassname, sizeof sClassname);
		return StrEqual(sClassname, "witch");
	}

	return false;
}

// Command target filters
bool bBoomerFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsBoomer(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bChargerFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsCharger(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bHunterFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsHunter(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bInfectedFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsInfected(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bJockeyFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsJockey(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bMutantFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsInfected(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && MT_GetRecordedTankType(iPlayer) > 0)
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bMutantBoomerFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsBoomer(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && MT_GetRecordedTankType(iPlayer) > 0)
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bMutantChargerFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsCharger(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && MT_GetRecordedTankType(iPlayer) > 0)
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bMutantHunterFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsHunter(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && MT_GetRecordedTankType(iPlayer) > 0)
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bMutantJockeyFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsJockey(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && MT_GetRecordedTankType(iPlayer) > 0)
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bMutantSmokerFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSmoker(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && MT_GetRecordedTankType(iPlayer) > 0)
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bMutantSpitterFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSpitter(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && MT_GetRecordedTankType(iPlayer) > 0)
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bMutantTankFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsTank(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && MT_GetRecordedTankType(iPlayer) > 0)
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bSmokerFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSmoker(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bSpecialFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSpecialInfected(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bSpitterFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSpitter(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

bool bTankFilter(const char[] pattern, ArrayList clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsTank(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			clients.Push(iPlayer);
		}
	}

	return true;
}

// Trace ray filters
public bool bTraceRayDontHitSelf(int entity, int mask, any data)
{
	return entity != data;
}

public bool bTraceRayDontHitSelfAndCommons(int entity, int mask, any data)
{
	return entity != data && !bIsCommonInfected(entity);
}

public bool bTraceRayDontHitSelfAndInfected(int entity, int mask, any data)
{
	return entity != data && !bIsInfected(entity);
}

public bool bTraceRayDontHitSelfAndPlayer(int entity, int mask, any data)
{
	return entity != data && !bIsValidClient(entity, MT_CHECK_INDEX|MT_CHECK_INGAME);
}

public bool bTraceRayDontHitSelfAndSurvivor(int entity, int mask, any data)
{
	return entity != data && !bIsSurvivor(entity, .both = true);
}

public bool bTraceRayDontHitSelfAndSolid(int entity, int mask)
{
	return entity > MaxClients;
}

public bool bTraceRayHitEntity(int entity, int mask, any data)
{
	return entity == data;
}

// Getters
stock void vGetDayName(int day, char[] buffer, int size)
{
	switch (day)
	{
		case 0: strcopy(buffer, size, "sunday");
		case 1: strcopy(buffer, size, "monday");
		case 2: strcopy(buffer, size, "tuesday");
		case 3: strcopy(buffer, size, "wednesday");
		case 4: strcopy(buffer, size, "thursday");
		case 5: strcopy(buffer, size, "friday");
		case 6: strcopy(buffer, size, "saturday");
	}
}

stock void vGetDoubleFromFloat(float value, int save[2])
{
	int iValue = view_as<int>(value), iSign = (iValue & 0x80000000) ? 1 : 0,
		iExponent = (((iValue & 0x7F800000) >> 23) - 127) + 1023,
		iMantissa = (iValue & 0x7FFFFF) << 1;

	save[0] = iSign << 31;
	save[0] |= iExponent << 20;
	save[0] |= (iMantissa >> 4) & 0xFFFFF;
	save[1] = iMantissa << 28;
}

stock void vGetEntityMidOrigin(int entity, float origin[3])
{
	float flMins[3], flMaxes[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
	GetEntPropVector(entity, Prop_Send, "m_vecMins", flMins);
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", flMaxes);

	origin[0] += (flMins[0] + flMaxes[0]) * 0.5;
	origin[1] += (flMins[1] + flMaxes[1]) * 0.5;
	origin[2] += (flMins[2] + flMaxes[2]) * 0.5;
}

stock void vGetKeyValue(const char[] subsection, const char[] sub1, const char[] sub2, const char[] sub3, const char[] sub4, const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, char[] buffer, int size, const char[] value)
{
	if (value[0] != '\0' && (StrEqual(subsection, sub1, false) || StrEqual(subsection, sub2, false) || StrEqual(subsection, sub3, false) || StrEqual(subsection, sub4, false)))
	{
		if (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false))
		{
			strcopy(buffer, size, value);
		}
	}
}

stock void vGetKeyValueEx(const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, char[] buffer, int size, const char[] value)
{
	if (value[0] != '\0' && (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
	{
		strcopy(buffer, size, value);
	}
}

stock void vGetMatchingFilename(const char[] directory, const char[] filename, char[] buffer, int size)
{
	DirectoryListing dlList = OpenDirectory(directory);
	if (dlList != null)
	{
		char sFilename[PLATFORM_MAX_PATH];
		while (dlList.GetNext(sFilename, sizeof sFilename))
		{
			if (StrEqual(sFilename, filename, false))
			{
				strcopy(buffer, size, sFilename);

				break;
			}
		}

		delete dlList;
	}
}

stock void vGetSettingValue(bool apply, bool human, char[] buffer, int size, const char[] playerVal, const char[] typeVal)
{
	switch (apply)
	{
		case true: FormatEx(buffer, size, "%s", ((human && playerVal[0] != '\0') ? playerVal : typeVal));
		case false: buffer[0] = '\0';
	}
}

stock void vGetStringValue(const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, int pos, char[] buffer1, int size1, char[] buffer2, int size2, char[] buffer3, int size3, char[] buffer4, int size4, const char[] value)
{
	if (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false))
	{
		switch (pos)
		{
			case 0: strcopy(buffer1, size1, value);
			case 1: strcopy(buffer2, size2, value);
			case 2: strcopy(buffer3, size3, value);
			case 3: strcopy(buffer4, size4, value);
		}
	}
}

stock void vGetSubSettingValue(bool apply, bool human, char[] buffer, int size, const char[] teamVal, const char[] playerVal, const char[] specVal, const char[] typeVal)
{
	switch (apply)
	{
		case true:
		{
			char sPlayerVal[PLATFORM_MAX_PATH], sTypeVal[PLATFORM_MAX_PATH];
			strcopy(sPlayerVal, sizeof sPlayerVal, ((teamVal[0] != '\0') ? teamVal : playerVal));
			strcopy(sTypeVal, sizeof sTypeVal, ((specVal[0] != '\0') ? specVal : typeVal));
			FormatEx(buffer, size, "%s", ((human && sPlayerVal[0] != '\0') ? sPlayerVal : sTypeVal));
		}
		case false: buffer[0] = '\0';
	}
}

stock float flGetAdrenalineTime(int survivor)
{
	if (!bIsSecondGame())
	{
		return -1.0;
	}

	static int iTimerAddress = -1;
	if (iTimerAddress == -1)
	{
		iTimerAddress = FindSendPropInfo("CTerrorPlayer", "m_bAdrenalineActive") - 12;
	}

	float flTime = GetGameTime(), flDuration = GetEntDataFloat(survivor, iTimerAddress + 8);
	if (flDuration <= flTime)
	{
		return -1.0;
	}

	return flDuration - flTime;
}

stock float flGetAngle(float angles1[3], float angles2[3])
{
	return ArcCosine(GetVectorDotProduct(angles1, angles2) / (GetVectorLength(angles1) * GetVectorLength(angles2)));
}

stock float flGetClampedValue(const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, float curVal, const char[] value, float min, float max, float check = -1.0)
{
	if (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false))
	{
		float flDefault = (check == -1.0) ? curVal : -1.0;
		return (value[0] != '\0' && (check == -1.0 || StringToFloat(value) >= check)) ? flClamp(StringToFloat(value), min, max) : flDefault;
	}

	return curVal;
}

stock float flGetDistance(float pos[3], float angles[3], float offset1, float offset2, float force[3], int entity, int type)
{
	float flAngle[3];
	vCopyVector(angles, flAngle);
	flAngle[0] += offset1;
	flAngle[1] += offset2;
	GetAngleVectors(flAngle, force, NULL_VECTOR, NULL_VECTOR);

	return flGetRayDistance(pos, flAngle, entity, type);
}

stock float flGetGroundUnits(int entity)
{
	if (!(GetEntityFlags(entity) & FL_ONGROUND))
	{
		float flOrigin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flOrigin);

		Handle hTrace = TR_TraceRayFilterEx(flOrigin, view_as<float>({90.0, 0.0, 0.0}), CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, bTraceRayDontHitSelf, entity);
		if (hTrace != null)
		{
			if (TR_DidHit(hTrace))
			{
				float flPos[3];
				TR_GetEndPosition(flPos, hTrace);

				delete hTrace;
				return flOrigin[2] - flPos[2];
			}

			delete hTrace;
		}
	}

	return 0.0;
}

stock float flGetKeyValue(const char[] subsection, const char[] sub1, const char[] sub2, const char[] sub3, const char[] sub4, const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, float curVal, const char[] value, float min, float max)
{
	if (FindCharInString(subsection, ',') != -1)
	{
		char sSet[16][16];
		ExplodeString(subsection, ",", sSet, sizeof sSet, sizeof sSet[]);
		for (int iPos = 0; iPos < (sizeof sSet); iPos++)
		{
			if (sSet[iPos][0] != '\0' && value[0] != '\0' && (StrEqual(sSet[iPos], "all", false) || StrEqual(sSet[iPos], sub1, false) || StrEqual(sSet[iPos], sub2, false) || StrEqual(sSet[iPos], sub3, false)
				|| StrEqual(sSet[iPos], sub4, false)) && (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
			{
				return flGetKeywordValue(key, curVal, value, min, max);
			}
		}
	}
	else if (value[0] != '\0' && (StrEqual(subsection, "all", false) || StrEqual(subsection, sub1, false) || StrEqual(subsection, sub2, false) || StrEqual(subsection, sub3, false)
		|| StrEqual(subsection, sub4, false)) && (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
	{
		return flGetKeywordValue(key, curVal, value, min, max);
	}

	return curVal;
}

stock float flGetKeyValueEx(const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, float curVal, const char[] value, float min, float max)
{
	if (value[0] != '\0' && (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
	{
		return flGetKeywordValue(key, curVal, value, min, max);
	}

	return curVal;
}

stock float flGetKeywordValue(const char[] key, float curVal, const char[] value, float min, float max)
{
	if (StrEqual(value, "default", false))
	{
		return curVal;
	}
	else if (StrEqual(value, "min", false))
	{
		return min;
	}
	else if (StrEqual(value, "max", false))
	{
		return max;
	}
	else if (StrContains(key, "chance", false) != -1 && min == 0.0 && max == 100.0)
	{
		if (StrEqual(value, "never", false))
		{
			return min;
		}
		else if (StrEqual(value, "sometimes", false) || StrEqual(value, "unlikely", false) || StrEqual(value, "seldom", false))
		{
			return 33.3;
		}
		else if (StrEqual(value, "maybe", false))
		{
			return max / 2.0;
		}
		else if (StrEqual(value, "often", false) || StrEqual(value, "likely", false) || StrEqual(value, "frequently", false))
		{
			return 66.6;
		}
		else if (StrEqual(value, "always", false))
		{
			return max;
		}
	}
	else if ((min == -1.0 || min == 1.0) && max == 99999.0)
	{
		bool bDamageSetting = StrContains(key, "damage", false) != -1,
			bForceSetting = (StrContains(key, "force", false) != -1 || StrContains(key, "radius", false) != -1),
			bRangeSetting = StrContains(key, "range", false) != -1;
		if (min == -1.0 && (bDamageSetting || bForceSetting) && (StrEqual(value, "nodmg", false) || StrEqual(value, "friendly", false) || StrEqual(value, "harmless", false)))
		{
			return 0.0;
		}
		else if (((bDamageSetting || bForceSetting) && StrEqual(value, "weakest", false)) || (bRangeSetting && StrEqual(value, "closest", false)))
		{
			return min;
		}
		else if (((bDamageSetting || bForceSetting) && StrEqual(value, "strongest", false)) || (bRangeSetting && StrEqual(value, "farthest", false)))
		{
			return max;
		}
	}
	else if ((!strncmp(key, "open", 4, false) || !strncmp(key, "close", 5, false)) && min == 0.0 && max == 99999.0)
	{
		if (StrEqual(value, "disabled", false) || StrEqual(value, "false", false) || StrEqual(value, "off", false) || StrEqual(value, "no", false))
		{
			return min;
		}
		else if (StrEqual(value, "farthest", false))
		{
			return max;
		}
	}
	else if ((StrContains(key, "cooldown", false) != -1 || StrContains(key, "delay", false) != -1 || StrContains(key, "duration", false) != -1 || StrContains(key, "interval", false) != -1 || StrContains(key, "lifetime", false) != -1) && (min == -1.0 || min == 0.0 || min == 0.1) && max == 99999.0)
	{
		if (min == 0.0 && (StrEqual(value, "never", false) || StrEqual(value, "disabled", false) || StrEqual(value, "false", false) || StrEqual(value, "off", false) || StrEqual(value, "no", false)))
		{
			return min;
		}
		else if (StrEqual(value, "milli", false) || StrEqual(value, "millisecond", false))
		{
			return (min == 0.1) ? min : 0.1;
		}
		else if (StrEqual(value, "second", false))
		{
			return 1.0;
		}
		else if (StrEqual(value, "minute", false))
		{
			return 60.0;
		}
		else if (StrEqual(value, "forever", false))
		{
			return max;
		}
	}
	else if (StrContains(key, "height", false) != -1 && min == 0.1 && max == 99999.0)
	{
		if (StrEqual(value, "shortest", false))
		{
			return min;
		}
		else if (StrEqual(value, "tallest", false))
		{
			return max;
		}
	}

	return flClamp(StringToFloat(value), min, max);
}

stock float flGetRayDistance(float pos[3], float angles[3], int entity, int type)
{
	float flHitPos[3];
	iGetRayHitPos(pos, angles, flHitPos, entity, false, type);
	return GetVectorDistance(pos, flHitPos);
}

stock float flGetSettingValue(bool apply, bool human, float playerVal, float typeVal, int overrideLevel = 0, float overrideVal = 0.0)
{
	if (apply)
	{
		switch (overrideLevel)
		{
			case 0: return (human && playerVal > overrideVal) ? playerVal : typeVal;
			case 1: return (human && playerVal >= overrideVal) ? playerVal : typeVal;
			case 2: return (human && playerVal != overrideVal) ? playerVal : typeVal;
		}
	}

	return (overrideLevel == 1) ? -1.0 : 0.0;
}

stock float flGetSubSettingValue(bool apply, bool human, float teamVal, float playerVal, float specVal, float typeVal, int overrideLevel = 0, float overrideVal = 0.0)
{
	if (apply)
	{
		float flPlayerVal = overrideVal, flTypeVal = overrideVal;

		switch (overrideLevel)
		{
			case 0:
			{
				flPlayerVal = (teamVal > overrideVal) ? teamVal : playerVal;
				flTypeVal = (specVal > overrideVal) ? specVal : typeVal;
				return (human && flPlayerVal > overrideVal) ? flPlayerVal : flTypeVal;
			}
			case 1:
			{
				flPlayerVal = (teamVal >= overrideVal) ? teamVal : playerVal;
				flTypeVal = (specVal >= overrideVal) ? specVal : typeVal;
				return (human && flPlayerVal >= overrideVal) ? flPlayerVal : flTypeVal;
			}
			case 2:
			{
				flPlayerVal = (teamVal != overrideVal) ? teamVal : playerVal;
				flTypeVal = (specVal != overrideVal) ? specVal : typeVal;
				return (human && flPlayerVal != overrideVal) ? flPlayerVal : flTypeVal;
			}
		}
	}

	return (overrideLevel == 1) ? -1.0 : 0.0;
}

stock float flGetTempHealth(int survivor, float decayRate)
{
	float flTempHealth = GetEntPropFloat(survivor, Prop_Send, "m_healthBuffer");
	flTempHealth -= (GetGameTime() - GetEntPropFloat(survivor, Prop_Send, "m_healthBufferTime")) * decayRate;
	return (flTempHealth < 0.0) ? 0.0 : flTempHealth;
}

stock int iGetAdminFlagsValue(const char[] subsection, const char[] sub1, const char[] sub2, const char[] sub3, const char[] sub4, const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, const char[] value)
{
	if (StrEqual(subsection, sub1, false) || StrEqual(subsection, sub2, false) || StrEqual(subsection, sub3, false) || StrEqual(subsection, sub4, false))
	{
		if (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false))
		{
			return ReadFlagString(value);
		}
	}

	return 0;
}

stock int iGetBotSurvivor()
{
	for (int iBot = MaxClients; iBot > 0; iBot--)
	{
		if (bIsBotSurvivor(iBot, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			return iBot;
		}
	}

	return -1;
}

stock int iGetClampedValue(const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, int curVal, const char[] value, int min, int max, int check = -1)
{
	if (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false))
	{
		int iDefault = (check == -1) ? curVal : -1;
		return (value[0] != '\0' && (check == -1 || StringToInt(value) >= check)) ? iClamp(StringToInt(value), min, max) : iDefault;
	}

	return curVal;
}

stock int iGetEntityIndex(int ref)
{
	return (ref & ENT_ENTRY_MASK);
}

stock int iGetHumanCount(bool infected = false)
{
	bool bValidPlayer = false;
	int iHumanCount = 0;
	for (int iHuman = 1; iHuman <= MaxClients; iHuman++)
	{
		bValidPlayer = infected ? bIsInfected(iHuman, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) : bIsSurvivor(iHuman, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT);
		if (bValidPlayer)
		{
			iHumanCount++;
		}
	}

	return iHumanCount;
}

stock int iGetIdleBot(int bot)
{
	for (int iBot = 1; iBot <= MaxClients; iBot++)
	{
		if (iGetIdlePlayer(iBot) == bot)
		{
			return iBot;
		}
	}

	return 0;
}

stock int iGetIdlePlayer(int bot)
{
	if (bIsBotSurvivor(bot))
	{
		int iIdler = GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));
		if (iIdler > 0 && bIsValidClient(iIdler, MT_CHECK_INGAME) && GetClientTeam(iIdler) == 1)
		{
			return iIdler;
		}
	}

	return 0;
}

stock int iGetInfectedCount(bool human = false, int flags = MT_CHECK_INGAME)
{
	bool bValidPlayer = false;
	int iCount = 0;
	for (int iSpecial = 1; iSpecial <= MaxClients; iSpecial++)
	{
		bValidPlayer = human ? bIsHumanInfected(iSpecial, flags) : bIsInfected(iSpecial, flags);
		if (bValidPlayer)
		{
			iCount++;
		}
	}

	return iCount;
}

stock int iGetInfectedType(int client)
{
	if (bIsSmoker(client, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		return 1;
	}
	else if (bIsBoomer(client, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		return 2;
	}
	else if (bIsHunter(client, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		return 3;
	}
	else if (bIsSpitter(client, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		return 4;
	}
	else if (bIsJockey(client, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		return 5;
	}
	else if (bIsCharger(client, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		return 6;
	}
	else if (bIsTank(client, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		return 8;
	}

	return 0;
}

stock int iGetInfectedVictim(int special, int type)
{
	switch (type)
	{
		case 1: return GetEntPropEnt(special, Prop_Send, "m_tongueVictim");
		case 3: return GetEntPropEnt(special, Prop_Send, "m_pounceVictim");
		case 5: return GetEntPropEnt(special, Prop_Send, "m_jockeyVictim");
		case 6:
		{
			int iVictim = GetEntPropEnt(special, Prop_Send, "m_carryVictim");
			return (iVictim <= 0) ? GetEntPropEnt(special, Prop_Send, "m_pummelVictim") : iVictim;
		}
	}

	return -1;
}

stock int iGetKeyValue(const char[] subsection, const char[] sub1, const char[] sub2, const char[] sub3, const char[] sub4, const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, int curVal, const char[] value, int min, int max)
{
	if (FindCharInString(subsection, ',') != -1)
	{
		char sSet[16][16];
		ExplodeString(subsection, ",", sSet, sizeof sSet, sizeof sSet[]);
		for (int iPos = 0; iPos < (sizeof sSet); iPos++)
		{
			if (sSet[iPos][0] != '\0' && value[0] != '\0' && (StrEqual(sSet[iPos], "all", false) || StrEqual(sSet[iPos], sub1, false) || StrEqual(sSet[iPos], sub2, false) || StrEqual(sSet[iPos], sub3, false)
				|| StrEqual(sSet[iPos], sub4, false)) && (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
			{
				return iGetKeywordValue(key, curVal, value, min, max);
			}
		}
	}
	else if (value[0] != '\0' && (StrEqual(subsection, "all", false) || StrEqual(subsection, sub1, false) || StrEqual(subsection, sub2, false) || StrEqual(subsection, sub3, false)
		|| StrEqual(subsection, sub4, false)) && (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
	{
		return iGetKeywordValue(key, curVal, value, min, max);
	}

	return curVal;
}

stock int iGetKeyValueEx(const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, int curVal, const char[] value, int min, int max)
{
	if (value[0] != '\0' && (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
	{
		return iGetKeywordValue(key, curVal, value, min, max);
	}

	return curVal;
}

stock int iGetKeywordValue(const char[] key, int curVal, const char[] value, int min, int max)
{
	if (StrEqual(value, "default", false))
	{
		return curVal;
	}
	else if (StrEqual(value, "min", false))
	{
		return min;
	}
	else if (StrEqual(value, "max", false))
	{
		return max;
	}
	else if (min <= 0 && max == 1)
	{
		if (min == -1 && (StrEqual(value, "ignore", false) || StrEqual(value, "exclude", false) || StrEqual(value, "filter", false) || StrEqual(value, "remove", false)))
		{
			return min;
		}
		else if (StrEqual(value, "disabled", false) || StrEqual(value, "false", false) || StrEqual(value, "off", false) || StrEqual(value, "no", false))
		{
			return (min == 0) ? min : 0;
		}
		else if (StrEqual(value, "enabled", false) || StrEqual(value, "true", false) || StrEqual(value, "on", false) || StrEqual(value, "yes", false))
		{
			return max;
		}
	}
	else if ((StrContains(key, "hitmode", false) != -1 || StrContains(key, "hit mode", false) != -1 || StrContains(key, "hit_mode", false) != -1) && min == 0 && max == 2)
	{
		if (StrEqual(value, "both", false) || StrEqual(value, "all", false))
		{
			return min;
		}
		else if (StrEqual(value, "tank", false) || StrEqual(value, "attack", false))
		{
			return 1;
		}
		else if (StrEqual(value, "survivor", false) || StrEqual(value, "hurt", false))
		{
			return max;
		}
	}
	else if (StrContains(key, "effect", false) != -1 && min == 0 && max == 7)
	{
		if (StrEqual(value, "none", false) || StrEqual(value, "off", false))
		{
			return min;
		}
		else if (StrEqual(value, "attack", false))
		{
			return 1;
		}
		else if (StrEqual(value, "hurt", false))
		{
			return 2;
		}
		else if (StrEqual(value, "attack,hurt", false))
		{
			return 3;
		}
		else if (StrEqual(value, "range", false))
		{
			return 4;
		}
		else if (StrEqual(value, "attack,range", false))
		{
			return 5;
		}
		else if (StrEqual(value, "hurt,range", false))
		{
			return 6;
		}
		else if (StrEqual(value, "attack,hurt,range", false) || StrEqual(value, "all", false))
		{
			return max;
		}
	}
	else if (StrContains(key, "message", false) != -1 && min == 0 && (max == 3 || max == 7 || max == 15))
	{
		if (StrEqual(value, "none", false) || StrEqual(value, "off", false))
		{
			return min;
		}
		else if (StrEqual(value, "hit", false))
		{
			return 1;
		}
		else if (StrEqual(value, "ability", false))
		{
			return 2;
		}
		else if ((max == 3 && (StrEqual(value, "both", false) || StrEqual(value, "all", false))) || StrEqual(value, "hit,ability", false))
		{
			return (max == 3) ? max : 3;
		}
		else if (max == 7)
		{
			if (StrEqual(value, "rock", false))
			{
				return 4;
			}
			else if (StrEqual(value, "hit,rock", false))
			{
				return 5;
			}
			else if (StrEqual(value, "ability,rock", false))
			{
				return 6;
			}
			else if (StrEqual(value, "hit,ability,rock", false) || StrEqual(value, "all", false))
			{
				return max;
			}
		}
		else if (max == 15)
		{
			if (StrEqual(value, "rock", false))
			{
				return 4;
			}
			else if (StrEqual(value, "hit,rock", false))
			{
				return 5;
			}
			else if (StrEqual(value, "ability,rock", false))
			{
				return 6;
			}
			else if (StrEqual(value, "hit,ability,rock", false))
			{
				return 7;
			}
			else if (StrEqual(value, "break", false))
			{
				return 8;
			}
			else if (StrEqual(value, "hit,break", false))
			{
				return 9;
			}
			else if (StrEqual(value, "ability,break", false))
			{
				return 10;
			}
			else if (StrEqual(value, "hit,ability,break", false))
			{
				return 11;
			}
			else if (StrEqual(value, "rock,break", false))
			{
				return 12;
			}
			else if (StrEqual(value, "hit,rock,break", false))
			{
				return 13;
			}
			else if (StrEqual(value, "ability,rock,break", false))
			{
				return 14;
			}
			else if (StrEqual(value, "hit,ability,rock,break", false) || StrEqual(value, "all", false))
			{
				return max;
			}
		}
	}
	else if ((StrContains(key, "humanammo", false) != -1 || StrContains(key, "human ammo", false) != -1 || StrContains(key, "human_ammo", false) != -1 || StrContains(key, "hammo", false) != -1) && min == 0 && max == 99999)
	{
		if (StrEqual(value, "none", false) || StrEqual(value, "off", false))
		{
			return min;
		}
		else if (StrEqual(value, "infinite", false))
		{
			return max;
		}
	}
	else if ((StrContains(key, "cooldown", false) != -1 || StrContains(key, "delay", false) != -1 || StrContains(key, "duration", false) != -1 || StrContains(key, "interval", false) != -1 || StrContains(key, "lifetime", false) != -1) && (min == 0 || min == 1) && max == 99999)
	{
		if (min == 0 && (StrEqual(value, "never", false) || StrEqual(value, "disabled", false) || StrEqual(value, "false", false) || StrEqual(value, "off", false) || StrEqual(value, "no", false)))
		{
			return min;
		}
		else if (StrEqual(value, "second", false))
		{
			return (min == 1) ? min : 1;
		}
		else if (StrEqual(value, "minute", false))
		{
			return 60;
		}
		else if (StrEqual(value, "forever", false))
		{
			return max;
		}
	}

	return iClamp(StringToInt(value), min, max);
}

stock int iGetListenServerHost(int client, bool dedicated)
{
	if (client == 0 && !dedicated)
	{
		int iManager = FindEntityByClassname(-1, "terror_player_manager");
		if (bIsValidEntity(iManager))
		{
			int iHostOffset = FindSendPropInfo("CTerrorPlayerResource", "m_listenServerHost");
			if (iHostOffset != -1)
			{
				bool bHost[MAXPLAYERS + 1];
				GetEntDataArray(iManager, iHostOffset, bHost, (MAXPLAYERS + 1), 1);

				for (int iPlayer = 1; iPlayer < (sizeof bHost); iPlayer++)
				{
					if (bHost[iPlayer])
					{
						return iPlayer;
					}
				}
			}
		}
	}

	return client;
}

stock int iGetNearestCommonInfected(int tank, float pos[3], float range)
{
	float flCommonPos[3];
	int iCommonCount = 0, iCommon = -1;
	int[] iCommons = new int[2048];
	while ((iCommon = FindEntityByClassname(iCommon, "infected")) != INVALID_ENT_REFERENCE)
	{
		if (bIsValidEntity(iCommon))
		{
			GetEntPropVector(iCommon, Prop_Send, "m_vecOrigin", flCommonPos);
			if (bIsVisibleToPosition(iCommon, pos, flCommonPos, range))
			{
				iCommons[iCommonCount] = iCommon;
				iCommonCount++;
			}
		}
	}

	return (iCommonCount > 0) ? iCommons[GetRandomInt(0, (iCommonCount - 1))] : 0;
}

stock int iGetNearestSpecialInfected(int tank, float pos[3], float range)
{
	float flInfectedPos[3];
	int iInfectedCount = 0;
	int[] iSpecials = new int[MaxClients + 1];
	for (int iSpecial = 1; iSpecial <= MaxClients; iSpecial++)
	{
		if (bIsInfected(iSpecial, MT_CHECK_INGAME|MT_CHECK_ALIVE) && tank != iSpecial)
		{
			GetClientEyePosition(iSpecial, flInfectedPos);
			if (bIsVisibleToPosition(iSpecial, pos, flInfectedPos, range))
			{
				iSpecials[iInfectedCount] = iSpecial;
				iInfectedCount++;
			}
		}
	}

	return (iInfectedCount > 0) ? iSpecials[GetRandomInt(0, (iInfectedCount - 1))] : 0;
}

stock int iGetNearestSurvivor(int tank, float pos[3], float range, bool noHumans = false, bool noBots = false, bool noIncaps = false)
{
	bool bHuman = false;
	float flSurvivorPos[3];
	int iSurvivorCount = 0;
	int[] iSurvivors = new int[MaxClients + 1];
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank))
		{
			bHuman = bIsValidClient(iSurvivor, MT_CHECK_FAKECLIENT);
			if ((noHumans && bHuman) || (noBots && !bHuman) || (noIncaps && bIsPlayerIncapacitated(iSurvivor)))
			{
				continue;
			}

			GetClientEyePosition(iSurvivor, flSurvivorPos);
			if (bIsVisibleToPosition(iSurvivor, pos, flSurvivorPos, range))
			{
				iSurvivors[iSurvivorCount] = iSurvivor;
				iSurvivorCount++;
			}
		}
	}

	return (iSurvivorCount > 0) ? iSurvivors[GetRandomInt(0, (iSurvivorCount - 1))] : 0;
}

stock int iGetPlayerCount()
{
	int iPlayerCount = 0;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
		{
			iPlayerCount++;
		}
	}

	return iPlayerCount;
}

stock int iGetPlayerHealth(int client, float decayRate)
{
	int iHealth = GetEntProp(client, Prop_Data, "m_iHealth");
	if (bIsInfected(client))
	{
		return iHealth;
	}
	else if (bIsSurvivor(client))
	{
		float flTempHealth = flGetTempHealth(client, decayRate);
		return RoundToFloor(iHealth + flTempHealth);
	}

	return 0;
}

stock int iGetPlayerWaterLevel(int client)
{
	return GetEntProp(client, Prop_Send, "m_nWaterLevel");
}

stock int iGetRandomColor(int color)
{
	return (color == -1 || color < 0 || color > 255) ? MT_GetRandomInt(0, 255) : color;
}

stock int iGetRandomPlayer(int flags = MT_CHECK_INGAME)
{
	int iPlayerCount = 0, iPlayers[MAXPLAYERS + 1];
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, flags))
		{
			iPlayers[iPlayerCount] = iPlayer;
			iPlayerCount++;
		}
	}

	return (iPlayerCount > 0) ? iPlayers[GetRandomInt(0, (iPlayerCount - 1))] : 0;
}

stock int iGetRandomSurvivor(int tank)
{
	int iSurvivorCount = 0, iSurvivors[MAXPLAYERS + 1];
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (MT_IsAdminImmune(iSurvivor, tank) || !bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			continue;
		}

		iSurvivors[iSurvivorCount] = iSurvivor;
		iSurvivorCount++;
	}

	return (iSurvivorCount > 0) ? iSurvivors[GetRandomInt(0, (iSurvivorCount - 1))] : 0;
}

stock int iGetRandomTank(int tank)
{
	int iTankCount = 0, iTanks[MAXPLAYERS + 1];
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE) && iTank != tank)
		{
			iTanks[iTankCount] = iTank;
			iTankCount++;
		}
	}

	return (iTankCount > 0) ? iTanks[GetRandomInt(0, (iTankCount - 1))] : 0;
}

stock int iGetRayHitPos(float pos[3], float angles[3], float hitpos[3], int entity, bool offset, int type)
{
	Handle hTrace = null;

	switch (type)
	{
		case 1: hTrace = TR_TraceRayFilterEx(pos, angles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, entity);
		case 2: hTrace = TR_TraceRayFilterEx(pos, angles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndPlayer, entity);
		case 3: hTrace = TR_TraceRayFilterEx(pos, angles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndSurvivor, entity);
		case 4: hTrace = TR_TraceRayFilterEx(pos, angles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndInfected, entity);
		case 5: hTrace = TR_TraceRayFilterEx(pos, angles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndCommons, entity);
	}

	int iHit = 0;
	if (hTrace != null)
	{
		if (TR_DidHit(hTrace))
		{
			TR_GetEndPosition(hitpos, hTrace);
			iHit = TR_GetEntityIndex(hTrace);
		}

		delete hTrace;
	}

	if (offset)
	{
		float flVector[3];
		MakeVectorFromPoints(hitpos, pos, flVector);
		NormalizeVector(flVector, flVector);
		ScaleVector(flVector, 15.0);
		AddVectors(hitpos, flVector, hitpos);
	}

	return iHit;
}

stock int iGetRGBColor(int red, int green, int blue)
{
	return red + (green * 256) + (blue * 65536);
}

stock int iGetSettingValue(bool apply, bool human, int playerVal, int typeVal, int overrideLevel = 0, int overrideVal = 0)
{
	if (apply)
	{
		switch (overrideLevel)
		{
			case 0: return (human && playerVal > overrideVal) ? playerVal : typeVal;
			case 1: return (human && playerVal >= overrideVal) ? playerVal : typeVal;
			case 2: return (human && playerVal != overrideVal) ? playerVal : typeVal;
		}
	}

	return (overrideLevel == 1) ? -1 : 0;
}

stock int iGetSubSettingValue(bool apply, bool human, int teamVal, int playerVal, int specVal, int typeVal, int overrideLevel = 0, int overrideVal = 0)
{
	if (apply)
	{
		int iPlayerVal = overrideVal, iTypeVal = overrideVal;

		switch (overrideLevel)
		{
			case 0:
			{
				iPlayerVal = (teamVal > overrideVal) ? teamVal : playerVal;
				iTypeVal = (specVal > overrideVal) ? specVal : typeVal;
				return (human && iPlayerVal > overrideVal) ? iPlayerVal : iTypeVal;
			}
			case 1:
			{
				iPlayerVal = (teamVal >= overrideVal) ? teamVal : playerVal;
				iTypeVal = (specVal >= overrideVal) ? specVal : typeVal;
				return (human && iPlayerVal >= overrideVal) ? iPlayerVal : iTypeVal;
			}
			case 2:
			{
				iPlayerVal = (teamVal != overrideVal) ? teamVal : playerVal;
				iTypeVal = (specVal != overrideVal) ? specVal : typeVal;
				return (human && iPlayerVal != overrideVal) ? iPlayerVal : iTypeVal;
			}
		}
	}

	return (overrideLevel == 1) ? -1 : 0;
}

stock int iGetSurvivorAttacker(int survivor)
{
	int iSpecial = GetEntPropEnt(survivor, Prop_Send, "m_pounceAttacker");
	iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_tongueOwner") : iSpecial;
	if (bIsSecondGame())
	{
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_pummelAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_carryAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_jockeyAttacker") : iSpecial;
	}

	return iSpecial;
}

stock int iGetSurvivorCount(bool human = false)
{
	bool bValidPlayer = false;
	int iCount = 0;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		bValidPlayer = human ? bIsHumanSurvivor(iSurvivor) : bIsSurvivor(iSurvivor);
		if (bValidPlayer)
		{
			iCount++;
		}
	}

	return iCount;
}

stock int iGetWeaponOffset(int weapon)
{
	char sWeapon[32];
	GetEntityClassname(weapon, sWeapon, sizeof sWeapon);
	if (StrEqual(sWeapon[7], "rifle") || StrEqual(sWeapon[7], "rifle_ak47") || StrEqual(sWeapon[7], "rifle_desert") || StrEqual(sWeapon[7], "rifle_sg552"))
	{
		return 3;
	}
	else if (StrEqual(sWeapon[7], "smg") || StrEqual(sWeapon[7], "smg_silenced") || StrEqual(sWeapon[7], "smg_mp5"))
	{
		return 5;
	}
	else if (StrEqual(sWeapon[7], "shotgun_chrome"))
	{
		return 7;
	}
	else if (StrEqual(sWeapon[7], "pumpshotgun"))
	{
		return bIsSecondGame() ? 7 : 6;
	}
	else if (StrEqual(sWeapon[7], "shotgun_spas"))
	{
		return 8;
	}
	else if (StrEqual(sWeapon[7], "autoshotgun"))
	{
		return bIsSecondGame() ? 8 : 6;
	}
	else if (StrEqual(sWeapon[7], "hunting_rifle"))
	{
		return bIsSecondGame() ? 9 : 2;
	}
	else if (StrEqual(sWeapon[7], "sniper_military") || StrEqual(sWeapon[7], "sniper_scout") || StrEqual(sWeapon[7], "sniper_awp"))
	{
		return 10;
	}
	else if (StrEqual(sWeapon[7], "grenade_launcher"))
	{
		return 17;
	}

	return 0;
}

stock int iGetWitchCount()
{
	int iWitchCount = 0, iWitch = -1;
	while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
	{
		iWitchCount++;
	}

	return iWitchCount;
}

// Limiters
stock float flClamp(float value, float min = 0.0, float max = 99999.0)
{
	if (value < min)
	{
		return min;
	}
	else if (value > max)
	{
		return max;
	}

	return value;
}

stock int iClamp(int value, int min = 0, int max = 99999)
{
	if (value < min)
	{
		return min;
	}
	else if (value > max)
	{
		return max;
	}

	return value;
}

// Particle functions
stock int iCreateParticle(int player, const char[] particlename, float pos[3], float angles[3], float pause, float duration, const char[] attachment = "")
{
	int iEffect = CreateEntityByName("info_particle_system");
	if (bIsValidEntity(iEffect))
	{
		DispatchKeyValue(iEffect, "effect_name", particlename);
		vSetEntityParent(iEffect, player);
		TeleportEntity(iEffect, pos, angles);
		DispatchSpawn(iEffect);
		ActivateEntity(iEffect);
		AcceptEntityInput(iEffect, "Start");
		vSetEdictFlags(iEffect, FL_EDICT_ALWAYS, true);

		if (attachment[0] != '\0')
		{
			SetVariantString(attachment);
			AcceptEntityInput(iEffect, "SetParentAttachment");
		}

		char sVariant[64];
		FormatEx(sVariant, sizeof sVariant, "OnUser1 !self:Stop::%f:-1", pause);
		SetVariantString(sVariant);
		AcceptEntityInput(iEffect, "AddOutput");

		FormatEx(sVariant, sizeof sVariant, "OnUser1 !self:FireUser2::%f:-1", (pause + 0.5));
		SetVariantString(sVariant);
		AcceptEntityInput(iEffect, "AddOutput");
		AcceptEntityInput(iEffect, "FireUser1");

		SetVariantString("OnUser2 !self:Start::0:-1");
		AcceptEntityInput(iEffect, "AddOutput");
		SetVariantString("OnUser2 !self:FireUser1::0:-1");
		AcceptEntityInput(iEffect, "AddOutput");

		FormatEx(sVariant, sizeof sVariant, "OnUser3 !self:Kill::%f:-1", duration);
		SetVariantString(sVariant);
		AcceptEntityInput(iEffect, "AddOutput");
		AcceptEntityInput(iEffect, "FireUser3");

		return iEffect;
	}

	return INVALID_ENT_REFERENCE;
}

stock int iPrecacheParticle(const char[] particlename)
{
	static int iTable = INVALID_STRING_TABLE;
	if (iTable == INVALID_STRING_TABLE)
	{
		iTable = FindStringTable("ParticleEffectNames");
	}

	int iIndex = FindStringIndex(iTable, particlename);
	if (iIndex == INVALID_STRING_INDEX)
	{
		bool bSave = LockStringTables(false);
		AddToStringTable(iTable, particlename);
		LockStringTables(bSave);
		iIndex = FindStringIndex(iTable, particlename);
	}

	return iIndex;
}