/**
 * Accelerator's SourcePawn include file
 */
 
#if defined _accelerator_included
 #endinput
#endif
#define _accelerator_included


/**
 * Called when Accelerator is done uploading crash dumps.
 */
forward void Accelerator_OnDoneUploadingCrashes();

/**
 * Returns the number of crashes uploaded.
 *
 * @return					Number of crashes uploaded.
 */
native int Accelerator_GetUploadedCrashCount();

/**
 * Returns if Accelerator is done uploading crashes.
 *
 * @return					True if no more crashes will be uploaded, false if there are still crashes pending upload.
 */
native bool Accelerator_IsDoneUploadingCrashes();

/**
 * Gets a crash's HTTP response from Accelerator's backend server.
 *
 * @note					The response from the server can be anything and there is no guarantee a crash ID will be present.
 * @param index				The crash index, starts at 0 and goes up to Accelerator_GetUploadedCrashCount() - 1;
 * @param buffer			Buffer to store the crash HTTP response.
 * @param size				Size of the buffer parameter.
 * @error					Native called before Accelerator_IsDoneUploadingCrashes() returns true or invalid crash index passed.
 */
native void Accelerator_GetCrashHTTPResponse(int index, char[] buffer, int size);

/**
 * Returns a newline-separated list of pending local dumps.
 *
 * @param buffer			Buffer to store the dump list text.
 * @param size				Size of the buffer parameter.
 * @return					True on success, false on failure.
 * @error					Native error is thrown on failure.
 */
native bool Accelerator_LocalListDumps(char[] buffer, int size);

/**
 * Returns a newline-separated list of local processing jobs.
 *
 * @param buffer            Buffer to store the job list text.
 * @param size              Size of the buffer parameter.
 * @return                  True on success, false on failure.
 * @error                   Native error is thrown on failure.
 */
native bool Accelerator_LocalListJobs(char[] buffer, int size);

/**
 * Processes a local dump and writes output to a file.
 *
 * @param dumpName			Dump basename without .dmp.
 * @param mode				One of Trace/rawstack/rawmemory/rawraw/all.
 * @param requestedOutput	Output file name or empty string for default naming.
 * @param outputPath		Receives the resolved output path.
 * @param outputPathSize	Size of outputPath.
 * @param status			Receives a short success message.
 * @param statusSize		Size of status.
 * @return					True on success, false on failure.
 * @error					Native error is thrown on failure.
 */
native bool Accelerator_LocalProcessDump(const char[] dumpName, const char[] mode, const char[] requestedOutput, char[] outputPath, int outputPathSize, char[] status, int statusSize);

/**
 * Starts asynchronous processing of a local dump.
 *
 * @param dumpName          Dump basename without .dmp.
 * @param mode              One of Trace/rawstack/rawmemory/rawraw/all.
 * @param requestedOutput   Output file name or empty string for default naming.
 * @param jobId             Receives the created job id.
 * @param status            Receives a short queue message.
 * @param statusSize        Size of status.
 * @return                  True on success, false on failure.
 * @error                   Native error is thrown on failure.
 */
native bool Accelerator_LocalStartProcessDump(const char[] dumpName, const char[] mode, const char[] requestedOutput, int &jobId, char[] status, int statusSize);

/**
 * Gets the short stack trace for a local dump.
 *
 * @param dumpName			Dump basename without .dmp.
 * @param buffer			Buffer to store the stack trace.
 * @param size				Size of buffer.
 * @return					True on success, false on failure.
 * @error					Native error is thrown on failure.
 */
native bool Accelerator_LocalGetStackDump(const char[] dumpName, char[] buffer, int size);

/**
 * Starts asynchronous construction of the trace report for a local dump.
 *
 * @param dumpName          Dump basename without .dmp.
 * @param jobId             Receives the created job id.
 * @param status            Receives a short queue message.
 * @param statusSize        Size of status.
 * @return                  True on success, false on failure.
 * @error                   Native error is thrown on failure.
 */
native bool Accelerator_LocalStartStackDump(const char[] dumpName, int &jobId, char[] status, int statusSize);

/**
 * Gets the console history captured alongside a local dump.
 *
 * @param dumpName			Dump basename without .dmp.
 * @param buffer			Buffer to store the console history.
 * @param size				Size of buffer.
 * @return					True on success, false on failure.
 * @error					Native error is thrown on failure.
 */
native bool Accelerator_LocalGetConsoleDump(const char[] dumpName, char[] buffer, int size);

/**
 * Gets the current state of an asynchronous local dump job.
 *
 * @param jobId             Job id.
 * @param state             Receives queued/running/done/failed.
 * @param stateSize         Size of state.
 * @param status            Receives the current status or error.
 * @param statusSize        Size of status.
 * @param outputPath        Receives the resolved output path, if any.
 * @param outputPathSize    Size of outputPath.
 * @return                  True on success, false on failure.
 * @error                   Native error is thrown on failure.
 */
native bool Accelerator_LocalGetJobStatus(int jobId, char[] state, int stateSize, char[] status, int statusSize, char[] outputPath, int outputPathSize);

/**
 * Gets the final result text for a completed local dump job.
 *
 * @param jobId             Job id.
 * @param buffer            Buffer to store the result text.
 * @param size              Size of buffer.
 * @return                  True on success, false on failure.
 * @error                   Native error is thrown on failure.
 */
native bool Accelerator_LocalGetJobResult(int jobId, char[] buffer, int size);

/**
 * Intentionally crashes the server for dump testing.
 */
native void Accelerator_LocalCrashTest();

/**
 * Do not edit below this line!
 */
public Extension __ext_accelerator =
{
	name = "accelerator",
	file = "accelerator.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_EXTENSIONS
public __ext_accelerator_SetNTVOptional()
{
	MarkNativeAsOptional("Accelerator_GetUploadedCrashCount");
	MarkNativeAsOptional("Accelerator_IsDoneUploadingCrashes");
	MarkNativeAsOptional("Accelerator_GetCrashHTTPResponse");
	MarkNativeAsOptional("Accelerator_LocalListDumps");
	MarkNativeAsOptional("Accelerator_LocalListJobs");
	MarkNativeAsOptional("Accelerator_LocalProcessDump");
	MarkNativeAsOptional("Accelerator_LocalStartProcessDump");
	MarkNativeAsOptional("Accelerator_LocalGetStackDump");
	MarkNativeAsOptional("Accelerator_LocalStartStackDump");
	MarkNativeAsOptional("Accelerator_LocalGetConsoleDump");
	MarkNativeAsOptional("Accelerator_LocalGetJobStatus");
	MarkNativeAsOptional("Accelerator_LocalGetJobResult");
	MarkNativeAsOptional("Accelerator_LocalCrashTest");
}
#endif
