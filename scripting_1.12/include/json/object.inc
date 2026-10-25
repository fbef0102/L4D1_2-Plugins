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

#if defined _json_object_included
 #endinput
#endif
#define _json_object_included

#include <string>
#include <json/definitions>
#include <json/helpers/errors>
#include <json/helpers/metastringmap>

methodmap JSON_Object < MetaStringMap
{
    /**
     * @section Properties
     */

    /**
     * Views the instance as its superclass to access overridden methods.
     */
    property MetaStringMap Super
    {
        public get()
        {
            return view_as<MetaStringMap>(this);
        }
    }

    /**
     * Whether the current object is an array.
     */
    property bool IsArray {
        public get()
        {
            return this.Meta.GetBool(JSON_ARRAY_KEY);
        }
    }

    /**
     * @section Iteration Helpers
     */

    /**
     * @section Metadata Getters
     */

    /**
     * Gets the requested meta info for a key.
     * @internal
     *
     * @param key               Key to get meta info for.
     * @param meta              Meta info to get.
     * @param default_value     Value to return if meta does not exist.
     * @return                  The meta value.
     */
    public any GetMeta(
        const char[] key,
        JSONMetaInfo meta,
        any default_value
    ) {
        int max_size = json_meta_key_length(key);
        char[] meta_key = new char[max_size];
        json_format_meta_key(meta_key, max_size, key, meta);

        return this.Meta.GetOptionalValue(meta_key, default_value);
    }

    /**
     * Gets the cell type stored at a key.
     *
     * @param key   Key to get value type for.
     * @return      Value type for key provided,
     *              or JSON_Type_Invalid if it does not exist.
     */
    public JSONCellType GetType(const char[] key)
    {
        return view_as<JSONCellType>(
            this.GetMeta(key, JSON_Meta_Type, JSON_Type_Invalid)
        );
    }

    /**
     * Gets the size of the string stored at a key.
     *
     * @param key   Key to get buffer size for.
     * @return      Buffer size for string at key provided,
     *              or -1 if it is not a string/does not exist.
     */
    public int GetSize(const char[] key)
    {
        return view_as<int>(this.GetMeta(key, JSON_Meta_Size, -1));
    }

    /**
     * Gets whether the key should be hidden from encoding.
     *
     * @param key   Key to get hidden state for.
     * @return      Whether or not the key should be hidden.
     */
    public bool GetHidden(const char[] key)
    {
        return view_as<bool>(this.GetMeta(key, JSON_Meta_Hidden, false));
    }

    /**
     * Gets the index of a key.
     *
     * @param key   Key to get index of.
     * @return      Index of the key provided, or -1 if it does not exist.
     */
    public int GetIndex(const char[] key)
    {
        return view_as<int>(this.GetMeta(key, JSON_Meta_Index, -1));
    }

    /**
     * Gets the key stored at an index.
     * If an array, will convert the index to its string value.
     * If an array, will return false if the index is not between [0, length].
     *
     * @param index     Index of key.
     * @param value     Buffer to store key at.
     * @param max_size  Maximum size of value buffer.
     * @return          True on success, false otherwise.
     */
    public bool GetKey(int index, char[] value, int max_size)
    {
        char[] index_key = new char[JSON_INT_BUFFER_SIZE];
        if (IntToString(index, index_key, JSON_INT_BUFFER_SIZE) == 0) {
            return false;
        }

        if (this.IsArray) {
            // allow access of one past last index for intermediary operations
            if (index < 0 || index > this.Length) {
                return false;
            }

            strcopy(value, max_size, index_key);

            return true;
        }

        return this.Meta.GetString(index_key, value, max_size);
    }

    /**
     * Returns the buffer size required to store the key at the specified index.
     *
     * @param index     Index of key.
     * @return          Buffer size required to store key.
     */
    public int GetKeySize(int index)
    {
        if (this.IsArray) {
            return JSON_INT_BUFFER_SIZE;
        }

        int max_size = JSON_INT_BUFFER_SIZE + 4;
        char[] index_size_key = new char[max_size];
        FormatEx(index_size_key, max_size, "%d:len", index);

        return this.Meta.GetInt(index_size_key);
    }

    /**
     * @section Metadata Setters
     */

    /**
     * Sets meta info on a key.
     * @internal
     *
     * @param key       Key to set meta info for.
     * @param meta      Meta info to set.
     * @param value     Value to set.
     * @return          True on success, false otherwise.
     */
    public bool SetMeta(const char[] key, JSONMetaInfo meta, any value)
    {
        int max_size = json_meta_key_length(key);
        char[] meta_key = new char[max_size];
        json_format_meta_key(meta_key, max_size, key, meta);

        return this.Meta.SetValue(meta_key, value);
    }

    /**
     * Removes meta info from a key.
     * @internal
     *
     * @param key   Key to remove meta info from.
     * @param meta  Meta info to remove.
     * @return          True on success, false otherwise.
     */
    public bool RemoveMeta(const char[] key, JSONMetaInfo meta)
    {
        int max_size = json_meta_key_length(key);
        char[] meta_key = new char[max_size];
        json_format_meta_key(meta_key, max_size, key, meta);

        return this.Meta.Remove(meta_key);
    }

    /**
     * Sets whether the key should be hidden from encoding.
     *
     * @param key       Key to set hidden state for.
     * @param hidden    Whether or not the key should be hidden.
     * @return          True on success, false otherwise.
     */
    public bool SetHidden(const char[] key, bool hidden)
    {
        return hidden
            ? this.SetMeta(key, JSON_Meta_Hidden, hidden)
            : this.RemoveMeta(key, JSON_Meta_Hidden);
    }

    /**
     * Tracks a key, setting it's type and index where necessary.
     * @internal
     *
     * @param key       Key to track. If the key already
     *                  exists, it's index will not be changed.
     * @param type      Type to set key to. If a valid type is
     *                  provided, the key's type will be updated.
     * @param index     Index to set key to. If the index is not
     *                  provided (-1), the object length will be used.
     * @return          True on success, false otherwise.
     */
    public bool TrackKey(
        const char[] key,
        JSONCellType type = JSON_Type_Invalid,
        int index = -1
    ) {
        // track type if provided
        if (type != JSON_Type_Invalid) {
            this.SetMeta(key, JSON_Meta_Type, type);
        }

        if (this.IsArray) {
            return true;
        }

        if (index == -1) {
            index = this.Length;

            // skip tracking index if we're pushing to end & key already exists
            if (this.HasKey(key)) {
                if (type != JSON_Type_Invalid && type != JSON_Type_String) {
                    // remove any existing size
                    this.RemoveMeta(key, JSON_Meta_Size);
                }

                return true;
            }
        }

        char[] index_key = new char[JSON_INT_BUFFER_SIZE];
        IntToString(index, index_key, JSON_INT_BUFFER_SIZE);

        int max_size = JSON_INT_BUFFER_SIZE + 8;
        char[] index_size_key = new char[max_size];
        FormatEx(index_size_key, max_size, "%d:len", index);

        return this.Meta.SetString(index_key, key)
            && this.Meta.SetInt(index_size_key, strlen(key) + 1)
            && this.SetMeta(key, JSON_Meta_Index, index);
    }

    /**
     * Untracks a key, cleaning up all it's meta and indexing data.
     * @internal
     *
     * @param key   Key to untrack.
     * @return      True on success, false otherwise.
     */
    public bool UntrackKey(const char[] key)
    {
        int index = this.GetIndex(key);

        for (int i = 0; i < sizeof(JSON_ALL_METADATA); i += 1) {
            this.RemoveMeta(key, JSON_ALL_METADATA[i]);
        }

        if (this.IsArray) {
            return true;
        }

        if (index == -1) {
            return false;
        }

        char[] index_key = new char[JSON_INT_BUFFER_SIZE];
        IntToString(index, index_key, JSON_INT_BUFFER_SIZE);

        int max_size = JSON_INT_BUFFER_SIZE + 8;
        char[] index_size_key = new char[max_size];
        FormatEx(index_size_key, max_size, "%d:len", index);

        if (! this.Meta.Remove(index_key) || ! this.Meta.Remove(index_size_key)) {
            return false;
        }

        int length = this.Length;
        int last_index = length - 1;
        if (index < last_index) {
            for (int i = index + 1; i < length; i += 1) {
                int new_key_size = this.GetKeySize(i);
                char[] new_key = new char[new_key_size];
                this.GetKey(i, new_key, new_key_size);

                this.TrackKey(new_key, JSON_Type_Invalid, i - 1);
            }

            IntToString(last_index, index_key, JSON_INT_BUFFER_SIZE);
            FormatEx(index_size_key, max_size, "%d:len", last_index);

            this.Meta.Remove(index_key);
            this.Meta.Remove(index_size_key);
        }

        return true;
    }

    /**
     * @section Getters
     */

    #if SM_INT64_SUPPORTED
    /**
     * Retrieves the int64 stored at a key.
     *
     * @param key   Key to retrieve int64 value for.
     * @param value Int buffer to store output.
     * @return      True on success, false otherwise.
     */
    public bool GetInt64(const char[] key, int value[2])
    {
        return this.Data.GetArray(key, value, 2);
    }
    #endif

    /**
     * Retrieves the JSON object stored at a key.
     *
     * @param key               Key to retrieve object value for.
     * @param default_value     Value to return if the key does not exist.
     * @return                  Value stored at key.
     */
    public JSON_Object GetObject(
        const char[] key,
        JSON_Object default_value = null
    ) {
        return view_as<JSON_Object>(this.GetHandle(key, default_value));
    }

    /**
     * @section Setters
     */

    /**
     * Sets the string stored at a key.
     *
     * @param key       Key to set to string value.
     * @param value     Value to set.
     * @return          True on success, false otherwise.
     */
    public bool SetString(const char[] key, const char[] value)
    {
        return this.TrackKey(key, JSON_Type_String)
            && this.Super.SetString(key, value)
            && this.SetMeta(key, JSON_Meta_Size, strlen(value) + 1);
    }

    /**
     * Sets the int stored at a key.
     *
     * @param key       Key to set to int value.
     * @param value     Value to set.
     * @return          True on success, false otherwise.
     */
    public bool SetInt(const char[] key, int value)
    {
        return this.TrackKey(key, JSON_Type_Int)
            && this.Super.SetInt(key, value);
    }

    #if SM_INT64_SUPPORTED
    /**
     * Sets the int64 stored at a key.
     *
     * @param key       Key to set to int64 value.
     * @param value     Value to set.
     * @return          True on success, false otherwise.
     */
    public bool SetInt64(const char[] key, int value[2])
    {
        return this.TrackKey(key, JSON_Type_Int64)
            && this.Data.SetArray(key, value, 2);
    }
    #endif

    /**
     * Sets the float stored at a key.
     *
     * @param key       Key to set to float value.
     * @param value     Value to set.
     * @return          True on success, false otherwise.
     */
    public bool SetFloat(const char[] key, float value)
    {
        return this.TrackKey(key, JSON_Type_Float)
            && this.Super.SetFloat(key, value);
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
        return this.TrackKey(key, JSON_Type_Bool)
            && this.Super.SetBool(key, value);
    }

    /**
     * Sets the JSON object stored at a key.
     *
     * @param key       Key to set to object value.
     * @param value     Value to set.
     * @return          True on success, false otherwise.
     */
    public bool SetObject(const char[] key, JSON_Object value)
    {
        return this.TrackKey(key, JSON_Type_Object)
            && this.Super.SetHandle(key, value);
    }

    /**
     * @section Misc
     */

    /**
     * Removes an item from the object by key.
     *
     * @param key       Key of object to remove.
     * @return          True on success, false if the value was never set.
     */
    public bool Remove(const char[] key)
    {
        return this.UntrackKey(key) && this.Super.Remove(key);
    }

    /**
     * Renames the key of an existing item in the object.
     *
     * @param from      Existing key to rename.
     * @param to        New key.
     * @param replace   Should the 'to' key should be replaced if it exists?
     * @return          True on success, false otherwise.
     */
    public bool Rename(
        const char[] from,
        const char[] to,
        bool replace = true
    ) {
        JSONCellType type = this.GetType(from);
        if (type == JSON_Type_Invalid) {
            return false;
        }

        if (StrEqual(from, to, true)) {
            return true;
        }

        bool toExists = this.HasKey(to);
        if (toExists) {
            if (! replace) {
                return false;
            }

            this.Remove(to);
        }

        switch (type) {
            case JSON_Type_String: {
                int length = this.GetSize(from);
                char[] value = new char[length];
                this.GetString(from, value, length);
                this.SetString(to, value);
            }
            case JSON_Type_Int: {
                this.SetInt(to, this.GetInt(from));
            }
            #if SM_INT64_SUPPORTED
            case JSON_Type_Int64: {
                int value[2];
                this.GetInt64(from, value);
                this.SetInt64(to, value);
            }
            #endif
            case JSON_Type_Float: {
                this.SetFloat(to, this.GetFloat(from));
            }
            case JSON_Type_Bool: {
                this.SetBool(to, this.GetBool(from));
            }
            case JSON_Type_Object: {
                this.SetObject(to, this.GetObject(from));
            }
        }

        this.SetHidden(to, this.GetHidden(from));

        this.Remove(from);

        return true;
    }

    /**
     * Merges in the entries from the specified object,
     * optionally replacing existing entries with the same key.
     *
     * @param from      Object to merge entries from.
     * @param options   Bitwise combination of `JSON_MERGE_*` options.
     * @return          True on success, false otherwise.
     * @error           If the object being merged is an array,
     *                  an error will be thrown.
     */
    public bool Merge(JSON_Object from, int options = JSON_MERGE_REPLACE)
    {
        if (this.IsArray || from.IsArray) {
            json_set_last_error("attempted to merge using an array");

            return false;
        }

        bool replace = (options & JSON_MERGE_REPLACE) > 0;
        bool autocleanup = (options & JSON_MERGE_CLEANUP) > 0;

        int json_size = from.Length;
        int key_length = 0;
        for (int i = 0; i < json_size; i += 1) {
            key_length = from.GetKeySize(i);
            char[] key = new char[key_length];
            from.GetKey(i, key, key_length);

            // skip already existing keys if we aren't in replace mode
            bool key_already_exists = this.HasKey(key);
            if (! replace && key_already_exists) {
                continue;
            }

            JSONCellType type = from.GetType(key);
            // skip keys of unknown type
            if (type == JSON_Type_Invalid) {
                continue;
            }

            // merge value onto structure
            switch (type) {
                case JSON_Type_String: {
                    int length = from.GetSize(key);
                    char[] value = new char[length];
                    from.GetString(key, value, length);

                    this.SetString(key, value);
                }
                case JSON_Type_Int: {
                    this.SetInt(key, from.GetInt(key));
                }
                #if SM_INT64_SUPPORTED
                case JSON_Type_Int64: {
                    int value[2];
                    from.GetInt64(key, value);
                    this.SetInt64(key, value);
                }
                #endif
                case JSON_Type_Float: {
                    this.SetFloat(key, from.GetFloat(key));
                }
                case JSON_Type_Bool: {
                    this.SetBool(key, from.GetBool(key));
                }
                case JSON_Type_Object: {
                    JSON_Object value = from.GetObject(key);

                    if (autocleanup && key_already_exists) {
                        JSON_Object existing = this.GetObject(key);
                        if (existing != value) {
                            json_cleanup_and_delete(existing);
                        }
                    }

                    this.SetObject(key, value);
                }
            }

            this.SetHidden(key, from.GetHidden(key));
        }

        return true;
    }

    /**
     * @section json.inc Aliases
     */

    /**
     * Makes a global call with this
     * instance passed as the object.
     *
     * @see json_encode_size
     */
    public int EncodeSize(int options = JSON_NONE)
    {
        return json_encode_size(this, options);
    }

    /**
     * Makes a global call with this
     * instance passed as the object.
     *
     * @see json_encode
     */
    public void Encode(char[] output, int max_size, int options = JSON_NONE)
    {
        json_encode(this, output, max_size, options);
    }

    /**
     * Makes a global call with this
     * instance passed as the object.
     *
     * @see json_write_to_file
     */
    public bool WriteToFile(const char[] path, int options = JSON_NONE)
    {
        return json_write_to_file(this, path, options);
    }

    /**
     * Makes a global call with this
     * instance passed as the object.
     *
     * @see json_copy_deep
     */
    public JSON_Object ShallowCopy()
    {
        return json_copy_shallow(this);
    }

    /**
     * Makes a global call with this
     * instance passed as the object.
     *
     * @see json_copy_deep
     */
    public JSON_Object DeepCopy()
    {
        return json_copy_deep(this);
    }

    /**
     * Makes a global call with this
     * instance passed as the object.
     *
     * @see json_cleanup
     */
    public void Cleanup()
    {
        json_cleanup(this);
    }

    /**
     * @section Constructor
     */

    /**
     * Creates a new JSON_Object.
     *
     * @return      A new JSON_Object.
     */
    public JSON_Object()
    {
        return view_as<JSON_Object>(new MetaStringMap());
    }
};
