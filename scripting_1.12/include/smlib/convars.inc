#if defined _smlib_convars_included
	#endinput
#endif
#define _smlib_convars_included

#include <sourcemod>

/**
 * Checks if a ConVar has one or more flags set.
 *
 * @param	convar		ConVar Handle.
 * @param	flags		Flags to check.
 * @return				True if flags are set, false otherwise.
 */
stock bool Convar_HasFlags(ConVar convar, int flags)
{
	return convar.Flags & flags > 0;
}

/**
 * Adds one or more flags to a ConVar.
 *
 * @param	convar		ConVar Handle.
 * @param	flags		Flags to add.
 */
stock void Convar_AddFlags(ConVar convar, int flags)
{
	int newFlags = convar.Flags;
	newFlags |= flags;
	convar.Flags = newFlags;
}

/**
 * Removes one ore more flags from a ConVar.
 *
 * @param	convar		ConVar Handle.
 * @param	flags		Flags to remove
 * @noreturn
 */
stock void Convar_RemoveFlags(ConVar convar, int flags)
{
	int newFlags = convar.Flags;
	newFlags &= ~flags;
	convar.Flags = newFlags;
}

/**
 * Checks if a String is a valid ConVar or
 * Console Command name.
 *
 * @param	name		String Name.
 * @return				True if the name specified is a valid ConVar or console command name, false otherwise.
 */
stock bool Convar_IsValidName(const char[] name)
{
	if (name[0] == '\0') {
		return false;
	}

	int n=0;
	while (name[n] != '\0') {

		if (!IsValidConVarChar(name[n])) {
			return false;
		}

		n++;
	}

	return true;
}
