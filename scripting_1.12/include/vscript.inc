#if defined _vscript_included
  #endinput
#endif
#define _vscript_included

#include <sdktools>
#include <dhooks>

// These field values does NOT reflect with actual game values, as it vaires between games.
// This should only be used with this plugin natives.
enum fieldtype_t
{
	FIELD_VOID,
	FIELD_FLOAT,
	FIELD_VECTOR,
	FIELD_INTEGER,
	FIELD_BOOLEAN,
	FIELD_TYPEUNKNOWN,
	FIELD_CSTRING,
	FIELD_HSCRIPT,
	FIELD_VARIANT,
	FIELD_QANGLE,
	FIELD_UINT32,
};

enum ScriptStatus_t
{
	SCRIPT_ERROR = -1,
	SCRIPT_DONE,
	SCRIPT_RUNNING,
};

methodmap Address {}

methodmap HSCRIPT < Address
{
	// Gets the key name by interator in hscript
	//
	// @param interator        Interator number, 0 for the first key.
	// @param buffer           Buffer to store name.
	// @param length           Size of buffer.
	// @param field            Field type value to store, FIELD_VOID if null.
	// @return                 Interator number to get next key, -1 if there is no more to interator through.
	public native int GetKey(int interator, char[] buffer, int length, fieldtype_t &field = FIELD_VOID);
	
	// Gets the field value from key
	//
	// @param key              Key name to get.
	// @return                 Value of the key.
	// @error                  Invalid key name or value is null.
	public native fieldtype_t GetValueField(const char[] key);
	
	// Gets the value from key
	//
	// @param key              Key name to get.
	// @return                 Value of the key.
	// @error                  Invalid key name or field usage.
	public native any GetValue(const char[] key);
	
	// Gets the string value from key
	//
	// @param key              Key name to get.
	// @param buffer           Buffer to store string.
	// @param length           Size of buffer.
	// @error                  Invalid key name or field usage.
	public native void GetValueString(const char[] key, char[] buffer, int length);
	
	// Gets the vector value from key
	//
	// @param key              Key name to get.
	// @param buffer           Buffer to store vector.
	// @error                  Invalid key name or field usage.
	public native void GetValueVector(const char[] key, float buffer[3]);
	
	// Returns whenever key value is null
	//
	// @param key              Key name to test.
	// @return                 True is value is null, false otherwise.
	// @error                  Invalid key name.
	public native bool IsValueNull(const char[] key);
	
	// Sets a value to key
	//
	// @param key              Key name to set.
	// @param field            Field to use to set.
	// @param value            Value to set.
	public native void SetValue(const char[] key, fieldtype_t field, any value);
	
	// Sets a string value to key
	//
	// @param key              Key name to set.
	// @param field            Field to use to set.
	// @param value            String value to set.
	public native void SetValueString(const char[] key, fieldtype_t field, const char[] value);
	
	// Sets a vector value to key
	//
	// @param key              Key name to set.
	// @param field            Field to use to set.
	// @param value            Vector value to set.
	public native void SetValueVector(const char[] key, fieldtype_t field, const float value[3]);
	
	// Sets a null value to key
	//
	// @param key              Key name to set.
	public native void SetValueNull(const char[] key);
	
	// Returns whenever key name exists, key with null value returns true
	//
	// @param key              Key name to test.
	// @return                 True if key exists, false otherwise.
	public native bool ValueExists(const char[] key);
	
	// Clears a key and it's value
	//
	// @param key              Key name to clear.
	public native void ClearValue(const char[] key);
	
	// Get the address of instance
	property Address Instance
	{
		public native get();
	}
	
	// Frees a HSCRIPT memory
	public native void Release();

	// Frees a HSCRIPT memory. This is only used for script scopes.
	public native void ReleaseScope();

	// Frees a HSCRIPT memory. This is only used for compiled scripts.
	public native void ReleaseScript();
}

// Several functions accept null HScript as g_pScriptVM for root table
const HSCRIPT HSCRIPT_RootTable = view_as<HSCRIPT>(0);

