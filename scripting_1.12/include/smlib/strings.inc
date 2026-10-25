#if defined _smlib_strings_included
	#endinput
#endif
#define _smlib_strings_included

#include <sourcemod>
#include <smlib/math>

/**
 * Checks if the string is numeric.
 * This correctly handles + - . in the String.
 *
 * @param str				String to check.
 * @return					True if the String is numeric, false otherwise..
 */
stock bool String_IsNumeric(const char[] str)
{
	int x=0;
	int dotsFound=0;
	int numbersFound=0;

	if (str[x] == '+' || str[x] == '-') {
		x++;
	}

	while (str[x] != '\0') {

		if (IsCharNumeric(str[x])) {
			numbersFound++;
		}
		else if (str[x] == '.') {
			dotsFound++;

			if (dotsFound > 1) {
				return false;
			}
		}
		else {
			return false;
		}

		x++;
	}

	if (!numbersFound) {
		return false;
	}

	return true;
}

/**
 * Trims a string by removing the specified chars from beginning and ending.
 * Removes all ' ', '\t', '\r', '\n' characters by default.
 * The Output String can be the same as the Input String.
 *
 * @param str				Input String.
 * @param output			Output String (Can be the as the input).
 * @param size				Size of the output String.
 * @param chars				Characters to remove.
 */
stock void String_Trim(const char[] str, char[] output, int size, const char[] chrs=" \t\r\n")
{
	int x=0;
	while (str[x] != '\0' && FindCharInString(chrs, str[x]) != -1) {
		x++;
	}

	x = strcopy(output, size, str[x]);
	x--;

	while (x >= 0 && FindCharInString(chrs, output[x]) != -1) {
		x--;
	}

	output[++x] = '\0';
}

/**
 * Removes a list of strings from a string.
 *
 * @param buffer			Input/Output buffer.
 * @param removeList		A list of strings which should be removed from buffer.
 * @param size				Number of Strings in the List.
 * @param caseSensitive		If true, comparison is case sensitive. If false (default), comparison is case insensitive.
 */
stock void String_RemoveList(char[] buffer, const char[][] removeList, int size, bool caseSensitive=false)
{
	for (int i=0; i < size; i++) {
		ReplaceString(buffer, SIZE_OF_INT, removeList[i], "", caseSensitive);
	}
}

/**
 * Converts the whole String to lower case.
 * Only works with alphabetical characters (not ÖÄÜ) because Sourcemod suxx !
 * The Output String can be the same as the Input String.
 *
 * @param input				Input String.
 * @param output			Output String.
 * @param size				Max Size of the Output string
 */
stock void String_ToLower(const char[] input, char[] output, int size)
{
	size--;

	int x=0;
	while (input[x] != '\0' && x < size) {

		output[x] = CharToLower(input[x]);

		x++;
	}

	output[x] = '\0';
}

/**
 * Converts the whole String to upper case.
 * Only works with alphabetical characters (not öäü) because Sourcemod suxx !
 * The Output String can be the same as the Input String.
 *
 * @param input				Input String.
 * @param output			Output String.
 * @param size				Max Size of the Output string
 */
stock void String_ToUpper(const char[] input, char[] output, int size)
{
	size--;

	int x=0;
	while (input[x] != '\0' && x < size) {

		output[x] = CharToUpper(input[x]);

		x++;
	}

	output[x] = '\0';
}

/**
 * Generates a random string.
 *
 *
 * @param buffer			String Buffer.
 * @param size				String Buffer size (must be length+1)
 * @param length			Number of characters being generated.
 * @param chrs				String for specifying the characters used for random character generation.
 * 							By default it will use all letters of the alphabet (upper and lower) and all numbers.
 * 							If you pass an empty String, it will use all readable ASCII characters (33 - 126)
 */
stock void String_GetRandom(char[] buffer, int size, int length=32, const char[] chrs="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234556789")
{
	int random, len;
	size--;

	if (chrs[0] != '\0') {
		len = strlen(chrs) - 1;
	}

	int n = 0;
	while (n < length && n < size) {

		if (chrs[0] == '\0') {
			random = Math_GetRandomInt(33, 126);
			buffer[n] = random;
		}
		else {
			random = Math_GetRandomInt(0, len);
			buffer[n] = chrs[random];
		}

		n++;
	}

	buffer[length] = '\0';
}

/**
 * Checks if string str starts with subString.
 *
 *
 * @param str				String to check
 * @param subString			Sub-String to check in str
 * @return					True if str starts with subString, false otherwise.
 */
stock bool String_StartsWith(const char[] str, const char[] subString)
{
	int n = 0;
	while (subString[n] != '\0') {

		if (str[n] == '\0' || str[n] != subString[n]) {
			return false;
		}

		n++;
	}

	return true;
}

/**
 * Checks if string str ends with subString.
 *
 *
 * @param str				String to check
 * @param subString			Sub-String to check in str
 * @return					True if str ends with subString, false otherwise.
 */
stock bool String_EndsWith(const char[] str, const char[] subString)
{
	int n_str = strlen(str) - 1;
	int n_subString = strlen(subString) - 1;

	if(n_str < n_subString) {
		return false;
	}

	while (n_str != 0 && n_subString != 0) {

		if (str[n_str--] != subString[n_subString--]) {
			return false;
		}
	}

	return true;
}
