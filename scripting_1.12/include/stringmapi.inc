/**
 * vim: set ts=4 sw=4 tw=99 noet :
 * =============================================================================
 * (C)2026 Dragokas & SourceMod & AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This file partially includes the source code of the SourceMod/SourcePawn SDK.
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

#if defined _stringmapi_included
 #endinput
#endif
#define _stringmapi_included

#define STRINGMAPI_NORMALIZE_KEY(%0)		\
	int len = strlen(%0);					\
    char[] _normKey = new char[len];		\
    for (int i = 0; i < len; i++)			\
        _normKey[i] = CharToLower(%0[i]);

methodmap StringMapI < StringMap
{
	// Case insensitive wrapper over StringMap.
	// Only "string sensitive" functions are redefined.
	// All other StringMap-specific functions are available through the inheritance.
	// See: https://sm.alliedmods.net/new-api/adt_trie/StringMap
	//
	// Creates a hash map. A hash map is a container that can map strings (called
	// "keys") to arbitrary values (cells, arrays, or strings). Keys in a hash map
	// are unique. That is, there is at most one entry in the map for a given key.
	// Keys are case insensitive.
	//
	// Insertion, deletion, and lookup in a hash map are all considered to be fast
	// operations, amortized to O(1), or constant time.
	//
	// The StringMapI must be freed via delete or CloseHandle().
	public StringMapI()
	{
		return view_as<StringMapI>(new StringMap());
	}

	// Sets a value in a hash map, either inserting a new entry or replacing an old one.
	//
	// @param key        Key string.
	// @param value      Value to store at this key.
	// @param replace    If false, operation will fail if the key is already set.
	// @return           True on success, false on failure.
	public bool SetValue(const char[] key, any value, bool replace = true)
	{
		STRINGMAPI_NORMALIZE_KEY(key)
		return view_as<StringMap>(this).SetValue(_normKey, value, replace);
	}
	
	// Sets an array value in a Map, either inserting a new entry or replacing an old one.
	//
	// @param key        Key string.
	// @param array      Array to store.
	// @param num_items  Number of items in the array.
	// @param replace    If false, operation will fail if the key is already set.
	// @return           True on success, false on failure.
	public bool SetArray(const char[] key, const any[] array, int num_items, bool replace = true)
	{
		STRINGMAPI_NORMALIZE_KEY(key)
		return view_as<StringMap>(this).SetArray(_normKey, array, num_items, replace);
	}

	// Sets a string value in a Map, either inserting a new entry or replacing an old one.
	//
	// @param key        Key string.
	// @param value      String to store.
	// @param replace    If false, operation will fail if the key is already set.
	// @return           True on success, false on failure.
	public bool SetString(const char[] key, const char[] value, bool replace = true)
	{
		STRINGMAPI_NORMALIZE_KEY(key)
		return view_as<StringMap>(this).SetString(_normKey, value, replace);
	}

	// Retrieves a value in a Map.
	//
	// @param key        Key string.
	// @param value      Variable to store value.
	// @return           True on success.  False if the key is not set, or the key is set 
	//                   as an array or string (not a value).
	public bool GetValue(const char[] key, any &value)
	{
		STRINGMAPI_NORMALIZE_KEY(key)
		return view_as<StringMap>(this).GetValue(_normKey, value);
	}

	// Retrieves an array in a Map.
	//
	// @param key        Key string.
	// @param array      Buffer to store array.
	// @param max_size   Maximum size of array buffer.
	// @param size       Optional parameter to store the number of elements written to the buffer.
	// @return           True on success.  False if the key is not set, or the key is set 
	//                   as a value or string (not an array).
	public int GetArray(const char[] key, any[] array, int max_size, int &size=0)
	{
		STRINGMAPI_NORMALIZE_KEY(key)
		return view_as<StringMap>(this).GetArray(_normKey, array, max_size, size);
	}

	// Retrieves a string in a Map.
	//
	// @param key        Key string.
	// @param value      Buffer to store value.
	// @param max_size   Maximum size of string buffer.
	// @param size       Optional parameter to store the number of bytes written to the buffer.
	// @return           True on success.  False if the key is not set, or the key is set 
	//                   as a value or array (not a string).
	public bool GetString(const char[] key, char[] value, int max_size, int &size=0)
	{
		STRINGMAPI_NORMALIZE_KEY(key)
		return view_as<StringMap>(this).GetString(_normKey, value, max_size, size);
	}

	// Checks whether a key is present in a Map.
	//
	// @param key        Key string.
	// @return           True if the key has been found, else false.
	public bool ContainsKey(const char[] key)
	{
		STRINGMAPI_NORMALIZE_KEY(key)
		return view_as<StringMap>(this).ContainsKey(_normKey);
	}

	// Removes a key entry from a Map.
	//
	// @param key        Key string.
	// @return           True on success, false if the value was never set.
	public bool Remove(const char[] key)
	{
		STRINGMAPI_NORMALIZE_KEY(key)
		return view_as<StringMap>(this).Remove(_normKey);
	}
};
