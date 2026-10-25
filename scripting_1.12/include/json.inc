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

#if defined _json_included
 #endinput
#endif
#define _json_included

#include <string>
#include <json/definitions>
#include <json/helpers/decode>
#include <json/helpers/errors>
#include <json/helpers/string>
#include <json/object>
#include <json/array>

/**
 * Calculates the buffer size required to store an encoded JSON instance.
 *
 * @param obj       Object to encode.
 * @param options   Bitwise combination of `JSON_ENCODE_*` options.
 * @param depth     The current depth of the encoder.
 * @return          The required buffer size.
 */
stock int json_encode_size(JSON_Object obj, int options = JSON_NONE, int depth = 0)
{
    bool pretty_print = (options & JSON_ENCODE_PRETTY) != 0;

    bool is_array = obj.IsArray;

    int size = 1; // for opening bracket

    // used in key iterator
    int json_size = obj.Length;
    JSON_Object child = null;
    bool is_empty = true;
    int str_length = 0;

    int key_length = 0;
    for (int i = 0; i < json_size; i += 1) {
        key_length = is_array ? JSON_INT_BUFFER_SIZE : obj.GetKeySize(i);
        char[] key = new char[key_length];

        if (is_array) {
            IntToString(i, key, key_length);
        } else {
            obj.GetKey(i, key, key_length);
        }

        // skip keys that are marked as hidden
        if (obj.GetHidden(key)) {
            continue;
        }

        JSONCellType type = obj.GetType(key);
        // skip keys of unknown type
        if (type == JSON_Type_Invalid) {
            continue;
        }

        if (pretty_print) {
            size += strlen(JSON_PP_NEWLINE);
            size += (depth + 1) * strlen(JSON_PP_INDENT);
        }

        if (! is_array) {
            // add the size of the key and + 1 for :
            size += json_cell_string_size(key) + 1;

            if (pretty_print) {
                size += strlen(JSON_PP_AFTER_COLON);
            }
        }

        switch (type) {
            case JSON_Type_String: {
                str_length = obj.GetSize(key);
                char[] value = new char[str_length];
                obj.GetString(key, value, str_length);

                size += json_cell_string_size(value);
            }
            case JSON_Type_Int: {
                size += JSON_INT_BUFFER_SIZE;
            }
            #if SM_INT64_SUPPORTED
            case JSON_Type_Int64: {
                size += JSON_INT64_BUFFER_SIZE;
            }
            #endif
            case JSON_Type_Float: {
                size += JSON_FLOAT_BUFFER_SIZE;
            }
            case JSON_Type_Bool: {
                size += JSON_BOOL_BUFFER_SIZE;
            }
            case JSON_Type_Object: {
                child = obj.GetObject(key);
                size += child != null ? json_encode_size(child, options, depth + 1) : JSON_NULL_BUFFER_SIZE;
            }
        }

        // increment for comma
        size += 1;

        is_empty = false;
    }

    if (! is_empty) {
        // remove the final comma
        size -= 1;

        if (pretty_print) {
            size += strlen(JSON_PP_NEWLINE);
            size += depth * strlen(JSON_PP_INDENT);
        }
    }

    size += 2; // closing bracket + NULL

    return size;
}

/**
 * Encodes a JSON instance into its string representation.
 *
 * @param obj       Object to encode.
 * @param output    String buffer to store output.
 * @param max_size  Maximum size of string buffer.
 * @param options   Bitwise combination of `JSON_ENCODE_*` options.
 * @param depth     The current depth of the encoder.
 */
