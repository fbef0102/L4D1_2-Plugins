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

#if defined _metastringmap_included
 #endinput
#endif
#define _metastringmap_included

#include <string>
#include <json/helpers/typedstringmap>

/**
 * A TypedStringMap which contains a nested `Data` `TypedStringMap` property.
 * Standard methods and properties have been overridden to run against `Data`,
 * but you can access the parent methods/properties using the `Meta` property.
 */
methodmap MetaStringMap < TypedStringMap
{
    /**
     * @section Properties
     */

    /**
     * Views the instance as its superclass to access overridden methods.
     */
    property TypedStringMap Meta
    {
        public get()
        {
            return view_as<TypedStringMap>(this);
        }
    }

    /**
     * Gets the nested stringmap where data is stored.
     */
    property TypedStringMap Data
    {
        public get()
        {
            return view_as<TypedStringMap>(this.Meta.GetHandle("data"));
        }

        public set(TypedStringMap value)
        {
            this.Meta.SetHandle("data", value);
        }
    }

    /** @see TypedStringMap.Length */
    property int Length {
        public get()
        {
            return this.Data.Length;
        }
    }

    /**
     * @section Getters
     */

    /** @see StringMap.GetValue */
    public bool GetValue(const char[] key, any &value)
    {
        return this.Data.GetValue(key, value);
    }

    /**
     * @see TypedStringMap.GetOptionalValue
     * @internal
     */
    public any GetOptionalValue(const char[] key, any default_value = -1)
    {
        return this.Data.GetOptionalValue(key, default_value);
    }

    /** @see StringMap.GetString */
	public bool GetString(
        const char[] key,
        char[] value,
        int max_size,
        int &size = 0
    ) {
        return this.Data.GetString(key, value, max_size, size);
    }

    /** @see TypedStringMap.GetInt */
    public int GetInt(const char[] key, int default_value = -1)
    {
        return this.Data.GetInt(key, default_value);
    }

    /** @see TypedStringMap.GetFloat */
    public float GetFloat(const char[] key, float default_value = -1.0)
    {
        return this.Data.GetFloat(key, default_value);
    }

    /** @see TypedStringMap.GetBool */
    public bool GetBool(const char[] key, bool default_value = false)
    {
        return this.Data.GetBool(key, default_value);
    }

    /** @see TypedStringMap.GetHandle */
    public Handle GetHandle(const char[] key, Handle default_value = null)
    {
        return this.Data.GetHandle(key, default_value);
    }

    /**
     * @section Setters
     */

    /** @see StringMap.SetValue */
    public bool SetValue(const char[] key, any value)
    {
        return this.Data.SetValue(key, value);
    }

    /** @see StringMap.SetString */
    public bool SetString(const char[] key, const char[] value)
    {
        return this.Data.SetString(key, value);
    }

    /** @see TypedStringMap.SetInt */
    public bool SetInt(const char[] key, int value)
    {
        return this.Data.SetInt(key, value);
    }

    /** @see TypedStringMap.SetFloat */
    public bool SetFloat(const char[] key, float value)
    {
        return this.Data.SetFloat(key, value);
    }

    /** @see TypedStringMap.SetBool */
    public bool SetBool(const char[] key, bool value)
    {
        return this.Data.SetBool(key, value);
    }

    /** @see TypedStringMap.SetHandle */
    public bool SetHandle(const char[] key, Handle value)
    {
        return this.Data.SetHandle(key, value);
    }

    /** @see StringMap.Remove */
    public bool Remove(const char[] key)
    {
        return this.Data.Remove(key);
    }

    /**
     * @section Misc
     */

    /** @see TypedStringMap.HasKey */
    public bool HasKey(const char[] key)
    {
        return this.Data.HasKey(key);
    }

    /** @see StringMap.Clear */
    public void Clear()
    {
        TypedStringMap data = this.Data;
        data.Clear();
        this.Meta.Clear();
        this.Data = data;
    }

    /**
     * Deletes the instance's data StringMap as well as the instance itself.
     */
    public void Cleanup()
    {
        delete this.Data;
        delete this;
    }

    /** @see StringMap.Snapshot */
    public StringMapSnapshot Snapshot()
    {
        return this.Data.Snapshot();
    }

    /**
     * @section Constructor
     */

    /**
     * Creates a new MetaStringMap.
     *
     * @return      A new MetaStringMap.
     */
    public MetaStringMap()
    {
        MetaStringMap self = view_as<MetaStringMap>(new TypedStringMap());
        self.Data = new TypedStringMap();

        return self;
    }
};
