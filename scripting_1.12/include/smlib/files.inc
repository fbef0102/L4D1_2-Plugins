#if defined _smlib_files_included
	#endinput
#endif
#define _smlib_files_included

#include <sourcemod>
#include <sdktools>
#include <smlib/arrays>

/**
 * Gets the Base name of a path.
 * Examples:
 * blub.txt -> "blub.txt"
 * /sourcemod/extensions/example.ext.so -> "example.ext.so"
 *
 * @param path			File path
 * @param buffer		String buffer array
 * @param size			Size of string buffer
 */
stock void File_GetBaseName(const char[] path, char[] buffer, int size)
{
	if (path[0] == '\0') {
		buffer[0] = '\0';
		return;
	}

	int pos_start = FindCharInString(path, '/', true);

	if (pos_start == -1) {
		pos_start = FindCharInString(path, '\\', true);
	}

	pos_start++;

	strcopy(buffer, size, path[pos_start]);
}

/**
 * Gets the Directory of a path (without the file name).
 * Does not work with "." as the path.
 * Examples:
 * blub.txt -> "blub.txt"
 * /sourcemod/extensions/example.ext.so -> "example.ext.so"
 *
 * @param path			File path
 * @param buffer		String buffer array
 * @param size			Size of string buffer
 */
stock void File_GetDirName(const char[] path, char[] buffer, int size)
{
	if (path[0] == '\0') {
		buffer[0] = '\0';
		return;
	}

	int pos_start = FindCharInString(path, '/', true);

	if (pos_start == -1) {
		pos_start = FindCharInString(path, '\\', true);

		if (pos_start == -1) {
			buffer[0] = '\0';
			return;
		}
	}

	strcopy(buffer, size, path);
	buffer[pos_start] = '\0';
}

/**
 * Gets the File name of a path.
 * blub.txt -> "blub"
 * /sourcemod/extensions/example.ext.so -> "example.ext"
 *
 * @param path			File path
 * @param buffer		String buffer array
 * @param size			Size of string buffer
 */
stock void File_GetFileName(const char[] path, char[] buffer, int size)
{
	if (path[0] == '\0') {
		buffer[0] = '\0';
		return;
	}

	File_GetBaseName(path, buffer, size);

	int pos_ext = FindCharInString(buffer, '.', true);

	if (pos_ext != -1) {
		buffer[pos_ext] = '\0';
	}
}

/**
 * Gets the Extension of a file.
 * Examples:
 * blub.inc.txt -> "txt"
 * /sourcemod/extensions/example.ext.so -> "so"
 *
 * @param path			Path String
 * @param buffer		String buffer array
 * @param size			Max length of string buffer
 */
stock void File_GetExtension(const char[] path, char[] buffer, int size)
{
	int extpos = FindCharInString(path, '.', true);

	if (extpos == -1) {
		buffer[0] = '\0';
		return;
	}

	strcopy(buffer, size, path[++extpos]);
}

/**
 * Adds a path to the downloadables network string table.
 * This can be a file or directory and also works recursed.
 * You can optionally specify file extensions that should be ignored.
 * Bz2 and ztmp are automatically ignored.
 * It only adds files that actually exist.
 * You can also specify a wildcard * after the ., very useful for models.
 * This forces a client to download the file if they do not already have it.
 *
 * @param path			Path String
 * @param recursive		Whether to do recursion or not.
 * @param ignoreExts	Optional: 2 dimensional String array.You can define it like this: new String:ignore[][] = { ".ext1", ".ext2" };
 * @param size			This should be set to the number of file extensions in the ignoreExts array (sizeof(ignore) for the example above)
 */