stock void json_encode(
    JSON_Object obj,
    char[] output,
    int max_size,
    int options = JSON_NONE,
    int depth = 0
)
{
    bool pretty_print = (options & JSON_ENCODE_PRETTY) != 0;

    bool is_array = obj.IsArray;
    strcopy(output, max_size, is_array ? "[" : "{");

    // used in key iterator
    int json_size = obj.Length;
    int builder_size = 0;
    int str_length = 1;
    JSON_Object child = null;
    int cell_length = 0;
    bool is_empty = true;

    int key_length = 0;
    for (int i = 0; i < json_size; i += 1) {
        key_length = is_array ? JSON_INT_BUFFER_SIZE : obj.GetKeySize(i);
        char[] key = new char[key_length];

        if (is_array) {
            IntToString(i, key, key_length);
        } else {
            obj.GetKey(i, key, key_length);
        }

        // skip keys that are marked as hidden
        if (obj.GetHidden(key)) {
            continue;
        }

        JSONCellType type = obj.GetType(key);
        // skip keys of unknown type
        if (type == JSON_Type_Invalid) {
            continue;
        }

        // determine the length of the char[] needed to represent our cell data
        cell_length = 0;
        switch (type) {
            case JSON_Type_String: {
                str_length = obj.GetSize(key);
                char[] value = new char[str_length];
                obj.GetString(key, value, str_length);

                cell_length = json_cell_string_size(value);
            }
            case JSON_Type_Int: {
                cell_length = JSON_INT_BUFFER_SIZE;
            }
            #if SM_INT64_SUPPORTED
            case JSON_Type_Int64: {
                cell_length = JSON_INT64_BUFFER_SIZE;
            }
            #endif
            case JSON_Type_Float: {
                cell_length = JSON_FLOAT_BUFFER_SIZE;
            }
            case JSON_Type_Bool: {
                cell_length = JSON_BOOL_BUFFER_SIZE;
            }
            case JSON_Type_Object: {
                child = obj.GetObject(key);
                cell_length = child != null ? max_size : JSON_NULL_BUFFER_SIZE;
            }
        }

        // fit the contents into the cell
        char[] cell = new char[cell_length];
        switch (type) {
            case JSON_Type_String: {
                char[] value = new char[str_length];
                obj.GetString(key, value, str_length);
                json_cell_string(value, cell, cell_length);
            }
            case JSON_Type_Int: {
                int value = obj.GetInt(key);
                IntToString(value, cell, cell_length);
            }
            #if SM_INT64_SUPPORTED
            case JSON_Type_Int64: {
                int value[2];
                obj.GetInt64(key, value);
                Int64ToString(value, cell, cell_length);
            }
            #endif
            case JSON_Type_Float: {
                float value = obj.GetFloat(key);
                FloatToString(value, cell, cell_length);

                // trim trailing 0s from float output up until decimal point
                int last_char = strlen(cell) - 1;
                while (cell[last_char] == '0' && cell[last_char - 1] != '.') {
                    cell[last_char--] = '\0';
                }
            }
            case JSON_Type_Bool: {
                bool value = obj.GetBool(key);
                strcopy(cell, cell_length, value ? "true" : "false");
            }
            case JSON_Type_Object: {
                if (child != null) {
                    json_encode(child, cell, cell_length, options, depth + 1);
                } else {
                    strcopy(cell, cell_length, "null");
                }
            }
        }

        // make the builder fit our key:value
        // use previously determined cell length and + 1 for ,
        builder_size = cell_length + 1;
        if (! is_array) {
            // get the length of the key and + 1 for :
            builder_size += json_cell_string_size(key) + 1;

            if (pretty_print) {
                builder_size += strlen(JSON_PP_AFTER_COLON);
            }
        }

        char[] builder = new char[builder_size];
        strcopy(builder, builder_size, "");

        // add the key if we're working with an object
        if (! is_array) {
            json_cell_string(key, builder, builder_size);
            StrCat(builder, builder_size, ":");

            if (pretty_print) {
                StrCat(builder, builder_size, JSON_PP_AFTER_COLON);
            }
        }

        // add the value and a trailing comma
        StrCat(builder, builder_size, cell);
        StrCat(builder, builder_size, ",");

        // prepare pretty printing then send builder to output afterwards
        if (pretty_print) {
            StrCat(output, max_size, JSON_PP_NEWLINE);

            for (int j = 0; j < depth + 1; j += 1) {
                StrCat(output, max_size, JSON_PP_INDENT);
            }
        }

        StrCat(output, max_size, builder);

        is_empty = false;
    }

    if (! is_empty) {
        // remove the final comma
        output[strlen(output) - 1] = '\0';

        if (pretty_print) {
            StrCat(output, max_size, JSON_PP_NEWLINE);

            for (int j = 0; j < depth; j += 1) {
                StrCat(output, max_size, JSON_PP_INDENT);
            }
        }
    }

    // append closing bracket
    StrCat(output, max_size, is_array ? "]" : "}");
}