methodmap VScriptFunction < Address
{
	// Gets the script name
	// 
	// @param buffer           Buffer to store name.
	// @param length           Size of buffer.
	public native void GetScriptName(char[] buffer, int length);
	
	// Sets a script name
	// 
	// @param value            Name to set.
	public native void SetScriptName(const char[] value);
	
	// Gets the function name, this is only for display purpose
	// 
	// @param buffer           Buffer to store name.
	// @param length           Size of buffer.
	public native void GetFunctionName(char[] buffer, int length);
	
	// Sets a function name, this is only for display purpose
	// 
	// @param value            Name to set.
	public native void SetFunctionName(const char[] value);
	
	// Gets the description
	// 
	// @param buffer           Buffer to store name.
	// @param length           Size of buffer.
	public native void GetDescription(char[] buffer, int length);
	
	// Sets the description
	// 
	// @param value            Description to set.
	public native void SetDescription(const char[] value);
	
	// Gets the address of the binding
	// Binding gets automatically updated when SetFunctionEmpty is called when possible.
	property Address Binding
	{
		public native get();
	}
	
	// Gets/Sets the address of the function
	property Address Function
	{
		public native get();
		public native set(Address func);
	}
	
	// Gets the offset of a virtual function from class, -1 if function is not a virtual
	property int Offset
	{
		public native get();
	}
	
	// Set the function as empty, doing nothing. This is used when wanting to create a new function only to be used for detour.
	// This MUST be used after return and params has been set. If return is not void, 0 or null is returned by default.
	public native void SetFunctionEmpty();
	
	// Gets/Sets the return field type
	property fieldtype_t Return
	{
		public native get();
		public native set(fieldtype_t field);
	}
	
	// Gets amount of parameters function has
	property int ParamCount
	{
		public native get();
	}
	
	// Gets the field type of a parameter
	// 
	// @param param            Parameter number, starting from 1.
	// @return                 Field type of a parameter.
	// @error                  Parameter number out of range.
	public native fieldtype_t GetParam(int param);
	
	// Sets the field type of a parameter, creating any new param values when needed, initialized as FIELD_VOID
	// 
	// @param param            Parameter number, starting from 1.
	// @param field            Field type to set.
	public native void SetParam(int param, fieldtype_t field);
	
	// Copy all datas from another function
	// 
	// @param from             A function to copy from.
	public native void CopyFrom(VScriptFunction from);
	
	// Register this as a global function until when g_pScriptVM has been reset. This should be called inside VScript_OnScriptVMInitialized forward.
	public native void Register();
	
	// Creates an SDKCall with parameters auto filled
	// 
	// @return                 SDKCall handle, must be deleted when not needed.
	public native Handle CreateSDKCall();
	
	// Creates a detour handle from DynamicDetour with parameters auto filled
	// 
	// @return                 DynamicDetour handle, must be deleted when not needed.
	public native DynamicDetour CreateDetour();
	
	// Creates a hook handle from DynamicHook with parameters auto filled
	// 
	// @return                 DynamicHook handle, must be deleted when not needed. Returns null if function is not a virtual.
	public native DynamicHook CreateHook();
	
	// Gets the class that this function is associated to it, Address_Null if global function
	property VScriptClass Class
	{
		public native get();
	}
}