// Damn you SourcePawn :( I didn't want to
char _smlib_empty_twodimstring_array[][] = { { '\0' } };
stock void File_AddToDownloadsTable(const char[] path, bool recursive=true, const char[][] ignoreExts=_smlib_empty_twodimstring_array, int size=0)
{
	if (path[0] == '\0') {
		return;
	}

	if (FileExists(path)) {

		char fileExtension[5];
		File_GetExtension(path, fileExtension, sizeof(fileExtension));

		if (StrEqual(fileExtension, "bz2", false) || StrEqual(fileExtension, "ztmp", false)) {
			return;
		}

		if (Array_FindString(ignoreExts, size, fileExtension) != -1) {
			return;
		}

		char path_new[PLATFORM_MAX_PATH];
		strcopy(path_new, sizeof(path_new), path);
		ReplaceString(path_new, sizeof(path_new), "//", "/");

		AddFileToDownloadsTable(path_new);
	}
	else if (recursive && DirExists(path)) {

		char dirEntry[PLATFORM_MAX_PATH];
		DirectoryListing __dir = OpenDirectory(path);

		while (ReadDirEntry(__dir, dirEntry, sizeof(dirEntry))) {

			if (StrEqual(dirEntry, ".") || StrEqual(dirEntry, "..")) {
				continue;
			}

			Format(dirEntry, sizeof(dirEntry), "%s/%s", path, dirEntry);
			File_AddToDownloadsTable(dirEntry, recursive, ignoreExts, size);
		}

		delete __dir;
	}
	else if (FindCharInString(path, '*', true)) {

		char fileExtension[4];
		File_GetExtension(path, fileExtension, sizeof(fileExtension));

		if (StrEqual(fileExtension, "*")) {

			char dirName[PLATFORM_MAX_PATH],
				 fileName[PLATFORM_MAX_PATH],
				 dirEntry[PLATFORM_MAX_PATH];

			File_GetDirName(path, dirName, sizeof(dirName));
			File_GetFileName(path, fileName, sizeof(fileName));
			StrCat(fileName, sizeof(fileName), ".");

			DirectoryListing __dir = OpenDirectory(dirName);
			while (ReadDirEntry(__dir, dirEntry, sizeof(dirEntry))) {

				if (StrEqual(dirEntry, ".") || StrEqual(dirEntry, "..")) {
					continue;
				}

				if (strncmp(dirEntry, fileName, strlen(fileName)) == 0) {
					Format(dirEntry, sizeof(dirEntry), "%s/%s", dirName, dirEntry);
					File_AddToDownloadsTable(dirEntry, recursive, ignoreExts, size);
				}
			}

			delete __dir;
		}
	}
}


/*
 * Adds all files/paths in the given text file to the download table.
 * Recursive mode enabled, see File_AddToDownloadsTable()
 * Comments are allowed ! Supported comment types are ; // #
 *
 * @param path			Path to the .txt file.
 */
stock void File_ReadDownloadList(const char[] path)
{
	File file = OpenFile(path, "r");

	if (file  == INVALID_HANDLE) {
		return;
	}

	char buffer[PLATFORM_MAX_PATH];
	while (!IsEndOfFile(file)) {
		ReadFileLine(file, buffer, sizeof(buffer));

		int pos;
		pos = StrContains(buffer, "//");
		if (pos != -1) {
			buffer[pos] = '\0';
		}

		pos = StrContains(buffer, "#");
		if (pos != -1) {
			buffer[pos] = '\0';
		}

		pos = StrContains(buffer, ";");
		if (pos != -1) {
			buffer[pos] = '\0';
		}

		TrimString(buffer);

		if (buffer[0] == '\0') {
			continue;
		}

		File_AddToDownloadsTable(buffer);
	}

	delete file;
}

/*
 * Attempts to load a translation file and optionally unloads the plugin if the file
 * doesn't exist (also prints an error message).
 *
 * @param file			Filename of the translations file (eg. <pluginname>.phrases).
 * @param setFailState	If true, it sets the failstate if the translations file doesn't exist
 * @return				True on success, false otherwise (only if setFailState is set to false)
 */
stock bool File_LoadTranslations(const char[] file, bool setFailState=true)
{
	char path[PLATFORM_MAX_PATH];

	BuildPath(Path_SM, path, sizeof(path), "translations/%s", file);

	if (FileExists(path)) {
		LoadTranslations(file);
		return true;
	}

	Format(path,sizeof(path), "%s.txt", path);

	if (!FileExists(path)) {

		if (setFailState) {
			SetFailState("Unable to locate translation file (%s).", path);
		}

		return false;
	}

	LoadTranslations(file);

	return true;
}

