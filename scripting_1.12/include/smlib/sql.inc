#if defined _smlib_sql_included
	#endinput
#endif
#define _smlib_sql_included

#include <sourcemod>
#include <dbi>

/**
 * Executes a threaded SQL Query (See: SQL_TQuery)
 * This function supports the printf Syntax.
 *
 *
 * @param database		A database Handle.
 * @param callback		Callback; database is in "owner" and the query Handle is passed in "hndl".
 * @param data			Extra data value to pass to the callback.
 * @param format		Query string, printf syntax supported
 * @param priority		Priority queue to use
 * @param ...			Variable number of format parameters.
 */
stock void SQL_TQueryF(Database database, SQLTCallback callback, any data, DBPriority priority=DBPrio_Normal, const char[] format, any ...) {

	if (!database) {
		ThrowError("[SMLIB] Error: Invalid database handle.");
		return;
	}

	char query[16384];
	VFormat(query, sizeof(query), format, 6);

	SQL_TQuery(database, callback, query, data, priority);
}

/**
 * Fetches an integer from a field in the current row of a result set (See: SQL_FetchInt)
 *
 * @param query			A query (or statement) Handle.
 * @param field			The field index (starting from 0).
 * @param result		Optional variable to store the status of the return value.
 * @return				An integer value.
 * @error				Invalid query Handle or field index, invalid
 *						type conversion requested from the database,
 *						or no current result set.
 */
stock int SQL_FetchIntByName(DBResultSet query, const char[] fieldName, DBResult &result=DBVal_Error) {

	int fieldNum;
	SQL_FieldNameToNum(query, fieldName, fieldNum);

	return SQL_FetchInt(query, fieldNum, result);
}

/**
 * Fetches a bool from a field in the current row of a result set (See: SQL_FetchInt)
 *
 * @param query			A query (or statement) Handle.
 * @param field			The field index (starting from 0).
 * @param result		Optional variable to store the status of the return value.
 * @return				A bool value.
 * @error				Invalid query Handle or field index, invalid
 *						type conversion requested from the database,
 *						or no current result set.
 */
stock bool SQL_FetchBoolByName(DBResultSet query, const char[] fieldName, DBResult &result=DBVal_Error) {

	return SQL_FetchIntByName(query, fieldName, result) != 0;
}

/**
 * Fetches a float from a field in the current row of a result set. (See: SQL_FetchFloat)
 *
 * @param query			A query (or statement) Handle.
 * @param field			The field index (starting from 0).
 * @param result		Optional variable to store the status of the return value.
 * @return				A float value.
 * @error				Invalid query Handle or field index, invalid
 *						type conversion requested from the database,
 *						or no current result set.
 */
stock float SQL_FetchFloatByName(DBResultSet query, const char[] fieldName, DBResult &result=DBVal_Error) {

	int fieldNum;
	SQL_FieldNameToNum(query, fieldName, fieldNum);

	return SQL_FetchFloat(query, fieldNum, result);
}

/**
 * Fetches a string from a field in the current row of a result set. (See: SQL_FetchString)
 *
 * @param query			A query (or statement) Handle.
 * @param field			The field index (starting from 0).
 * @param buffer		String buffer.
 * @param maxlength		Maximum size of the string buffer.
 * @param result		Optional variable to store the status of the return value.
 * @return				Number of bytes written.
 * @error				Invalid query Handle or field index, invalid
 *						type conversion requested from the database,
 *						or no current result set.
 */
stock int SQL_FetchStringByName(DBResultSet query, const char[] fieldName, char[] buffer, int maxlength, DBResult &result=DBVal_Error) {

	int fieldNum;
	SQL_FieldNameToNum(query, fieldName, fieldNum);

	return SQL_FetchString(query, fieldNum, buffer, maxlength, result);
}
