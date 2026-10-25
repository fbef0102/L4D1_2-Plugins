#if defined _smlib_menus_included
	#endinput
#endif
#define _smlib_menus_included

#include <sourcemod>
#include <smlib/math>

/**
 * Adds an option to a menu with a String display but an integer
 * identifying the option.
 *
 * @param   menu        Handle to the menu
 * @param   value       Integer value for the option
 * @param   display     Display text for the menu
 */
stock void Menu_AddIntItem(Menu menu, any value, char[] display)
{
	char buffer[INT_MAX_DIGITS + 1];
	IntToString(value, buffer, sizeof(buffer));
	menu.AddItem(buffer, display);
}

/**
 * Retrieves an integer-value choice from a menu, where the
 * menu's information strings were created as integers.
 *
 * @param   menu         Handle to the menu
 * @param   param2       The item position selected from the menu.
 * @return               Integer choice from the menu, or 0 if the integer could not be parsed.
 */
stock any Menu_GetIntItem(Menu menu, any param2)
{
	char buffer[INT_MAX_DIGITS + 1];
	menu.GetItem(param2, buffer, sizeof(buffer));
	return StringToInt(buffer);
}