methodmap VScriptClass < Address
{
	// Gets the script name
	// 
	// @param buffer           Buffer to store script name.
	// @param length           Size of buffer.
	public native void GetScriptName(char[] buffer, int length);
	
	// Sets the script name
	// 
	// @param value            Script name to set.
	public native void SetScriptName(const char[] value);
	
	// Gets the class name
	// 
	// @param buffer           Buffer to store class name.
	// @param length           Size of buffer.
	public native void GetClassName(char[] buffer, int length);
	
	// Sets the class name
	// 
	// @param value            Class name to set.
	public native void SetClassName(const char[] value);
	
	// Gets the description
	// 
	// @param buffer           Buffer to store name.
	// @param length           Size of buffer.
	public native void GetDescription(char[] buffer, int length);
	
	// Sets the description
	// 
	// @param value            Description to set.
	public native void SetDescription(const char[] value);
	
	// Get all of the functions used for this class
	// 
	// @return                 Arrays of VScriptFunction, handle must be deleted when not needed.
	public native ArrayList GetAllFunctions();
	
	// Gets VScriptFunction from this class
	// 
	// @param functionName     Function name.
	// @return                 Address of VScriptFunction, null if does not exist.
	public native VScriptFunction GetFunction(const char[] functionName);
	
	// Creates a new VScriptFunction connected from this class. Function will need to be filled in then call VScript_ResetScriptVM
	// 
	// @param functionName     Function name.
	// @return                 Address of VScriptFunction.
	public native VScriptFunction CreateFunction();
	
	// Register this class as an instance. This should be used inside VScript_OnScriptVMInitialized forward.
	// 
	// @param instance         Name of an instance in script.
	// @return                 Created HSCRIPT instance.
	public native HSCRIPT RegisterInstance(const char[] instance);
	
	// Gets the class that this is based on, Address_Null if does not have base class
	property VScriptClass Base
	{
		public native get();
	}
	
	// Return whenever if this class function is derived from other class base
	// 
	// @param base             Function base to find if derived at.
	// @return                 True if derived from, false otherwise.
	public bool IsDerivedFrom(VScriptClass base)
	{
		while (base)
		{
			if (this == base)
				return true;
			
			base = base.Base;
		}
		
		return false;
	}
	
}

methodmap VScriptExecute < Handle
{
	// Creates a new handle to execute a script function
	// 
	// @param script           Script address to execute.
	// @param scope            The script scope to execute the script inside of.
	public native VScriptExecute(HSCRIPT script, HSCRIPT scope = HSCRIPT_RootTable);
	
	// Adds a new parameter at the end
	// 
	// @param type             Type of field to set.
	// @param value            Value to set.
	public native void AddParam(fieldtype_t type, any value);
	
	// Adds a new string parameter at the end
	// 
	// @param type             Type of field to set.
	// @param value            String value to set.
	public native void AddParamString(fieldtype_t type, const char[] value);
	
	// Adds a new vector parameter at the end
	// 
	// @param type             Type of field to set.
	// @param value            Vector value to set.
	public native void AddParamVector(fieldtype_t type, const float value[3]);
	
	// Sets a given parameter with value
	// 
	// @param param            Parameter to set.
	// @param type             Type of field to set.
	// @param value            Value to set.
	public native void SetParam(int param, fieldtype_t type, any value);
	
	// Sets a given parameter with string value
	// 
	// @param param            Parameter to set.
	// @param type             Type of field to set.
	// @param value            String value to set.
	public native void SetParamString(int param, fieldtype_t type, const char[] value);
	
	// Sets a given parameter with vector value
	// 
	// @param param            Parameter to set.
	// @param type             Type of field to set.
	// @param value            Vector value to set.
	public native void SetParamVector(int param, fieldtype_t type, const float value[3]);
	
	// Executes a function
	//
	// @return                 Script status after executed.
	public native ScriptStatus_t Execute();
	
	// Gets return field type, FIELD_VOID if null
	property fieldtype_t ReturnType
	{
		public native get();
	}
	
	// Gets return value
	property any ReturnValue
	{
		public native get();
	}
	
	// Gets a return string value
	// 
	// @param buffer           Buffer to store string.
	// @param length           Size of buffer.
	public native void GetReturnString(char[] buffer, int length);
	
	// Gets a return vector value
	// 
	// @param buffer           Buffer to store vector.
	// @param length           Size of buffer.
	public native void GetReturnVector(float buffer[3]);
}


/**
 * Called when g_pScriptVM has been fully initialized, this is where VScriptClass.RegisterInstance and VScriptFunction.Register should be called
 * @note This forward does not get called on plugin lateload, use VScript_IsScriptVMInitialized to determine whenever to manually call this forward
 */
forward void VScript_OnScriptVMInitialized();