/*
 * Reads the contents of a given file into a string buffer in binary mode.
 *
 * @param path		Path to the file
 * @param buffer	String buffer
 * @param size		If -1, reads until a null terminator is encountered in the file.  Otherwise, read_count bytes are read into the buffer provided.  In this case the buffer is not explicitly null terminated, and the buffer will contain any null terminators read from the file.
 * @return			Number of characters written to the buffer, or -1 if an error was encountered.
 */
stock int File_ToString(const char[] path, char[] buffer, int size)
{
	File file = OpenFile(path, "rb");

	if (file == INVALID_HANDLE) {
		buffer[0] = '\0';
		return -1;
	}

	int num_bytes_written = ReadFileString(file, buffer, size);
	delete file;

	return num_bytes_written;
}

/*
 * Writes a string into a file in binary mode.
 *
 * @param file		Path to the file
 * @param str		String to write
 * @return			True on success, false otherwise
 */
stock bool File_StringToFile(const char[] path, char[] str)
{
	File file = OpenFile(path, "wb");

	if (file == INVALID_HANDLE) {
		return false;
	}

	bool success = WriteFileString(file, str, false);
	delete file;

	return success;
}

/*
 * Copies file source to destination
 * Based on code of javalia:
 * http://forums.alliedmods.net/showthread.php?t=159895
 *
 * @param source		Input file
 * @param destination	Output file
 * @return				True on success, false otherwise
 */
stock bool File_Copy(const char[] source, const char[] destination)
{
	File file_source = OpenFile(source, "rb");

	if (file_source == INVALID_HANDLE) {
		return false;
	}

	File file_destination = OpenFile(destination, "wb");

	if (file_destination == INVALID_HANDLE) {
		delete file_source;
		return false;
	}

	int buffer[32];
	int cache;

	while (!IsEndOfFile(file_source)) {
		cache = ReadFile(file_source, buffer, sizeof(buffer), 1);
		WriteFile(file_destination, buffer, cache, 1);
	}

	delete file_source;
	delete file_destination;

	return true;
}

/*
 * Recursively copies (the content) of a directory or file specified
 * by "path" to "destination".
 * Note that because of Sourcemod API limitations this currently does not
 * takeover the file permissions (it leaves them default).
 * Links will be resolved.
 *
 * @param path			Source path
 * @param destination	Destination directory (This can only be a directory)
 * @param stop_on_error	Optional: Set to true to stop on error (ie can't read a file)
 * @param dirMode		Optional: File mode for directories that will be created (Default = 0755), don't forget to convert FROM octal
 * @return				True on success, false otherwise
 */
stock bool File_CopyRecursive(const char[] path, const char[] destination, bool stop_on_error=false, int dirMode=493)
{
	if (FileExists(path)) {
		return File_Copy(path, destination);
	}
	else if (DirExists(path)) {
		return Sub_File_CopyRecursive(path, destination, stop_on_error, FileType_Directory, dirMode);
	}
	else {
		return false;
	}
}

static stock bool Sub_File_CopyRecursive(const char[] path, const char[] destination, bool stop_on_error=false, FileType fileType, int dirMode)
{
	if (fileType == FileType_File) {
		return File_Copy(path, destination);
	}
	else if (fileType == FileType_Directory) {

		if (!CreateDirectory(destination, dirMode) && stop_on_error) {
			return false;
		}

		DirectoryListing directory = OpenDirectory(path);

		if (directory == INVALID_HANDLE) {
			return false;
		}

		char
			source_buffer[PLATFORM_MAX_PATH],
			destination_buffer[PLATFORM_MAX_PATH];
		FileType type;

		while (ReadDirEntry(directory, source_buffer, sizeof(source_buffer), type)) {

			if (StrEqual(source_buffer, "..") || StrEqual(source_buffer, ".")) {
				continue;
			}

			Format(destination_buffer, sizeof(destination_buffer), "%s/%s", destination, source_buffer);
			Format(source_buffer, sizeof(source_buffer), "%s/%s", path, source_buffer);

			if (type == FileType_File) {
				File_Copy(source_buffer, destination_buffer);
			}
			else if (type == FileType_Directory) {

				if (!File_CopyRecursive(source_buffer, destination_buffer, stop_on_error, dirMode) && stop_on_error) {
					delete directory;
					return false;
				}
			}
		}

		delete directory;
	}
	else if (fileType == FileType_Unknown) {
		return false;
	}

	return true;
}