/**
 * Decodes a JSON string into a JSON instance.
 *
 * @param buffer    Buffer to decode.
 * @param options   Bitwise combination of `JSON_DECODE_*` options.
 * @param pos       Current position of the decoder as bytes
 *                  offset into the buffer.
 * @param depth     Current nested depth of the decoder.
 * @return          JSON instance or null if decoding failed becase
 *                  the buffer didn't contain valid JSON.
 * @error           If the buffer does not contain valid JSON,
 *                  an error will be thrown.
 */
stock JSON_Object json_decode(
    const char[] buffer,
    int options = JSON_NONE,
    int &pos = 0,
    int depth = 0
)
{
    int length = strlen(buffer);
    // skip preceding whitespace
    if (! json_skip_whitespace(buffer, length, pos)) {
        json_set_last_error("buffer ended early at position %d", pos);

        return null;
    }

    bool is_array = false;
    JSON_Array arr = null;
    JSON_Object obj = null;
    if (buffer[pos] == '{') {
        is_array = false;
        obj = new JSON_Object();
    } else if (buffer[pos] == '[') {
        is_array = true;
        arr = new JSON_Array();
    } else {
        json_set_last_error("no object or array found at position %d", pos);

        return null;
    }

    bool allow_single_quotes = (options & JSON_DECODE_SINGLE_QUOTES) > 0;

    bool empty_checked = false;

    // while we haven't reached the end of our structure
    while (
        (! is_array && buffer[pos] != '}')
        || (is_array && buffer[pos] != ']')
    ) {
        // pos is either an opening structure or comma, so increment past it
        pos += 1;

        // skip any whitespace preceding the element
        if (! json_skip_whitespace(buffer, length, pos)) {
            json_set_last_error("buffer ended early at position %d", pos);
            json_cleanup_and_delete(obj);
            json_cleanup_and_delete(arr);

            return null;
        }

        // if we haven't checked for empty yet and we are at the end
        // of an object or array, we can stop here (empty structure)
        if (! empty_checked) {
            if (
                (! is_array && buffer[pos] == '}')
                || (is_array && buffer[pos] == ']')
            ) {
                break;
            }

            empty_checked = true;
        }

        int key_length = 1;
        if (! is_array) {
            // if dealing with an object, look for the key and determine length
            if (! json_is_string(buffer[pos], allow_single_quotes)) {
                json_set_last_error("expected key string at position %d", pos);
                json_cleanup_and_delete(obj);
                json_cleanup_and_delete(arr);

                return null;
            }

            key_length = json_extract_string_size(buffer, length, pos);
        }

        char[] key = new char[key_length];

        if (! is_array) {
            // extract the key from the buffer
            json_extract_string(buffer, length, pos, key, key_length, is_array);

            // skip any whitespace following the key
            if (! json_skip_whitespace(buffer, length, pos)) {
                json_set_last_error("buffer ended early at position %d", pos);
                json_cleanup_and_delete(obj);
                json_cleanup_and_delete(arr);

                return null;
            }

            // ensure that we find a colon
            if (buffer[pos++] != ':') {
                json_set_last_error(
                    "expected colon after key at position %d",
                    pos
                );
                json_cleanup_and_delete(obj);
                json_cleanup_and_delete(arr);

                return null;
            }

            // skip any whitespace following the colon
            if (! json_skip_whitespace(buffer, length, pos)) {
                json_set_last_error("buffer ended early at position %d", pos);
                json_cleanup_and_delete(obj);
                json_cleanup_and_delete(arr);

                return null;
            }
        }

        int cell_length = 1;
        JSONCellType cell_type = JSON_Type_Invalid;
        if (buffer[pos] == '{' || buffer[pos] == '[') {
            cell_type = JSON_Type_Object;
        } else if (json_is_string(buffer[pos], allow_single_quotes)) {
            cell_type = JSON_Type_String;
            cell_length = json_extract_string_size(buffer, length, pos);
        } else {
            // in this particular instance, we use JSON_Type_Invalid to
            // represent any type that isn't an object or string
            cell_length = json_extract_until_end_size(
                buffer,
                length,
                pos,
                is_array
            );
        }

        if (! is_array && obj.HasKey(key)) {
            obj.Remove(key);
        }

        char[] cell = new char[cell_length];
        switch (cell_type) {
            case JSON_Type_Object: {
                // if we are dealing with an object or array, decode recursively
                JSON_Object value = json_decode(
                    buffer,
                    options,
                    pos,
                    depth + 1
                );

                // decoding failed, error will be logged in json_decode
                if (value == null) {
                    json_cleanup_and_delete(obj);
                    json_cleanup_and_delete(arr);

                    return null;
                }

                if (is_array) {
                    arr.PushObject(value);
                } else {
                    obj.SetObject(key, value);
                }
            }
            case JSON_Type_String: {
                // if we are dealing with a string, attempt to extract it
                if (! json_extract_string(
                    buffer,
                    length,
                    pos,
                    cell,
                    cell_length,
                    is_array
                )) {
                    json_set_last_error(
                        "couldn't extract string at position %d",
                        pos
                    );
                    json_cleanup_and_delete(obj);
                    json_cleanup_and_delete(arr);

                    return null;
                }

                if (is_array) {
                    arr.PushString(cell);
                } else {
                    obj.SetString(key, cell);
                }
            }
            case JSON_Type_Invalid: {
                if (! json_extract_until_end(
                    buffer,
                    length,
                    pos,
                    cell,
                    cell_length,
                    is_array
                )) {
                    json_set_last_error(
                        "couldn't extract until end at position %d",
                        pos
                    );
                    json_cleanup_and_delete(obj);
                    json_cleanup_and_delete(arr);

                    return null;
                }

                if (strlen(cell) == 0) {
                    json_set_last_error(
                        "empty cell encountered at position %d",
                        pos
                    );
                    json_cleanup_and_delete(obj);
                    json_cleanup_and_delete(arr);

                    return null;
                }

                if (json_is_int(cell)) {
                    int value = StringToInt(cell);
                    #if SM_INT64_SUPPORTED
                    if (json_is_int64(cell, value)) {
                        int values[2];
                        StringToInt64(cell, values);

                        if (is_array) {
                            arr.PushInt64(values);
                        } else {
                            obj.SetInt64(key, values);
                        }
                    } else {
                        if (is_array) {
                            arr.PushInt(value);
                        } else {
                            obj.SetInt(key, value);
                        }
                    }
                    #else
                    if (is_array) {
                        arr.PushInt(value);
                    } else {
                        obj.SetInt(key, value);
                    }
                    #endif
                } else if (json_is_float(cell)) {
                    float value = StringToFloat(cell);
                    if (is_array) {
                        arr.PushFloat(value);
                    } else {
                        obj.SetFloat(key, value);
                    }
                } else if (StrEqual(cell, "true") || StrEqual(cell, "false")) {
                    bool value = StrEqual(cell, "true");
                    if (is_array) {
                        arr.PushBool(value);
                    } else {
                        obj.SetBool(key, value);
                    }
                } else if (StrEqual(cell, "null")) {
                    if (is_array) {
                        arr.PushObject(null);
                    } else {
                        obj.SetObject(key, null);
                    }
                } else {
                    json_set_last_error(
                        "unknown type encountered at position %d: %s",
                        pos,
                        cell
                    );
                    json_cleanup_and_delete(obj);
                    json_cleanup_and_delete(arr);

                    return null;
                }
            }
        }

        if (! json_skip_whitespace(buffer, length, pos)) {
            json_set_last_error("buffer ended early at position %d", pos);
            json_cleanup_and_delete(obj);
            json_cleanup_and_delete(arr);

            return null;
        }
    }

    // skip remaining whitespace and ensure we're at the end of the buffer
    pos += 1;
    if (json_skip_whitespace(buffer, length, pos) && depth == 0) {
        json_set_last_error(
            "unexpected data after structure end at position %d",
            pos
        );
        json_cleanup_and_delete(obj);
        json_cleanup_and_delete(arr);

        return null;
    }

    return is_array ? view_as<JSON_Object>(arr) : obj;
}