/**
 * Returns whenever g_pScriptVM has been initialized, useful for plugin start to determine whenever to call VScript_ResetScriptVM or VScript_OnScriptVMInitialized if this were to return true
 * 
 * @return                 True if script vm is initialized, false otherwise
 */
native bool VScript_IsScriptVMInitialized();

/**
 * Deletes g_pScriptVM and creates a new one. This should be used when VScriptClass or VScriptFunction has been modified, including adding new functions to class
 */
native void VScript_ResetScriptVM();

/**
 * Compiles a script.
 * 
 * @param script           Script to compile
 * @param id               Optional ID to set
 * 
 * @return                 HSCRIPT of script, null if could not compile. This MUST be freed when not in use by using HSCRIPT.ReleaseScript().
 */
native HSCRIPT VScript_CompileScript(const char[] script, const char[] id = NULL_STRING);

/**
 * Compiles a script file.
 * 
 * @param filepath         Filepath to get a script, 'scripts/vscripts/' are automatically added to the filepath
 * 
 * @return                 HSCRIPT of script, null if could not compile. This MUST be freed when not in use by using HSCRIPT.ReleaseScript().
 * @error                  Invalid filepath.
 */
native HSCRIPT VScript_CompileScriptFile(const char[] filepath);

/**
 * Creates a new HSCRIPT scope, it MUST be deleted when no longer needed by using HSCRIPT.ReleaseScope()
 * 
 * @param name             Name to set the scope
 * @param parent           Parent of the HSCRIPT to set as
 * 
 * @return                 HSCRIPT of scope.
 */
native HSCRIPT VScript_CreateScope(const char[] name, HSCRIPT parent = HSCRIPT_RootTable);

/**
 * Creates a new HSCRIPT table, it MUST be deleted when no longer needed by using HSCRIPT.Release()
 * 
 * @return                 HSCRIPT of table.
 */
native HSCRIPT VScript_CreateTable();

/**
 * Creates a new HSCRIPT instance, this is only to be used on non-entity script class that needs it's script instance created
 * @note You may need to manually set property to an instance to point where the newly created hscript are at
 *
 * @param class            Script class an instance uses
 * @param instance         Instance pointer address to use
 * 
 * @return                 HSCRIPT of an instance, null if could not create one.
 */
native HSCRIPT VScript_CreateInstance(VScriptClass class, Address instance);

/**
 * Get all the classes used for vscript
 * 
 * @return                 Arrays of VScriptClass, handle must be deleted when not needed.
 */
native ArrayList VScript_GetAllClasses();

/**
 * Gets VScriptClass from class
 * 
 * @param className        Class name.
 * 
 * @return                 Address of VScriptClass
 * @error                  Invalid class name
 */
native VScriptClass VScript_GetClass(const char[] className);

/**
 * Gets VScriptClass from class or creates one if don't exist. VScriptClass.RegisterInstance must be called after params are filled.
 * 
 * @param className        Class name.
 * 
 * @return                 Address of VScriptClass, either existing or newly created
 */
native VScriptClass VScript_CreateClass(const char[] className);

/**
 * Gets VScriptFunction from class
 * 
 * @param className        Class name.
 * @param functionName     Function name.
 * 
 * @return                 Address of VScriptFunction, null if class does not have one
 * @error                  Invalid class name
 */
native VScriptFunction VScript_GetClassFunction(const char[] className, const char[] functionName);

/**
 * Get all global functions used for vscript
 * 
 * @return                 Arrays of VScriptFunction, handle must be deleted when not needed.
 */
native ArrayList VScript_GetAllGlobalFunctions();

/**
 * Gets VScriptFunction from a global
 * 
 * @param functionName     Function name.
 * 
 * @return                 Address of VScriptFunction
 */
native VScriptFunction VScript_GetGlobalFunction(const char[] functionName);

/**
 * Creates a new VScriptFunction as a pointer. VScriptFunction.Register should be called for function to come into effect.
 * 
 * @return                 Address of VScriptFunction
 */
