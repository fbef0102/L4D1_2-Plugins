/*
*	VScript File Replacer
*	Copyright (C) 2022 Silvers
*
*	This program is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#if defined _vscript_replacer_included
 #endinput
#endif
#define _vscript_replacer_included



public SharedPlugin __pl_vscript_replacer = 
{
	name = "vscript_replacer",
	file = "vscript_replacer.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};



/**
 * Triggered when a VScript is being executed, allowing you to block or change filename.
 * All script names will use lowercase letters.
 *
 * @param sScript      VScript filename being executed. Does not include the .nuc or .nut extension.
 * @param sOverride    VScript being used to override the original script when override is true.
 * @param bOverride    True when the sScript is being overwritten by the sOverride value.
 *
 * @return             Plugin_Handled to block the script from being executed.
 *                     Plugin_Changed to change the script and use your provided sOverride value.
 *                     Plugin_Continue to continue without changes.
 */
forward Action OnVScriptExecuted(const char[] sScript, char sOverride[PLATFORM_MAX_PATH], bool bOverride);