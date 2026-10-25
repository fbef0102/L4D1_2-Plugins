#if defined _SENDPROXYMANAGER_INC_
	#endinput
#endif
#define _SENDPROXYMANAGER_INC_

#define SENDPROXY_LIB "sendproxy2"

enum SendPropType
{
	Prop_Int,
	Prop_Float,
	Prop_String,
	Prop_Vector,
	Prop_EHandle,
	Prop_Max
};

/**
 * Callback for send proxy hooks.
 * 
 * @param entity		Index of the hooked entity.
 * @param prop			Name of the hooked send prop.
 * @param value			Prop value.
 * @param element		0 if the hooked prop is not an array,
 * 						otherwise an index into the array (starting from 0).
 * @param client		Index of the current processing client.
 * 
 * @return Action		Plugin_Changed to override value, otherwise ignored.
 */
typeset SendProxyCallback
{
	function Action (int entity, const char[] prop, int &value, int element, int client); //Prop_Int, Prop_EHandle
	function Action (int entity, const char[] prop, float &value, int element, int client); //Prop_Float
	function Action (int entity, const char[] prop, char[] value, int maxlength, int element, int client); //Prop_String
	function Action (int entity, const char[] prop, float value[3], int element, int client); //Prop_Vector
};

/**
 * Callback for gamerules send proxy hooks.
 * 
 * @param prop			Name of the hooked send prop.
 * @param value			Prop value.
 * @param element		0 if the hooked prop is NOT an array (InsideArray),
 * 						otherwise an index into the array (starting from 0).
 * @param client		Index of the current processing client.
 * 
 * @return Action		Plugin_Changed to override value, ignored otherwise.
 */
typeset SendProxyCallbackGamerules
{
	function Action (const char[] prop, int &value, int element, int client); //Prop_Int, Prop_EHandle
	function Action (const char[] prop, float &value, int element, int client); //Prop_Float
	function Action (const char[] prop, char[] value, int maxlength, int element, int client); //Prop_String
	function Action (const char[] prop, float value[3], int element, int client); //Prop_Vector
};

/**
 * Hook an entity's prop to override its value in callback without actually changing the prop.
 * @note Callback function cannot be checked so make sure it matches the prop type.
 * 
 * @param entity		Entity index to hook.
 * @param prop			Send prop name.
 * @param type			Prop type. Reports an error if type is mismatched.
 * @param callback		Callback function.
 * @param element		Element of the prop. Has no effect if the prop is NOT an array or a table.
 * 
 * @return bool			True if success, false if already hooked.
 */
native bool SendProxy_HookEntity(int entity, const char[] prop, SendPropType type, SendProxyCallback callback, int element = 0);
native bool SendProxy_HookGameRules(const char[] prop, SendPropType type, SendProxyCallbackGamerules callback, int element = 0);

/**
 * Unhook an entity's prop.
 * 
 * @param entity		Entity index to unhook.
 * @param prop			Send prop name.
 * @param callback		Callback function.
 * @param element		Element of the prop. Has no effect if the prop is NOT an array or a table.
 * 
 * @return bool			True if found, false otherwise.
 */
native bool SendProxy_UnhookEntity(int entity, const char[] prop, SendProxyCallback callback, int element = 0);
native bool SendProxy_UnhookGameRules(const char[] prop, SendProxyCallbackGamerules callback, int element = 0);

/**
 * Test if an entity's prop is hooked.
 * 
 * @param entity		Entity index to hook.
 * @param prop			Send prop name.
 * @param callback		Callback function.
 * @param element		Element of the prop. Has no effect if the prop is NOT an array or a table.
 * 
 * @return bool			True if hooked, false otherwise.
 */
native bool SendProxy_IsHookedEntity(int entity, const char[] prop, SendProxyCallback callback, int element = 0);
native bool SendProxy_IsHookedGameRules(const char[] prop, SendProxyCallbackGamerules callback, int element = 0);

public __ext_sendproxymanager_SetNTVOptional()
{
#if !defined REQUIRE_EXTENSIONS
    MarkNativeAsOptional("SendProxy_HookEntity");
    MarkNativeAsOptional("SendProxy_HookGameRules");
    MarkNativeAsOptional("SendProxy_UnhookEntity");
    MarkNativeAsOptional("SendProxy_UnhookGameRules");
    MarkNativeAsOptional("SendProxy_IsHookedEntity");
    MarkNativeAsOptional("SendProxy_IsHookedGameRules");
#endif  
}

public Extension __ext_sendproxymanager = 
{
	name = "SendProxy Manager",
	file = "sendproxy.ext",
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