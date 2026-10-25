/**
 * vim: set ts=4 :
 * =============================================================================
 * sm-json
 * A pure SourcePawn JSON encoder/decoder.
 * https://github.com/clugg/sm-json
 *
 * sm-json (C)2022 James Dickens. (clug)
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */

#if defined _json_helpers_errors_included
 #endinput
#endif
#define _json_helpers_errors_included

static char g_jsonLastError[1024] = "";

/**
 * Stores the error provided as the 'last error' for later access.
 * @internal
 *
 * @param error     Error to store.
 * @param ...       Further arguments to pass to message formatter.
 */
stock void json_set_last_error(const char[] error, any ...)
{
    VFormat(g_jsonLastError, sizeof(g_jsonLastError), error, 2);
}

/**
 * Retrieves the last error encountered and stores it in the buffer provided.
 *
 * @param buffer       String buffer.
 * @param max_size     Maximum size of string buffer.
 * @return             True if the error was copied successfuly,
 *                     false otherwise.
 */
stock bool json_get_last_error(char[] buffer, int max_size)
{
    return strcopy(buffer, max_size, g_jsonLastError) > 0;
}
