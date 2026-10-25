#if defined _smlib_array_included
	#endinput
#endif
#define _smlib_array_included

#include <sourcemod>

/**
 * Returns the index for the first occurance of the given value.
 * If the value cannot be found, -1 will be returned.
 *
 * @param array			Static Array.
 * @param size			Size of the Array.
 * @param value			Value to search for.
 * @param start			Optional: Offset where to start (0 - (size-1)).
 * @return				Array index, or -1 if the value couldn't be found.
 */
stock int Array_FindValue(const any[] array, int size, any value, int start=0)
{
	if (start < 0) {
		start = 0;
	}

	for (int i=start; i < size; i++) {

		if (array[i] == value) {
			return i;
		}
	}

	return -1;
}

/**
 * Searchs for the first occurance of a string in the array.
 * If the value cannot be located, -1 will be returned.
 *
 * @param array			Static Array.
 * @param size			Size of the Array.
 * @param value			String to search for.
 * @param start			Optional: Offset where to start(0 - (size-1)).
 * @return				Array index, or -1 if the value couldn't be found.
 */
stock int Array_FindString(const char[][] array, int size, const char[] str, bool caseSensitive=true, int start=0)
{
	if (start < 0) {
		start = 0;
	}

	for (int i=start; i < size; i++) {

		if (StrEqual(array[i], str, caseSensitive)) {
			return i;
		}
	}

	return -1;
}

/**
 * Returns the Index of the Lowest value in the array
 *
 * @param array			Static Array.
 * @param size			Size of the Array.
 * @param start			Optional: Offset where to start (0 - (size-1)).
 * @return				Array index.
 */
stock int Array_FindLowestValue(const any[] array, int size, int start=0)
{
	if (start < 0) {
		start = 0;
	}

	any value = array[start];
	any tempValue;
	int x = start;

	for (int i=start; i < size; i++) {

		tempValue = array[i];

		if (tempValue < value) {
			value = tempValue;
			x = i;
		}

	}

	return x;
}

/**
 * Returns the Index of the Highest value in the array
 *
 * @param array			Static Array.
 * @param size			Size of the Array.
 * @param start			Optional: Offset where to start (0 - (size-1)).
 * @return				Array index.
 */
stock int Array_FindHighestValue(const any[] array, int size, int start=0)
{
	if (start < 0) {
		start = 0;
	}

	any value = array[start];
	any tempValue;
	int x = start;

	for (int i=start; i < size; i++) {

		tempValue = array[i];

		if (tempValue > value) {
			value = tempValue;
			x = i;
		}

	}

	return x;
}

/**
 * Fills an array with a given value in a 1 dimensional static array.
 * You can specify the amount of cells to be written.
 *
 * @param array			Static Array.
 * @param size			Number of cells to write (eg. the array's size)
 * @param value			Fill value.
 * @param start			Optional: Offset where to start (0 - (size-1)).
 */
stock void Array_Fill(any[] array, int size, any value, int start=0)
{
	if (start < 0) {
		start = 0;
	}

	for (int i=start; i < size; i++) {
		array[i] = value;
	}
}

/**
 * Copies a 1 dimensional static array.
 *
 * @param array			Static Array to copy from.
 * @param newArray		New Array to copy to.
 * @param size			Size of the array (or number of cells to copy)
 * @noreturn
 */
stock void Array_Copy(const any[] array, any[] newArray, int size)
{
	for (int i=0; i < size; i++) {
		newArray[i] = array[i];
	}
}
