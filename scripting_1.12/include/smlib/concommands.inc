#if defined _smlib_concommands_included
	#endinput
#endif
#define _smlib_concommands_included

#include <sourcemod>
#include <smlib/clients>

/**
 * Checks if a ConCommand has one or more flags set.
 *
 * @param    command        ConCommand name.
 * @param    flags        Flags to check.
 * @return                True if flags are set, false otherwise.
 */
stock bool ConCommand_HasFlags(const char[] command, int flags)
{
    return GetCommandFlags(command) & flags > 0;
}

/**
 * Adds one or more flags to a ConCommand.
 *
 * @param    command        ConCommand name.
 * @param    flags        Flags to add.
 */
stock void ConCommand_AddFlags(const char[] command, int flags)
{
    int newFlags = GetCommandFlags(command);
    newFlags |= flags;
    SetCommandFlags(command, newFlags);
}

/**
 * Removes one ore more flags from a ConCommand.
 *
 * @param    command        ConCommand name.
 * @param    flags        Flags to remove
 */
stock void ConCommand_RemoveFlags(const char[] command, int flags)
{
    int newFlags = GetCommandFlags(command);
    newFlags &= ~flags;
    SetCommandFlags(command, newFlags);
}