/**
 * Encodes the object with the options provided and writes
 * the output to the file at the path specified.
 *
 * @param obj         Object to encode/write to file.
 * @param path        Path of file to write to.
 * @param options     Options to pass to `json_encode`.
 * @return            True on success, false otherwise.
 */
stock bool json_write_to_file(
    JSON_Object obj,
    const char[] path,
    int options = JSON_NONE
)
{
    File f = OpenFile(path, "wb");
    if (f == null) {
        return false;
    }

    int size = json_encode_size(obj, options);
    char[] buffer = new char[size];
    json_encode(obj, buffer, size, options);

    bool success = f.WriteString(buffer, false);
    delete f;

    return success;
}

/**
 * Reads and decodes the contents of a JSON file.
 *
 * @param path        Path of file to read from.
 * @param options     Options to pass to `json_decode`.
 * @return            The decoded object on success, null otherwise.
 */
stock JSON_Object json_read_from_file(const char[] path, int options = JSON_NONE)
{
    File f = OpenFile(path, "rb");
    if (f == null) {
        return null;
    }

    f.Seek(0, SEEK_END);
    int size = f.Position + 1;
    char[] buffer = new char[size];

    f.Seek(0, SEEK_SET);
    f.ReadString(buffer, size);
    delete f;

    return json_decode(buffer, options);
}

