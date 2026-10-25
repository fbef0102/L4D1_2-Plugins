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

#if defined _json_array_included
 #endinput
#endif
#define _json_array_included

#include <string>
#include <json/definitions>
#include <json/helpers/errors>
#include <json/object>

methodmap JSON_Array < JSON_Object
{
    /**
     * @section Helpers
     */

    /**
     * Views the instance as its superclass to access overridden methods.
     */
    property JSON_Object Super
    {
        public get()
        {
            return view_as<JSON_Object>(this);
        }
    }

    /**
     * The enforced type of the array.
     */
    property JSONCellType Type
    {
        public get()
        {
            return view_as<JSONCellType>(this.Meta.GetOptionalValue(
                JSON_ENFORCE_TYPE_KEY,
                JSON_Type_Invalid
            ));
        }

        public set(JSONCellType value)
        {
            if (value == JSON_Type_Invalid) {
                this.Meta.Remove(JSON_ENFORCE_TYPE_KEY);
            } else {
                this.Meta.SetValue(JSON_ENFORCE_TYPE_KEY, value);
            }
        }
    }

    /**
     * Checks whether the array accepts the type provided.
     *
     * @param type  Type to check for enforcement.
     * @return      True if the type can be used, false otherwise.
     */
    public bool CanUseType(JSONCellType type)
    {
        return this.Type == JSON_Type_Invalid || this.Type == type;
    }

    /**
     * Checks whether the object has an index.
     *
     * @param index     Index to check existence of.
     * @return          True if the index exists, false otherwise.
     */
    public bool HasKey(int index)
    {
        return index >= 0 && index < this.Length;
    }

    /**
     * @section Metadata Getters
     */

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     * @internal
     *
     * @see MetaStringMap.GetMeta
     */
    public any GetMeta(int index, JSONMetaInfo meta, any default_value)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return default_value;
        }

        return this.Super.GetMeta(key, meta, default_value);
    }

    /**
     * Gets the cell type stored at an index.
     *
     * @param index     Index to get value type for.
     * @return          Value type for index provided,
     *                  or JSON_Type_Invalid if it does not exist.
     */
    public JSONCellType GetType(int index)
    {
        return view_as<JSONCellType>(
            this.GetMeta(index, JSON_Meta_Type, JSON_Type_Invalid)
        );
    }

    /**
     * Gets the length of the string stored at an index.
     *
     * @param index     Index to get string length for.
     * @return          Length of string at index provided,
     *                  or -1 if it is not a string/does not exist.
     */
    public int GetSize(int index)
    {
        return view_as<int>(this.GetMeta(index, JSON_Meta_Size, -1));
    }

    /**
     * Gets whether the index should be hidden from encoding.
     *
     * @param index     Index to get hidden state for.
     * @return          Whether or not the index should be hidden.
     */
    public bool GetHidden(int index)
    {
        return view_as<bool>(this.GetMeta(index, JSON_Meta_Hidden, false));
    }

    /**
     * @section Metadata Setters
     */

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     * @internal
     *
     * @see JSON_Object.SetMeta
     */
    public bool SetMeta(int index, JSONMetaInfo meta, any value)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetMeta(key, meta, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     * @internal
     *
     * @see JSON_Object.RemoveMeta
     */
    public bool RemoveMeta(int index, JSONMetaInfo meta)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.RemoveMeta(key, meta);
    }

    /**
     * Sets whether the index should be hidden from encoding.
     *
     * @param index     Index to set hidden state for.
     * @param hidden    Whether or not the index should be hidden.
     * @return          True on success, false otherwise.
     */
    public bool SetHidden(int index, bool hidden)
    {
        return this.SetMeta(index, JSON_Meta_Hidden, hidden);
    }

    /**
     * @section Getters
     */

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see MetaStringMap.GetValue
     */
    public bool GetValue(int index, any &value)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.GetValue(key, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     * @internal
     *
     * @see MetaStringMap.GetOptionalValue
     */
    public any GetOptionalValue(int index, any default_value = -1)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.GetOptionalValue(key, default_value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see MetaStringMap.GetString
     */
    public bool GetString(int index, char[] value, int max_size, int &size = 0)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.GetString(key, value, max_size, size);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see MetaStringMap.GetInt
     */
    public int GetInt(int index, int default_value = -1)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return default_value;
        }

        return this.Super.GetInt(key, default_value);
    }

    #if SM_INT64_SUPPORTED
    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.GetInt64
     */
    public bool GetInt64(int index, int value[2])
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.GetInt64(key, value);
    }
    #endif

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see MetaStringMap.GetFloat
     */
    public float GetFloat(int index, float default_value = -1.0)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return default_value;
        }

        return this.Super.GetFloat(key, default_value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see MetaStringMap.GetBool
     */
    public bool GetBool(int index, bool default_value = false)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return default_value;
        }

        return this.Super.GetBool(key, default_value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see MetaStringMap.GetObject
     */
    public JSON_Object GetObject(int index, JSON_Object default_value = null)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return default_value;
        }

        return this.Super.GetObject(key, default_value);
    }

    /**
     * @section Setters
     */

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetString
     */
    public bool SetString(int index, const char[] value)
    {
        if (! this.CanUseType(JSON_Type_String)) {
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetString(key, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetInt
     */
    public bool SetInt(int index, int value)
    {
        if (! this.CanUseType(JSON_Type_Int)) {
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetInt(key, value);
    }

    #if SM_INT64_SUPPORTED
    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetInt64
     */
    public bool SetInt64(int index, int value[2])
    {
        if (! this.CanUseType(JSON_Type_Int64)) {
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetInt64(key, value);
    }
    #endif

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetFloat
     */
    public bool SetFloat(int index, float value)
    {
        if (! this.CanUseType(JSON_Type_Float)) {
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetFloat(key, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetBool
     */
    public bool SetBool(int index, bool value)
    {
        if (! this.CanUseType(JSON_Type_Bool)) {
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetBool(key, value);
    }

    /**
     * Converts index to a string ('key') and calls the relevant Super method.
     *
     * @see JSON_Object.SetObject
     */
    public bool SetObject(int index, JSON_Object value)
    {
        if (! this.CanUseType(JSON_Type_Object)) {
            return false;
        }

        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        return this.Super.SetObject(key, value);
    }

    /**
     * @section Pushers
     */

    /**
     * Pushes a string to the end of the array.
     *
     * @param value     Value to push.
     * @return          The element's index on success, -1 otherwise.
     */
    public int PushString(const char[] value)
    {
        int index = this.Length;
        if (! this.SetString(index, value)) {
            return -1;
        }

        return index;
    }

    /**
     * Pushes an int to the end of the array.
     *
     * @param value     Value to push.
     * @return          The element's index on success, -1 otherwise.
     */
    public int PushInt(int value)
    {
        int index = this.Length;
        if (! this.SetInt(index, value)) {
            return -1;
        }

        return index;
    }

    #if SM_INT64_SUPPORTED
    /**
     * Pushes an int64 to the end of the array.
     *
     * @param value     Value to push.
     * @return          The element's index on success, -1 otherwise.
     */
    public int PushInt64(int value[2])
    {
        int index = this.Length;
        if (! this.SetInt64(index, value)) {
            return -1;
        }

        return index;
    }
    #endif

    /**
     * Pushes a float to the end of the array.
     *
     * @param value     Value to push.
     * @return          The element's index on success, -1 otherwise.
     */
    public int PushFloat(float value)
    {
        int index = this.Length;
        if (! this.SetFloat(index, value)) {
            return -1;
        }

        return index;
    }

    /**
     * Pushes a bool to the end of the array.
     *
     * @param value     Value to push.
     * @return          The element's index on success, -1 otherwise.
     */
    public int PushBool(bool value)
    {
        int index = this.Length;
        if (! this.SetBool(index, value)) {
            return -1;
        }

        return index;
    }

    /**
     * Pushes a JSON object to the end of the array.
     *
     * @param value     Value to push.
     * @return          The element's index on success, -1 otherwise.
     */
    public int PushObject(JSON_Object value)
    {
        int index = this.Length;
        if (! this.SetObject(index, value)) {
            return -1;
        }

        return index;
    }

    /**
     * @section Search Helpers
     */

    /**
     * Finds the index of a value in the array.
     *
     * @param value     Value to search for.
     * @return          The index of the value if it is found, -1 otherwise.
     */
    public int IndexOf(any value)
    {
        any current;
        int length = this.Length;
        for (int i = 0; i < length; i += 1) {
            if (this.GetValue(i, current) && value == current) {
                return i;
            }
        }

        return -1;
    }

    /**
     * Finds the index of a string in the array.
     *
     * @param value     String to search for.
     * @return          The index of the string if it is found, -1 otherwise.
     */
    public int IndexOfString(const char[] value)
    {
        int length = this.Length;
        for (int i = 0; i < length; i += 1) {
            if (this.GetType(i) != JSON_Type_String) {
                continue;
            }

            int current_size = this.GetSize(i);
            char[] current = new char[current_size];
            this.GetString(i, current, current_size);
            if (StrEqual(value, current)) {
                return i;
            }
        }

        return -1;
    }

    /**
     * Determines whether the array contains a value.
     *
     * @param value     Value to search for.
     * @return          True if the value is found, false otherwise.
     */
    public bool Contains(any value)
    {
        return this.IndexOf(value) != -1;
    }

    /**
     * Determines whether the array contains a string.
     *
     * @param value     String to search for.
     * @return          True if the string is found, false otherwise.
     */
    public bool ContainsString(const char[] value)
    {
        return this.IndexOfString(value) != -1;
    }

    /**
     * @section Misc
     */

    /**
     * Removes an index and its related meta-keys from the array,
     * and shifts down all following element indices.
     *
     * @param key   Key to remove.
     * @return      True on success, false if the value was never set.
     */
    public bool Remove(int index)
    {
        char key[JSON_INT_BUFFER_SIZE];
        if (! this.GetKey(index, key, sizeof(key))) {
            return false;
        }

        int length = this.Length;

        // remove existing value at index
        if (! this.Super.Remove(key)) {
            return false;
        }

        // shift all following elements down
        char current_key[JSON_INT_BUFFER_SIZE];
        for (int oldIndex = index + 1; oldIndex < length; oldIndex += 1) {
            int newIndex = oldIndex - 1;
            JSONCellType type = this.GetType(oldIndex);

            switch (type) {
                case JSON_Type_String: {
                    int str_length = this.GetSize(oldIndex);
                    char[] str_value = new char[str_length];

                    this.GetString(oldIndex, str_value, str_length);
                    this.SetString(newIndex, str_value);
                }
                case JSON_Type_Int: {
                    this.SetInt(newIndex, this.GetInt(oldIndex));
                }
                #if SM_INT64_SUPPORTED
                case JSON_Type_Int64: {
                    int value[2];
                    this.GetInt64(oldIndex, value);
                    this.SetInt64(newIndex, value);
                }
                #endif
                case JSON_Type_Float: {
                    this.SetFloat(newIndex, this.GetFloat(oldIndex));
                }
                case JSON_Type_Bool: {
                    this.SetBool(newIndex, this.GetBool(oldIndex));
                }
                case JSON_Type_Object: {
                    this.SetObject(newIndex, this.GetObject(oldIndex));
                }
            }

            this.SetHidden(newIndex, this.GetHidden(oldIndex));

            if (this.GetKey(
                oldIndex,
                current_key,
                sizeof(current_key)
            )) {
                this.Super.Remove(current_key);
            }
        }

        return true;
    }

    /**
     * Concatenates the entries from the specified array
     * on to the end of this array.
     *
     * @param from      Array to concat entries from.
     * @return          True on success, false otherwise.
     * @error           If the object being merged is an object or the
     *                  arrays being merged don't have the same strict
     *                  type set, an error will be thrown.
     */
    public bool Concat(JSON_Array from)
    {
        if (! this.IsArray || ! from.IsArray) {
            json_set_last_error("attempted to concat using object(s)");

            return false;
        }

        if (this.Type != from.Type) {
            json_set_last_error(
                "attempted to concat arrays with mismatched strict types"
            );

            return false;
        }

        int current_length = this.Length;
        int json_size = from.Length;
        for (int i = 0; i < json_size; i += 1) {
            JSONCellType type = from.GetType(i);
            // skip keys of unknown type
            if (type == JSON_Type_Invalid) {
                continue;
            }

            // push value onto array
            switch (type) {
                case JSON_Type_String: {
                    int length = from.GetSize(i);
                    char[] value = new char[length];
                    from.GetString(i, value, length);

                    this.PushString(value);
                }
                case JSON_Type_Int: {
                    this.PushInt(from.GetInt(i));
                }
                #if SM_INT64_SUPPORTED
                case JSON_Type_Int64: {
                    int value[2];
                    from.GetInt64(i, value);
                    this.PushInt64(value);
                }
                #endif
                case JSON_Type_Float: {
                    this.PushFloat(from.GetFloat(i));
                }
                case JSON_Type_Bool: {
                    this.PushBool(from.GetBool(i));
                }
                case JSON_Type_Object: {
                    this.PushObject(from.GetObject(i));
                }
            }

            this.SetHidden(current_length + i, from.GetHidden(i));
        }

        return true;
    }

    /**
     * Typed Helpers
     */

    /**
     * The length of the longest string in the array.
     */
    property int MaxStringLength
    {
        public get()
        {
            int max = -1;
            int current = -1;
            int length = this.Length;
            for (int i = 0; i < length; i += 1) {
                if (this.GetType(i) != JSON_Type_String) {
                    continue;
                }

                current = this.GetSize(i);
                if (current > max) {
                    max = current;
                }
            }

            return max;
        }
    }

    /**
     * Sets the array to enforce a specific type.
     * This will fail if there are any existing elements
     * in the array which are not of the same type.
     *
     * @param type  Type to enforce.
     * @return      True if the type was enforced successfully, false otherwise.
     */
    public bool EnforceType(JSONCellType type)
    {
        if (type == JSON_Type_Invalid) {
            this.Type = type;

            return true;
        }

        int length = this.Length;
        for (int i = 0; i < length; i += 1) {
            if (this.GetType(i) != type) {
                return false;
            }
        }

        this.Type = type;

        return true;
    }

    /**
     * Imports a native array's values into the instance.
     *
     * @param type      Type of native values.
     * @param values    Array of values.
     * @param size      Size of array.
     * @return          True on success, false otherwise.
     */
    public bool ImportValues(JSONCellType type, any[] values, int size)
    {
        bool success = true;
        for (int i = 0; i < size; i += 1) {
            switch (type) {
                case JSON_Type_Int: {
                    success = success && this.PushInt(values[i]) > -1;
                }
                case JSON_Type_Float: {
                    success = success && this.PushFloat(values[i]) > -1;
                }
                case JSON_Type_Bool: {
                    success = success && this.PushBool(values[i]) > -1;
                }
                case JSON_Type_Object: {
                    success = success && this.PushObject(values[i]) > -1;
                }
            }
        }

        return success;
    }

    /**
     * Imports a native array's strings into the instance.
     *
     * @param strings   Array of strings.
     * @param size      Size of array.
     * @return          True on success, false otherwise.
     */
    public bool ImportStrings(const char[][] strings, int size)
    {
        bool success = true;
        for (int i = 0; i < size; i += 1) {
            success = success && this.PushString(strings[i]) > -1;
        }

        return success;
    }

    /**
     * Exports the instance's values into a native array.
     *
     * @param values    Array to export to.
     * @param max_size  Maximum size of array.
     */
    public void ExportValues(any[] values, int max_size)
    {
        int length = this.Length;
        if (length < max_size) {
            max_size = length;
        }

        for (int i = 0; i < max_size; i += 1) {
            this.GetValue(i, values[i]);
        }
    }

    /**
     * Exports the instance's strings into a native array.
     *
     * @param values            Array to export to.
     * @param max_size          Maximum size of array.
     * @param max_string_size   Maximum size of array elements.
     */
    public void ExportStrings(
        char[][] values,
        int max_size,
        int max_string_size
    ) {
        int length = this.Length;
        if (length < max_size) {
            max_size = length;
        }

        for (int i = 0; i < max_size; i += 1) {
            this.GetString(i, values[i], max_string_size);
        }
    }

    /**
     * json.inc Aliases
     */

    /** @see JSON_Object.ShallowCopy */
    public JSON_Array ShallowCopy()
    {
        return view_as<JSON_Array>(this.Super.ShallowCopy());
    }

    /** @see JSON_Object.DeepCopy */
    public JSON_Array DeepCopy()
    {
        return view_as<JSON_Array>(this.Super.DeepCopy());
    }

    /**
     * @section Constructor
     */

    /**
     * Creates a new JSON_Array.
     *
     * @param type  The type to enforce for this array, or
     *              JSON_Type_Invalid for no enforced type.
     * @return      A new JSON_Array.
     */
    public JSON_Array(JSONCellType type = JSON_Type_Invalid)
    {
        JSON_Array self = view_as<JSON_Array>(new JSON_Object());
        self.Meta.SetBool(JSON_ARRAY_KEY, true);
        self.EnforceType(type);

        return self;
    }
};