native VScriptFunction VScript_CreateFunction();

/**
 * Gets the script scope of an entity
 * 
 * @param entity           Entity index.
 * 
 * @return                 Address of the HScript scope
 * @error                  Invalid entity
 */
native HSCRIPT VScript_GetEntityScriptScope(int entity);

/**
 * Gets the HScript address of an entity
 * 
 * @param entity           Entity index.
 * 
 * @return                 Address of the HScript
 * @error                  Invalid entity
 */
native HSCRIPT VScript_EntityToHScript(int entity);

/**
 * Gets the entity index from HScript address
 * 
 * @param hscript          HScript address.
 * 
 * @return                 Entity index
 */
native int VScript_HScriptToEntity(HSCRIPT hscript);

/**
 * Gets VScriptFunction from class or creates one if don't exist
 *
 * @param className        Class name.
 * @param functionName     Function name.
 * 
 * @return                 Address of VScriptFunction, either existing or newly created
 * @error                  Invalid class name
 */
stock VScriptFunction VScript_CreateClassFunction(const char[] className, const char[] functionName)
{
	VScriptFunction func = VScript_GetClassFunction(className, functionName);
	if (func)
		return func;
	
	VScriptClass class = VScript_GetClass(className);
	func = class.CreateFunction();
	func.SetScriptName(functionName);
	return func;
}

/**
 * Gets VScriptFunction from global or creates one if don't exist
 * 
 * @param functionName     Function name.
 * 
 * @return                 Address of VScriptFunction, either existing or newly created
 */
stock VScriptFunction VScript_CreateGlobalFunction(const char[] functionName)
{
	VScriptFunction func = VScript_GetGlobalFunction(functionName);
	if (func)
		return func;
	
	func = VScript_CreateFunction();
	func.SetScriptName(functionName);
	return func;
}

/**
 * Returns the value of a constant
 * 
 * @param table            Enum or bitfield name to get.
 * @param name             Value name to get.
 * 
 * @return                 Value of the enum key.
 * @error                  Invalid enum, bitfield or value name to get.
 */
stock any VScript_GetConstantsValue(const char[] table, const char[] name)
{
	HSCRIPT constants = HSCRIPT_RootTable.GetValue("Constants");
	HSCRIPT keys = constants.GetValue(table);
	return keys.GetValue(name);
}

