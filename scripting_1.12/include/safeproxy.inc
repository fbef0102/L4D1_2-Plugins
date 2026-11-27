#if defined _safeproxy_included
	#endinput
#endif
#define _safeproxy_included

// ============================================================================
// Constants
// ============================================================================

/**
 * The all-clients recipient.
 * A client's own prop overrides apply on top of it, and a client's own transmit states replace it.
 */
#define SAFEPROXY_ALL_CLIENTS  -2

// ============================================================================
// Enums
// ============================================================================

/**
 * Transmit states.
 */
enum SafeProxyTransmit
{
	SafeProxyTransmit_Normal = 0,        /**< The game decides as usual */
	SafeProxyTransmit_Hide,              /**< Not sent, along with everything parented to it */
	SafeProxyTransmit_Force,             /**< Sent, along with its moveparent ancestors */
	SafeProxyTransmit_ForceWithChildren, /**< As Force, and also sends everything parented to it that has no override of its own */
};

/**
 * Prop types.
 */
enum SafeProxyPropType
{
	SafeProxyPropType_Unsupported = 0,
	SafeProxyPropType_Int,
	SafeProxyPropType_Float,
	SafeProxyPropType_Vector,
	SafeProxyPropType_String,
	SafeProxyPropType_Ent,
	SafeProxyPropType_Color,
};

// ============================================================================
// Prop overrides
// ============================================================================

/**
 * Overrides an int SendProp for a recipient.
 * Each plugin has one layer per prop, element and recipient, and the most recently changed layer wins.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param value     Value to send instead of the real one.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           Invalid entity, recipient or element, disconnected recipient, unknown or unsupported prop, prop of another type, or called while entities are being encoded.
 *
 * @note            SourceTV and Replay ignore prop overrides.
 */
