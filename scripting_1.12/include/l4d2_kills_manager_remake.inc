/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#if defined  _l4d2_kills_manager_remake_included_
 #endinput
#endif
#define _l4d2_kills_manager_remake_included_

/**
 * @brief Called before event "player_death" is modified and changed
 * @remarks This happens before l4d2_kills_manager_remake.smx tries to modify "player_death" event (EventHookMode_Pre)
 * @remarks You can get the original attacker, weapon, victim,....etc here
 *
 * @param userid			user ID who died
 * @param entityid			entity ID who died, userid should be used first, to get the dead Player. Otherwise, it is not a player, so use this.
 * @param attacker			user ID who killed
 * @param attackername		What type of zombie, so we don't have zombie names
 * @param attackerentid		if killer not a player, the entindex of who killed. Again, use attacker first
 * @param weapon			weapon name killer used
 * @param headshot			signals a headshot
 * @param attackerisbot		is the attacker a bot
 * @param victimname		What type of zombie, so we don't have zombie names
 * @param victimisbot		is the victim a bot
 * @param abort				did the victim abort (I don't know what it is)
 * @param type				damage type
 * @param victim_x			victim x (I don't know what it is)
 * @param victim_y			victim y (I don't know what it is)
 * @param victim_z			victim z (I don't know what it is)
 *
 * @noreturn
 */
forward void l4d2_kills_manager_remake_PlayerDeath_Pre(int userid, int entityid, int attacker, const char[] attackername, int attackerentid, const char[] weapon, bool headshot, bool attackerisbot, const char[] victimname, bool victimisbot, bool abort, int type, float victim_x, float victim_y, float victim_z);

public SharedPlugin __pl_l4d2_kills_manager_remake =
{
	name = "l4d2_kills_manager_remake",
	file = "l4d2_kills_manager_remake.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_kills_manager_remake_SetNTVOptional()
{
}
#endif