public SharedPlugin __pl_vscript =
{
	name = "vscript",
	file = "vscript.smx",
	#if defined REQUIRE_PLUGIN
		required = 1,
	#else
		required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_vscript_SetNTVOptional()
{
	MarkNativeAsOptional("HSCRIPT.GetKey");
	MarkNativeAsOptional("HSCRIPT.GetValueField");
	MarkNativeAsOptional("HSCRIPT.GetValue");
	MarkNativeAsOptional("HSCRIPT.GetValueString");
	MarkNativeAsOptional("HSCRIPT.GetValueVector");
	MarkNativeAsOptional("HSCRIPT.IsValueNull");
	MarkNativeAsOptional("HSCRIPT.SetValue");
	MarkNativeAsOptional("HSCRIPT.SetValueString");
	MarkNativeAsOptional("HSCRIPT.SetValueVector");
	MarkNativeAsOptional("HSCRIPT.SetValueNull");
	MarkNativeAsOptional("HSCRIPT.ValueExists");
	MarkNativeAsOptional("HSCRIPT.ClearValue");
	MarkNativeAsOptional("HSCRIPT.Instance.get");
	MarkNativeAsOptional("HSCRIPT.Release");
	MarkNativeAsOptional("HSCRIPT.ReleaseScope");
	MarkNativeAsOptional("HSCRIPT.ReleaseScript");
	
	MarkNativeAsOptional("VScriptFunction.GetScriptName");
	MarkNativeAsOptional("VScriptFunction.SetScriptName");
	MarkNativeAsOptional("VScriptFunction.GetFunctionName");
	MarkNativeAsOptional("VScriptFunction.SetFunctionName");
	MarkNativeAsOptional("VScriptFunction.GetDescription");
	MarkNativeAsOptional("VScriptFunction.SetDescription");
	MarkNativeAsOptional("VScriptFunction.Binding.get");
	MarkNativeAsOptional("VScriptFunction.Function.get");
	MarkNativeAsOptional("VScriptFunction.Function.set");
	MarkNativeAsOptional("VScriptFunction.Offset.get");
	MarkNativeAsOptional("VScriptFunction.SetFunctionEmpty");
	MarkNativeAsOptional("VScriptFunction.Return.get");
	MarkNativeAsOptional("VScriptFunction.Return.set");
	MarkNativeAsOptional("VScriptFunction.ParamCount.get");
	MarkNativeAsOptional("VScriptFunction.GetParam");
	MarkNativeAsOptional("VScriptFunction.SetParam");
	MarkNativeAsOptional("VScriptFunction.CopyFrom");
	MarkNativeAsOptional("VScriptFunction.Register");
	MarkNativeAsOptional("VScriptFunction.CreateSDKCall");
	MarkNativeAsOptional("VScriptFunction.CreateDetour");
	MarkNativeAsOptional("VScriptFunction.CreateHook");
	MarkNativeAsOptional("VScriptFunction.Class.get");
	
	MarkNativeAsOptional("VScriptClass.GetScriptName");
	MarkNativeAsOptional("VScriptClass.SetScriptName");
	MarkNativeAsOptional("VScriptClass.GetClassName");
	MarkNativeAsOptional("VScriptClass.SetClassName");
	MarkNativeAsOptional("VScriptClass.GetDescription");
	MarkNativeAsOptional("VScriptClass.SetDescription");
	MarkNativeAsOptional("VScriptClass.GetAllFunctions");
	MarkNativeAsOptional("VScriptClass.GetFunction");
	MarkNativeAsOptional("VScriptClass.CreateFunction");
	MarkNativeAsOptional("VScriptClass.RegisterInstance");
	MarkNativeAsOptional("VScriptClass.Base.get");
	
	MarkNativeAsOptional("VScriptExecute.VScriptExecute");
	MarkNativeAsOptional("VScriptExecute.AddParam");
	MarkNativeAsOptional("VScriptExecute.AddParamString");
	MarkNativeAsOptional("VScriptExecute.AddParamVector");
	MarkNativeAsOptional("VScriptExecute.SetParam");
	MarkNativeAsOptional("VScriptExecute.SetParamString");
	MarkNativeAsOptional("VScriptExecute.SetParamVector");
	MarkNativeAsOptional("VScriptExecute.Execute");
	MarkNativeAsOptional("VScriptExecute.ReturnType.get");
	MarkNativeAsOptional("VScriptExecute.ReturnValue.get");
	MarkNativeAsOptional("VScriptExecute.GetReturnString");
	MarkNativeAsOptional("VScriptExecute.GetReturnVector");
	
	MarkNativeAsOptional("VScript_IsScriptVMInitialized");
	MarkNativeAsOptional("VScript_ResetScriptVM");
	MarkNativeAsOptional("VScript_CompileScript");
	MarkNativeAsOptional("VScript_CompileScriptFile");
	MarkNativeAsOptional("VScript_CreateScope");
	MarkNativeAsOptional("VScript_CreateTable");
	MarkNativeAsOptional("VScript_CreateInstance");
	MarkNativeAsOptional("VScript_GetAllClasses");
	MarkNativeAsOptional("VScript_GetClass");
	MarkNativeAsOptional("VScript_CreateClass");
	MarkNativeAsOptional("VScript_GetClassFunction");
	MarkNativeAsOptional("VScript_GetAllGlobalFunctions");
	MarkNativeAsOptional("VScript_GetGlobalFunction");
	MarkNativeAsOptional("VScript_CreateFunction");
	MarkNativeAsOptional("VScript_GetEntityScriptScope");
	MarkNativeAsOptional("VScript_EntityToHScript");
	MarkNativeAsOptional("VScript_HScriptToEntity");
}
#endif
