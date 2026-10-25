#if defined _hacks_included
 #endinput
#endif
#define _hacks_included

#include <core>

// Version: 1.3.0.0

#define Hacks_Continue -54321

enum Hacks_HookType
{
	HACKS_HTYPE_SPAWN=0,
	HACKS_HTYPE_TRACEATTACK,
	HACKS_HTYPE_ONTAKEDAMAGE,
	HACKS_HTYPE_EVENT_KILLED,
	HACKS_HTYPE_STARTTOUCH,
	HACKS_HTYPE_TOUCH,
	HACKS_HTYPE_ENDTOUCH,
	HACKS_HTYPE_UPDATEONREMOVE,
	HACKS_HTYPE_WEAPON_CANUSE,
	HACKS_HTYPE_WEAPON_DROP,
	HACKS_HTYPE_WEAPON_CANSWITCHTO,
	HACKS_HTYPE_COMMITSUICIDE,
	HACKS_HTYPE_IMPULSECOMMANDS,
	HACKS_HTYPE_PLAYERRUNCOMMAND
};

enum Hacks_CallType
{
	HACKS_CTYPE_ENTITY=0,
	HACKS_CTYPE_COLLISIONPROP,
	HACKS_CTYPE_PHYSICSOBJECT,
	HACKS_CTYPE_EVENTQUEUE,
	HACKS_CTYPE_GAMERULES
};

enum Hacks_ReturnType
{
	HACKS_RTYPE_VOID=0,
	HACKS_RTYPE_INT,
	HACKS_RTYPE_FLOAT,
	HACKS_RTYPE_EDICT,
	HACKS_RTYPE_ENTITY
};

enum Hacks_Param
{
	HACKS_PARAM_NULL=0,
	HACKS_PARAM_INT,
	HACKS_PARAM_FLOAT,
	HACKS_PARAM_STRING,
	HACKS_PARAM_VECTOR,		// Pointer
	HACKS_PARAM_QANGLE,		// Pointer
	HACKS_PARAM_EDICT,
	HACKS_PARAM_ENTITY,
	HACKS_PARAM_PHYSICSOBJECT
};


/**
 * Callback for a hooked function.
 *
 * @param entity			Index of the entity that was hooked.
 * @param arg1
 * @param arg2
 * @param arg3
 * @param arg4
 * @param arg5
 * @return					Hacks_Continue, other = Supercede the
 *        					   function and return the value.
 */
typedef Hacks_HookFunc = function Action (int entity, int arg1, int arg2, int arg3, int arg4, int arg5);

/**
 * Hooks a virtual function.
 *
 * @param entity			Index of the entity.
 * @param type				Type of the function, see Hacks_HookType.
 * @param handler			Your function that will be called on hooking.
 * @param post				True for post operation, false for pre operation.
 * @return					HookID, that's needed to unhook.
 */
native Hacks_Hook(entity, Hacks_HookType:type, Hacks_HookFunc:func, bool:post=false);

/**
 * Unhooks a virtual function.
 *
 * @param hookid			The returned hookid from Hacks_Hook.
 * @noreturn
 */
native Hacks_Unhook(hookid);

/**
 * Scans for a function in the memory.
 *
 * @param name				Name of the function (e.g. "CBaseAnimating::Ignite").
 * @param signature			Signature to scan for (Windows). 2A = wildcard
 *							 (e.g. "56 8B 74 24 0C 83 FE FF 57 8B 7C 24 0C 74 25 8B")
 * @param symbol			Symbol to scan for (Linux).
 * @return					CallID, that's needed to call the function.
 */
native Hacks_Find(const String:name[], const String:signature[], const String:symbol[]);

/**
 * Calls a previously scanned function.
 *
 * @param entity			Index of the entity.
 * @param callid			The returned callid from Hacks_Find.
 * @param calltype			Type to call, see Hacks_CallType.
 * @param returntype		Return type, see Hacks_ReturnType.
 * @param[x] argtype		Datatype of argument, see Hacks_Param.
 * @param[y] arg			Argument for function.
 * @return					If there was a failure in the function, it will return -1,
 *							 otherwise see Hacks_ReturnType.
 */
native Hacks_Call(entity, callid, Hacks_CallType:calltype, Hacks_ReturnType:returntype, any:...);

/**
 * Calls a virtual function by its offset.
 *
 * @param entity			Index of the entity.
 * @param windows			Windows offset.
 * @param linux				Linux offset.
 * @param calltype			Type to call, see Hacks_CallType.
 * @param returntype		Return type, see  Hacks_ReturnType.
 * @param[x] argtype		Datatype of argument, see Hacks_Param.
 * @param[y] arg			Argument for function.
 * @return					If there was a failure in the function, it will return -1,
 *							 otherwise see Hacks_ReturnType.
 */
native Hacks_Call_Offset(entity, windows, linux, Hacks_CallType:calltype, Hacks_ReturnType:returntype, any:...);

/**
 * Calls a previously scanned function, but without an entity.
 *
 * @param callid			The returned callid from Hacks_Find.
 * @param returntype		Return type, see Hacks_ReturnType.
 * @param[x] argtype		Datatype of argument, see Hacks_Param.
 * @param[y] arg			Argument for function.
 * @return					If there was a failure in the function, it will return -1,
 *							 otherwise see Hacks_ReturnType.
 */
native Hacks_Call_NoEntity(callid, Hacks_ReturnType:returntype, any:...);

/**
 * Adds a file to be force downloaded (cleared every map change).
 *
 * @param ...				Each argument = One file that will be added.
 * @noreturn
 */
native Hacks_AddDownload(const String:...);

/**
 * Creates a patch that you can use with Hacks_Patch/Hacks_Unpatch
 *
 * @param callid			The returned callid from Hacks_Find.
 * @param windows_bytes		New Bytes (eg "C2 08 00")
 * @param windows_offset	Offset (addr to patch = func_addr + offset)
 * @param linux_bytes
 * @param linux_offset
 * @return					PatchID, that's needed to patch/unpatch.
 */
native Hacks_CreatePatch(callid, const String:windows_bytes[], windows_offset, const String:linux_bytes[], linux_offset);

/**
 * Writes new bytes to a given address
 *
 * @param patchid			The returned patchid from Hacks_CreatePatch.
 * @noreturn
 */
native Hacks_Patch(patchid);

/**
 * Writes the original bytes to a given address
 *
 * @param patchid			The returned patchid from Hacks_CreatePatch.
 * @noreturn
 */
native Hacks_Unpatch(patchid);

/**
 * Do not edit below this line!
 */
public Extension:__ext_hacks =
{
	name = "Hacks Extension",
	file = "hacks.ext",
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