/**
 * Creates a shallow copy of the specified object.
 *
 * @param obj   Object to copy.
 * @return      A shallow copy of the specified object.
 */
stock JSON_Object json_copy_shallow(JSON_Object obj)
{
    bool isArray = obj.IsArray;
    JSON_Object result = isArray
        ? view_as<JSON_Object>(new JSON_Array())
        : new JSON_Object();

    if (isArray) {
        view_as<JSON_Array>(result).Concat(view_as<JSON_Array>(obj));
    } else {
        result.Merge(obj);
    }

    return result;
}

/**
 * Creates a deep copy of the specified object.
 *
 * @param obj   Object to copy.
 * @return      A deep copy of the specified object.
 */
stock JSON_Object json_copy_deep(JSON_Object obj)
{
    JSON_Object result = json_copy_shallow(obj);

    int length = obj.Length;
    int key_length = 0;
    for (int i = 0; i < length; i += 1) {
        key_length = obj.GetKeySize(i);
        char[] key = new char[key_length];
        obj.GetKey(i, key, key_length);

        // only deep copy objects
        JSONCellType type = obj.GetType(key);
        if (type != JSON_Type_Object) {
            continue;
        }

        JSON_Object value = obj.GetObject(key);
        result.SetObject(key, value != null ? json_copy_deep(value) : null);
    }

    return result;
}

/**
 * Recursively cleans up the instance and any instances stored within.
 *
 * @param obj   Object to clean up.
 */
stock void json_cleanup(JSON_Object obj)
{
    if (obj == null) {
        return;
    }

    int length = obj.Length;
    int key_length = 0;
    for (int i = 0; i < length; i += 1) {
        key_length = obj.GetKeySize(i);
        char[] key = new char[key_length];
        obj.GetKey(i, key, key_length);

        // only clean up objects
        JSONCellType type = obj.GetType(key);
        if (type != JSON_Type_Object) {
            continue;
        }

        JSON_Object value = obj.GetObject(key);
        if (value != null) {
            json_cleanup(value);
        }
    }

    obj.Super.Cleanup();
}

/**
 * Cleans up an object and sets the passed variable to null.
 *
 * @param obj   Object to clean up.
 */
stock void json_cleanup_and_delete(JSON_Object &obj)
{
    json_cleanup(obj);
    obj = null;
}
