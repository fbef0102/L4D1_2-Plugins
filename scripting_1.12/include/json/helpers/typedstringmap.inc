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

#if defined _typedstringmap_included
 #endinput
#endif
#define _typedstringmap_included

#include <string>

/** @see StringMap.ContainsKey */
#define TRIE_SUPPORTS_CONTAINSKEY SOURCEMOD_V_MAJOR >= 1 \
    && SOURCEMOD_V_MINOR >= 11 \
    && SOURCEMOD_V_REV >= 6646

/**
 * A StringMap with typed getters and setters.
 */
methodmap TypedStringMap < StringMap
{
    /**
     * @section Properies
     */

    /** @see StringMap.Size */
    property int Length {
        public get()
        {
            return this.Size;
        }
    }

    /**
     * @section Misc
     */

    /** @see StringMap.ContainsKey */
    public bool HasKey(const char[] key)
    {
        #if TRIE_SUPPORTS_CONTAINSKEY
        return this.ContainsKey(key);
        #else
        int dummy_int;
        char dummy_str[1];

        return this.GetValue(key, dummy_int)
            || this.GetString(key, dummy_str, sizeof(dummy_str));
        #endif
    }

    /**
     * @section Getters
     */

    // GetValue is implemented natively by StringMap

    /**
     * Retrieves the value stored at a key.
     * @internal
     *
     * @param key               Key to retrieve value for.
     * @param default_value     Value to return if the key does not exist.
     * @return                  Value stored at key.
     */
    public any GetOptionalValue(const char[] key, any default_value = -1)
    {
        any value;
        return this.GetValue(key, value) ? value : default_value;
    }

    // GetString is implemented natively by StringMap

    /**
     * Retrieves the int stored at a key.
     *
     * @param key               Key to retrieve int value for.
     * @param default_value     Value to return if the key does not exist.
     * @return                  Value stored at key.
     */
    public int GetInt(const char[] key, int default_value = -1)
    {
        return view_as<int>(this.GetOptionalValue(key, default_value));
    }

    /**
     * Retrieves the float stored at a key.
     *
     * @param key               Key to retrieve float value for.
     * @param default_value     Value to return if the key does not exist.
     * @return                  Value stored at key.
     */
    public float GetFloat(const char[] key, float default_value = -1.0)
    {
        return view_as<float>(this.GetOptionalValue(key, default_value));
    }

    /**
     * Retrieves the bool stored at a key.
     *
     * @param key               Key to retrieve bool value for.
     * @param default_value     Value to return if the key does not exist.
     * @return                  Value stored at key.
     */
    public bool GetBool(const char[] key, bool default_value = false)
    {
        return view_as<bool>(this.GetOptionalValue(key, default_value));
    }

    /**
     * Retrieves the handle stored at a key.
     *
     * @param key               Key to retrieve handle value for.
     * @param default_value     Value to return if the key does not exist.
     * @return                  Value stored at key.
     */
    public Handle GetHandle(
        const char[] key,
        Handle default_value = null
    ) {
        return view_as<Handle>(this.GetOptionalValue(key, default_value));
    }

    /**
     * @section Setters
     */

    // SetValue is implemented natively by StringMap

    // SetString is implemented natively by StringMap

    /**
     * Sets the int stored at a key.
     *
     * @param key       Key to set to int value.
     * @param value     Value to set.
     * @return          True on success, false otherwise.
     */
    public bool SetInt(const char[] key, int value)
    {
        return this.SetValue(key, value);
    }

    /**
     * Sets the float stored at a key.
     *
     * @param key       Key to set to float value.
     * @param value     Value to set.
     * @return          True on success, false otherwise.
     */
    public bool SetFloat(const char[] key, float value)
    {
        return this.SetValue(key, value);
    }

    /**
     * Sets the bool stored at a key.
     *
     * @param key       Key to set to bool value.
     * @param value     Value to set.
     * @return          True on success, false otherwise.
     */
    public bool SetBool(const char[] key, bool value)
    {
        return this.SetValue(key, value);
    }

    /**
     * Sets the handle stored at a key.
     *
     * @param key       Key to set to object value.
     * @param value     Value to set.
     * @return          True on success, false otherwise.
     */
    public bool SetHandle(const char[] key, Handle value)
    {
        return this.SetValue(key, value);
    }

    /**
     * @section Constructor
     */

    /**
     * Creates a new TypedStringMap.
     *
     * @return      A new TypedStringMap.
     */
    public TypedStringMap()
    {
        return view_as<TypedStringMap>(CreateTrie());
    }
};
