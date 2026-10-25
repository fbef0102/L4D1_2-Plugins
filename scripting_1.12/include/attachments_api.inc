#if defined _attachments_included
	#endinput
#endif
#define _attachments_included



public SharedPlugin __pl_attachment_api = 
{
	name = "attachments_api",
	file = "attachments_api.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};



/**
 * Creates or retrieves the specified clients weapon worldmodel entity for attaching other entities to.
 * @remarks					Never delete the returned entity index. Use ClearParent input on your entity instead and delete your attached entity.
 *
 * @param client			Client index to affect.
 * @param weapon			Weapon index to affect.
 *
 * @return					Entity index for attachments.
 */
native int Attachments_GetViewModel(int client, int weapon);

/**
 * Creates or retrieves the specified clients weapon worldmodel entity for attaching other entities to.
 * @remarks					Never delete the returned entity index. Use ClearParent input on your entity instead and delete your attached entity.
 *
 * @param client			Client index to affect.
 * @param weapon			Weapon index to affect.
 *
 * @return					Entity index for attachments.
 */
native int Attachments_GetWorldModel(int client, int weapon);

/**
 * Returns the attachment entity index if one exists, does not create if missing.
 * @remarks					Never delete the returned entity index. Use ClearParent input on your entity instead and delete your attached entity.
 *
 * @param client			Client index to affect.
 * @param viewmodel			True to check for viewmodel. False to check for worldmodel.
 *
 * @return					Entity index for attachments or 0 if none exist.
 */
native int Attachments_HasAttachment(int client, bool viewmodel);



/**
 * @brief				Called whenever a client switches weapons
 * @remarks				This happens after Attachments_API has changed the replica model and re-attached to the weapon.
 *
 * @param client		The clients entity index
 * @param weapon		The weapons entity index or -1 if missing or when a client is disconnecting
 * @param ent_views		The ViewModel entity index or -1 if missing
 * @param ent_world		The WorldModel entity index or -1 if missing
 */
forward void Attachments_OnWeaponSwitch(int client, int weapon, int ent_views, int ent_world);

/**
 * @brief				Called whenever a clients model changes (requires cvar "attachments_api_models" value "1" to enable)
 *
 * @param client		The clients entity index
 */
forward void Attachments_OnModelChanged(int client);

/**
 * @brief				Called whenever the plugin is unloading so other plugins can delete their attachments.
 *
 */
forward void Attachments_OnPluginEnd();

/**
 * @brief				Called whenever the plugin is late loaded so other plugins can attach their stuff.
 *
 */
forward void Attachments_OnLateLoad();