native void SafeProxy_SetProp(int entity, const char[] prop, int value, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides a float SendProp for a recipient.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param value     Value to send instead of the real one.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetProp.
 */
native void SafeProxy_SetPropFloat(int entity, const char[] prop, float value, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides a vector SendProp for a recipient.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param value     Vector to send instead of the real one.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetProp.
 */
native void SafeProxy_SetPropVector(int entity, const char[] prop, const float value[3], int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides a string SendProp for a recipient.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param value     String to send instead of the real one.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetProp.
 */
native void SafeProxy_SetPropString(int entity, const char[] prop, const char[] value, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides an entity handle SendProp for a recipient.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param other     Networked entity index or reference to send, or -1 for a null handle.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetProp, or an invalid or non-networked target.
 */
native void SafeProxy_SetPropEnt(int entity, const char[] prop, int other, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides a color SendProp for a recipient.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param rgba      Red, green, blue and alpha, each 0..255.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetProp, or a channel out of range.
 */
native void SafeProxy_SetPropColor(int entity, const char[] prop, const int rgba[4], int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Makes a client receive a prop's real value despite all-clients overrides and the client's earlier ones.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param recipient Client index.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetProp, or SAFEPROXY_ALL_CLIENTS as the recipient.
 */
native void SafeProxy_SetPropReal(int entity, const char[] prop, int recipient, int element = 0);

/**
 * Overrides only the masked bits of an int SendProp for a recipient.
 * Other bits keep the calling plugin's earlier values, but a callback or SafeProxy_SetPropReal layer is replaced.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param bits      Values for the masked bits.
 * @param mask      Which bits to override.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetProp.
 */
native void SafeProxy_SetPropBits(int entity, const char[] prop, int bits, int mask, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Gets which setters and getters a prop takes.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param element   Element index for array props.
 * @param error     Buffer to store why the prop is unsupported.
 * @param maxlen    Maximum length of the error buffer.
 * @return          The prop's type, or SafeProxyPropType_Unsupported.
 * @error           Invalid entity.
 */
native SafeProxyPropType SafeProxy_GetPropType(int entity, const char[] prop, int element = 0, char[] error = "", int maxlen = 0);

/**
 * Returns whether a recipient is sent an overridden value for a prop of any type.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @return          True if any plugin's layers override the value.
 * @error           Invalid entity, recipient or element, or unknown or unsupported prop.
 */
native bool SafeProxy_HasProp(int entity, const char[] prop, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Gets the overridden value of an int SendProp.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param value     Receives the value the recipient is sent.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @return          True if any plugin's layers override the value.
 * @error           Invalid entity, recipient or element, unknown or unsupported prop, or prop of another type.
 */
native bool SafeProxy_GetProp(int entity, const char[] prop, int &value, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Gets the overridden value of a float SendProp.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param value     Receives the value the recipient is sent.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @return          True if any plugin's layers override the value.
 * @error           As SafeProxy_GetProp.
 */
native bool SafeProxy_GetPropFloat(int entity, const char[] prop, float &value, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Gets the overridden value of a vector SendProp.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param value     Receives the vector the recipient is sent.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @return          True if any plugin's layers override the value.
 * @error           As SafeProxy_GetProp.
 */
native bool SafeProxy_GetPropVector(int entity, const char[] prop, float value[3], int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Gets the overridden value of a string SendProp.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param buffer    Buffer to store the string the recipient is sent.
 * @param maxlen    Maximum length of the buffer.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @return          True if any plugin's layers override the value.
 * @error           As SafeProxy_GetProp.
 */
native bool SafeProxy_GetPropString(int entity, const char[] prop, char[] buffer, int maxlen, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Gets the overridden value of an entity handle SendProp.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param other     Receives the entity index the recipient is sent, or -1 for a null handle or removed entity.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @return          True if any plugin's layers override the value.
 * @error           As SafeProxy_GetProp.
 */
native bool SafeProxy_GetPropEnt(int entity, const char[] prop, int &other, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Gets the overridden value of a color SendProp.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param rgba      Receives the red, green, blue and alpha the recipient is sent.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @return          True if any plugin's layers override the value.
 * @error           As SafeProxy_GetProp.
 */
native bool SafeProxy_GetPropColor(int entity, const char[] prop, int rgba[4], int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Gets which bits of an int SendProp are overridden.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param bits      Receives the overridden bits.
 * @param mask      Receives which bits are overridden.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @return          True if any plugin's layers override any bit.
 * @error           As SafeProxy_GetProp.
 */
native bool SafeProxy_GetPropBits(int entity, const char[] prop, int &bits, int &mask, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Removes the calling plugin's layer for a prop and recipient.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @return          True if the calling plugin had a layer to remove.
 * @error           Invalid recipient or element, unknown or unsupported prop, or called while entities are being encoded.
 */
native bool SafeProxy_UnsetProp(int entity, const char[] prop, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Stops the calling plugin's layer from overriding the masked bits of an int SendProp for a recipient.
 * The layer keeps its precedence, and is removed once it overrides no bits.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param mask      Which bits to stop overriding.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @return          True if the calling plugin's layer overrode any of the masked bits.
 * @error           As SafeProxy_UnsetProp, or prop of another type.
 */
native bool SafeProxy_UnsetPropBits(int entity, const char[] prop, int mask, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

// ============================================================================
// Prop callbacks
// ============================================================================

/**
 * Supplies an int prop's value for a client.
 *
 * @param entity    Entity index.
 * @param prop      SendProp name the callback was set with.
 * @param value     The real value.
 * @param client    Client index the value is for.
 * @param element   Element index the callback was set with.
 * @return          Plugin_Changed to send value, or anything else to leave this layer out.
 */
typedef SafeProxyCallback = function Action (int entity, const char[] prop, int &value, int client, int element);

/**
 * Supplies a float prop's value for a client.
 *
 * @param entity    Entity index.
 * @param prop      SendProp name the callback was set with.
 * @param value     The real value.
 * @param client    Client index the value is for.
 * @param element   Element index the callback was set with.
 * @return          Plugin_Changed to send value, or anything else to leave this layer out.
 */
typedef SafeProxyCallbackFloat = function Action (int entity, const char[] prop, float &value, int client, int element);

/**
 * Supplies a vector prop's value for a client.
 *
 * @param entity    Entity index.
 * @param prop      SendProp name the callback was set with.
 * @param value     The real vector.
 * @param client    Client index the value is for.
 * @param element   Element index the callback was set with.
 * @return          Plugin_Changed to send value, or anything else to leave this layer out.
 */
typedef SafeProxyCallbackVector = function Action (int entity, const char[] prop, float value[3], int client, int element);

/**
 * Supplies a string prop's value for a client.
 *
 * @param entity    Entity index.
 * @param prop      SendProp name the callback was set with.
 * @param value     The real string.
 * @param maxlen    Maximum length of the value buffer.
 * @param client    Client index the value is for.
 * @param element   Element index the callback was set with.
 * @return          Plugin_Changed to send value, or anything else to leave this layer out.
 */
typedef SafeProxyCallbackString = function Action (int entity, const char[] prop, char[] value, int maxlen, int client, int element);

/**
 * Supplies an entity handle prop's value for a client.
 *
 * @param entity    Entity index.
 * @param prop      SendProp name the callback was set with.
 * @param other     The real entity index, or -1.
 * @param client    Client index the value is for.
 * @param element   Element index the callback was set with.
 * @return          Plugin_Changed to send other, or anything else to leave this layer out.
 */
typedef SafeProxyCallbackEnt = function Action (int entity, const char[] prop, int &other, int client, int element);

/**
 * Supplies a color prop's value for a client.
 *
 * @param entity    Entity index.
 * @param prop      SendProp name the callback was set with.
 * @param rgba      The real red, green, blue and alpha.
 * @param client    Client index the value is for.
 * @param element   Element index the callback was set with.
 * @return          Plugin_Changed to send rgba, or anything else to leave this layer out.
 */
typedef SafeProxyCallbackColor = function Action (int entity, const char[] prop, int rgba[4], int client, int element);

/**
 * Overrides an int SendProp for a recipient with the value a callback returns for each snapshot.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param callback  Callback that supplies the value.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetProp.
 *
 * @note            The callback runs on the main thread, only for clients the entity is sent to, never for fake clients.
 * @note            SafeProxy_HasProp and the getters see what the callback last sent each client, and ignore it for SAFEPROXY_ALL_CLIENTS.
 */
native void SafeProxy_SetPropCallback(int entity, const char[] prop, SafeProxyCallback callback, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides a float SendProp for a recipient with the value a callback returns for each snapshot.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param callback  Callback that supplies the value.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetPropCallback.
 */
native void SafeProxy_SetPropFloatCallback(int entity, const char[] prop, SafeProxyCallbackFloat callback, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides a vector SendProp for a recipient with the vector a callback returns for each snapshot.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param callback  Callback that supplies the vector.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetPropCallback.
 */
native void SafeProxy_SetPropVectorCallback(int entity, const char[] prop, SafeProxyCallbackVector callback, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides a string SendProp for a recipient with the string a callback returns for each snapshot.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param callback  Callback that supplies the string.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetPropCallback.
 */
native void SafeProxy_SetPropStringCallback(int entity, const char[] prop, SafeProxyCallbackString callback, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides an entity handle SendProp for a recipient with the entity a callback returns for each snapshot.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param callback  Callback that supplies the entity.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetPropCallback.
 *
 * @note            An invalid or non-networked entity from the callback is logged and leaves this layer out.
 */
native void SafeProxy_SetPropEntCallback(int entity, const char[] prop, SafeProxyCallbackEnt callback, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides a color SendProp for a recipient with the color a callback returns for each snapshot.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param callback  Callback that supplies the color.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetPropCallback.
 *
 * @note            A channel out of range from the callback is logged and leaves this layer out.
 */
native void SafeProxy_SetPropColorCallback(int entity, const char[] prop, SafeProxyCallbackColor callback, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

/**
 * Overrides only the masked bits of an int SendProp for a recipient with the value a callback returns for each snapshot.
 * The callback replaces the calling plugin's whole layer, including bits set with SafeProxy_SetPropBits.
 *
 * @param entity    Entity index or reference.
 * @param prop      SendProp name.
 * @param callback  Callback that supplies the value.
 * @param mask      Which bits to override.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @param element   Element index for array props.
 * @error           As SafeProxy_SetPropCallback.
 *
 * @note            A mask with none of the prop's bits removes the calling plugin's layer.
 */
native void SafeProxy_SetPropBitsCallback(int entity, const char[] prop, SafeProxyCallback callback, int mask, int recipient = SAFEPROXY_ALL_CLIENTS, int element = 0);

// ============================================================================
// Transmit control
// ============================================================================

/**
 * Overrides whether an entity is sent to a recipient.
 *
 * @param entity    Entity index or reference.
 * @param state     Transmit state.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @error           Invalid, non-networked or world entity, invalid or disconnected recipient, invalid state, or SafeProxyTransmit_Normal for SAFEPROXY_ALL_CLIENTS.
 *
 * @note            Hide beats ForceWithChildren beats Force beats Normal across plugins.
 * @note            A Hide on or above a player doesn't hide it, its moveparent ancestors or anything parented to it from that player.
 * @note            ForceWithChildren skips children the game reserves for other clients, like another player's view model, and everything parented to them.
 * @note            SourceTV and Replay ignore transmit states.
 */
native void SafeProxy_SetTransmit(int entity, SafeProxyTransmit state, int recipient = SAFEPROXY_ALL_CLIENTS);

/**
 * Gets the transmit state an entity is overridden with for a recipient.
 *
 * @param entity    Entity index or reference.
 * @param state     Receives the state that wins across all plugins.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @return          True if any plugin overrides it.
 * @error           Invalid entity or recipient.
 */
native bool SafeProxy_GetTransmit(int entity, SafeProxyTransmit &state, int recipient = SAFEPROXY_ALL_CLIENTS);

/**
 * Returns whether an entity was in a client's latest snapshot.
 *
 * @param entity    Entity index or reference.
 * @param client    Client index.
 * @return          True if the entity was sent to the client.
 * @error           Invalid entity or client index.
 *
 * @note            Always false for bots.
 * @note            SourceTV and Replay report what the game sent them.
 */
native bool SafeProxy_IsTransmitted(int entity, int client);

/**
 * Returns whether a Hide on an entity or a moveparent above it keeps the entity from a client.
 *
 * @param entity    Entity index or reference.
 * @param client    Client index.
 * @return          True if the entity is hidden from the client.
 * @error           Invalid entity or client index.
 */
native bool SafeProxy_IsHidden(int entity, int client);

/**
 * Removes the calling plugin's transmit override for a recipient.
 *
 * @param entity    Entity index or reference.
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @return          True if the calling plugin had one to remove.
 * @error           Invalid recipient.
 */
native bool SafeProxy_UnsetTransmit(int entity, int recipient = SAFEPROXY_ALL_CLIENTS);

// ============================================================================
// Clearing
// ============================================================================

/**
 * Removes all of the calling plugin's prop overrides and callbacks on an entity.
 *
 * @param entity    Entity index or reference.
 * @return          Number of overrides and callbacks removed.
 * @error           Called while entities are being encoded.
 */
native int SafeProxy_ClearProps(int entity);

/**
 * Removes all of the calling plugin's transmit overrides on an entity.
 *
 * @param entity    Entity index or reference.
 * @return          Number of overrides removed.
 */
native int SafeProxy_ClearTransmit(int entity);

/**
 * Removes all of the calling plugin's prop overrides, callbacks and transmit overrides for a recipient.
 *
 * @param recipient Client index or SAFEPROXY_ALL_CLIENTS.
 * @return          Number of overrides and callbacks removed.
 * @error           Invalid recipient, or called while entities are being encoded.
 *
 * @note            With SAFEPROXY_ALL_CLIENTS, clients' own overrides are kept, unlike with SafeProxy_ClearAll.
 */
native int SafeProxy_ClearRecipient(int recipient);

/**
 * Removes all of the calling plugin's prop overrides, callbacks and transmit overrides.
 *
 * @return          Number of overrides and callbacks removed.
 * @error           Called while entities are being encoded.
 */
native int SafeProxy_ClearAll();

// ============================================================================
// Extension
// ============================================================================

public Extension __ext_safeproxy =
{
	name = "SafeProxy",
	file = "safeproxy.ext",
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
public void __ext_safeproxy_SetNTVOptional()
{
	MarkNativeAsOptional("SafeProxy_SetProp");
	MarkNativeAsOptional("SafeProxy_SetPropFloat");
	MarkNativeAsOptional("SafeProxy_SetPropVector");
	MarkNativeAsOptional("SafeProxy_SetPropString");
	MarkNativeAsOptional("SafeProxy_SetPropEnt");
	MarkNativeAsOptional("SafeProxy_SetPropColor");
	MarkNativeAsOptional("SafeProxy_SetPropReal");
	MarkNativeAsOptional("SafeProxy_SetPropBits");
	MarkNativeAsOptional("SafeProxy_GetPropType");
	MarkNativeAsOptional("SafeProxy_HasProp");
	MarkNativeAsOptional("SafeProxy_GetProp");
	MarkNativeAsOptional("SafeProxy_GetPropFloat");
	MarkNativeAsOptional("SafeProxy_GetPropVector");
	MarkNativeAsOptional("SafeProxy_GetPropString");
	MarkNativeAsOptional("SafeProxy_GetPropEnt");
	MarkNativeAsOptional("SafeProxy_GetPropColor");
	MarkNativeAsOptional("SafeProxy_GetPropBits");
	MarkNativeAsOptional("SafeProxy_UnsetProp");
	MarkNativeAsOptional("SafeProxy_UnsetPropBits");
	MarkNativeAsOptional("SafeProxy_SetPropCallback");
	MarkNativeAsOptional("SafeProxy_SetPropFloatCallback");
	MarkNativeAsOptional("SafeProxy_SetPropVectorCallback");
	MarkNativeAsOptional("SafeProxy_SetPropStringCallback");
	MarkNativeAsOptional("SafeProxy_SetPropEntCallback");
	MarkNativeAsOptional("SafeProxy_SetPropColorCallback");
	MarkNativeAsOptional("SafeProxy_SetPropBitsCallback");
	MarkNativeAsOptional("SafeProxy_SetTransmit");
	MarkNativeAsOptional("SafeProxy_GetTransmit");
	MarkNativeAsOptional("SafeProxy_IsTransmitted");
	MarkNativeAsOptional("SafeProxy_IsHidden");
	MarkNativeAsOptional("SafeProxy_UnsetTransmit");
	MarkNativeAsOptional("SafeProxy_ClearProps");
	MarkNativeAsOptional("SafeProxy_ClearTransmit");
	MarkNativeAsOptional("SafeProxy_ClearRecipient");
	MarkNativeAsOptional("SafeProxy_ClearAll");
}
#endif
