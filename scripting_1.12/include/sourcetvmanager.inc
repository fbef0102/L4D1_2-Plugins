#if defined _stvmngr_included
 #endinput
#endif
#define _stvmngr_included

// Some guidelines from the SDK about director camera shot durations
#define MIN_SHOT_LENGTH				4.0  // minimum time of a cut (seconds)
#define MAX_SHOT_LENGTH				8.0  // maximum time of a cut (seconds)
#define DEF_SHOT_LENGTH				6.0  // average time of a cut (seconds)

enum SourceTVBroadcastTarget {
	// Send message to all spectators including proxies.
	BTarget_Everyone = 0,
	// Send message only to locally connected spectators.
	BTarget_OnlyLocal
};

/**
 * Get the current amount of running SourceTV instances.
 * Can usually only be 1 at max except for CSGO, which can have 2.
 *
 * @return SourceTV instance number count. 
 */
native int SourceTV_GetServerInstanceCount();

/**
 * Select a SourceTV instance to operate the rest of the natives on.
 * The first SourceTV to connect will always be selected by default.
 * Most games only have 1 instance, so this might only be useful in CS:GO,
 * which can have 2 instances running.
 *
 * @param instance The SourceTV instance number.
 * @error Invalid SourceTV instance number.
 */
native void SourceTV_SelectServerInstance(int instance);

/**
 * Get the index of the currently selected SourceTV server instance.
 *
 * @return Index of the selected SourceTV instance number or -1 if no SourceTV enabled.
 */
native int SourceTV_GetSelectedServerInstance();

/**
 * Called when a SourceTV is initialized.
 *
 * @param instance	The SourceTV instance number.
 */
forward void SourceTV_OnServerStart(int instance);

 /**
  * Called when a SourceTV server instance is shutdown.
  *
  * @param instance	The SourceTV instance number.
  */
forward void SourceTV_OnServerShutdown(int instance);

/**
 * Returns whether this SourceTV instance is currently broadcasting.
 *
 * @return	True if SourceTV instance is broadcasting, false otherwise.
 */
native bool SourceTV_IsActive();

/**
 * Returns whether this SourceTV instance is a master proxy or relay.
 *
 * @return	True if SourceTV instance is master proxy, false otherwise.
 */
native bool SourceTV_IsMasterProxy();

/**
 * Get the local ip of the SourceTV server.
 *
 * @param ip	Buffer to save IP in.
 * @param maxlen	Maximum length of the buffer.
 * @return	True if IP written, false otherwise.
 */
native bool SourceTV_GetServerIP(char[] ip, int maxlen);

/**
 * Get the UDP port of the SourceTV server.
 * This is the port clients use to connect.
 *
 * @return	SourceTV server UDP port.
 */
native int SourceTV_GetServerPort();

/**
 * Get the client index of the SourceTV bot.
 *
 * @return Client index of SourceTV bot.
 */
native int SourceTV_GetBotIndex();

/**
 * Get stats of the local SourceTV instance.
 * Returns only the stats of this server, don't include relays.
 *
 * You have to subtract the proxy count from the spectator count to 
 * get the real spectator count, because the proxies take one spectator slot
 * on the SourceTV server.
 *
 * @param proxies	Number of SourceTV proxies connected to this server.
 * @param slots	Number of maximal available SourceTV spectator slots.
 * @param specs Number of currently connected SourceTV spectators.
 * @return True if stats were retrieved, false otherwise.
 */
native bool SourceTV_GetLocalStats(int &proxies, int &slots, int &specs);

/**
 * Get stats of this SourceTV network.
 * Only the current Master Proxy can give accurate numbers.
 * Relay proxies only get updates from the master from time to time.
 *
 * You have to subtract the proxy count from the spectator count to 
 * get the real spectator count, because the proxies take one spectator slot
 * on the SourceTV server.
 *
 * @param proxies	Number of SourceTV proxies connected to all servers.
 * @param slots	Number of maximal available SourceTV spectator slots on all servers.
 * @param specs Number of currently connected SourceTV spectators on all servers.
 * @return True if stats were retrieved, false otherwise.
 */
native bool SourceTV_GetGlobalStats(int &proxies, int &slots, int &specs);

/**
 * Current broadcasted tick. Can be lower than the actual server tick,
 * due to delay.
 *
 * @return Current broadcast tick from director.
 */
native int SourceTV_GetBroadcastTick();

/**
 * Returns current delay in seconds. (tv_delay)
 *
 * @return Current delay in seconds.
 */
native float SourceTV_GetDelay();

/**
 * Print a center message to all SourceTV spectators for ~2 seconds.
 * Like the tv_msg command.
 *
 * @param target	Send only to directly connected spectators or proxies as well?
 * @param format	The format string.
 * @param ...	Variable number of format string arguments.
 * @return	True if message was sent, false otherwise.
 */
native bool SourceTV_BroadcastScreenMessage(SourceTVBroadcastTarget target, const char[] format, any ...);

/**
 * Prints text to the console of all connected SourceTV spectators.
 *
 * @param format	The format string.
 * @param ...	Variable number of format string arguments.
 * @return	True if message was sent, false otherwise.
 */
native bool SourceTV_BroadcastConsoleMessage(const char[] format, any ...);

/**
 * Print a chat message to all SourceTV spectators.
 *
 * @param target	Send only to directly connected spectators or proxies as well?
 * @param format	The format string.
 * @param ...	Variable number of format string arguments.
 * @return	True if message was sent, false otherwise.
 */
native bool SourceTV_BroadcastChatMessage(SourceTVBroadcastTarget target, const char[] format, any ...);


/********************************************************************************
 * SourceTV Director control
 ********************************************************************************/

/**
 * Get entity index of current view entity (PVS) of the
 * auto director. Check the view origin, if this returns 0.
 * @see SourceTV_GetViewOrigin
 *
 * @return Current view entity index, 0 if coords are used.
 */
native int SourceTV_GetViewEntity();

/**
 * Get origin of current view point if view entity is 0.
 *
 * @param view	Vector to store view position in.
 */
native void SourceTV_GetViewOrigin(float view[3]);

/**
 * Force the auto director to show a certain camera angle.
 *
 * @param pos	The camera position.
 * @param angle	The camera angles (roll is unused).
 * @param iTarget	Target entity to keep the camera pointed towards or 0 to use the angle.
 * @param fow	Field of view of the camera.
 * @param fDuration	Length of the shot in seconds.
 * @return True if shot was created, false otherwise.
 * @error Invalid target entity.
 */
native bool SourceTV_ForceFixedCameraShot(float[] pos, float[] angle, int iTarget, float fov, float fDuration = DEF_SHOT_LENGTH);

/**
 * Force the auto director to show a player.
 *
 * @param iTarget1	The target player to follow.
 * @param iTarget2	The other player to keep the camera centered on or 0 to follow target1's view.
 * @param distance	Distance of camera behind the player.
 * @param phi	Up/down offset of view point.
 * @param theta	Left/right offset of view point.
 * @param bInEye	Show as in-eye camera of the target. Ignores all the other third-person settings.
 * @param fDuration	Length of the shot in seconds.
 * @return True if shot was created, false otherwise.
 * @error Invalid target1 or target2 entity
 */
native bool SourceTV_ForceChaseCameraShot(int iTarget1, int iTarget2, int distance, int phi, int theta, bool bInEye, float fDuration = DEF_SHOT_LENGTH);




/********************************************************************************
 * SourceTV demo recording
 ********************************************************************************/

/**
 * Starts recording a SourceTV demo into the specified file.
 * Only the master proxy can record demos.
 *
 * @param sFilename	Filename of the demo file.
 * @return True if recording started, false otherwise.
 */
native bool SourceTV_StartRecording(const char[] sFilename);

/**
 * Stops recording a SourceTV demo.
 *
 * @return	True if recording stopped, false otherwise.
 */
native bool SourceTV_StopRecording();

/**
 * Returns whether the SourceTV server is currently recording a demo.
 *
 * @return True if currently recording a SourceTV demo, false otherwise.
 */
native bool SourceTV_IsRecording();

/**
 * Get the filename of the currently recorded demo.
 *
 * @param sFilename	Buffer to store the filename in.
 * @param maxlen	Maximal length of the buffer.
 * @return True if filename was written, false otherwise.
 */
native bool SourceTV_GetDemoFileName(char[] sFilename, int maxlen);

/**
 * Get current tick in the demofile.
 *
 * @return Current recording tick in the demofle.
 */
native int SourceTV_GetRecordingTick();

/**
 * Print text to the demo console.
 * This will show up when playing the demo back in the client console later.
 *
 * @param format	The format string.
 * @param ...	Variable number of format string arguments.
 *
 * @return True if message was printed, false otherwise.
 */
native bool SourceTV_PrintToDemoConsole(const char[] format, any ...);

/**
 * Called when a SourceTV demo starts being recorded.
 * @see SourceTV_SelectServerInstance
 *
 * @param instance	The SourceTV instance of server recording.
 * @param filename	The filename of the demo.
 */
forward void SourceTV_OnStartRecording(int instance, const char[] filename);

/**
 * Called when a SourceTV demo stops being recorded.
 * @see SourceTV_SelectServerInstance
 *
 * @param instance	The SourceTV instance of server recording.
 * @param filename	The filename of the demo.
 * @param recordingtick	The tick length of the demo.
 */
forward void SourceTV_OnStopRecording(int instance, const char[] filename, int recordingtick);




/********************************************************************************
 * SourceTV spectator client handling
 ********************************************************************************/

/**
 * Get currently connected SourcetV spectator count.
 *
 * @return	SourceTV spectator count.
 */
native int SourceTV_GetSpectatorCount();

/**
 * Get the current client limit.
 *
 * @return	Maximal possible spectator count.
 */
native int SourceTV_GetMaxClients();

/**
 * Get number of client slots (used & unused)
 * Client slots are only allocated when they're needed.
 * Use this when iterating spectators.
 *
 * @return	Number of client slots (used & unused)
 */
native int SourceTV_GetClientCount();

/**
 * Returns if the spectator is connected.
 *
 * @param client	The spectator client index.
 * @return	True if client is connected, false otherwise.
 * @error	Invalid client index.
 */
native bool SourceTV_IsClientConnected(int client);

/**
 * Returns if the spectator is a relay proxy.
 *
 * @param client	The spectator client index.
 * @return	True if client is a proxy, false otherwise.
 * @error	Invalid client index.
 */
native bool SourceTV_IsClientProxy(int client);

/**
 * Get the name of a SourceTV spectator client.
 *
 * @param client	The spectator client index.
 * @param name	Buffer for the client name.
 * @param maxlen	Maximal length of the buffer.
 * @error	Invalid client index or not connected.
 */
native void SourceTV_GetClientName(int client, char[] name, int maxlen);

/**
 * Get the IP of a SourceTV spectator client.
 *
 * @param client	The spectator client index.
 * @param name	Buffer for the client ip.
 * @param maxlen	Maximal length of the buffer.
 * @error	Invalid client index or not connected.
 */
native void SourceTV_GetClientIP(int client, char[] ip, int maxlen);

/**
 * Get the password of a SourceTV spectator client.
 * The password the client tried to connect with.
 * Ignores changes from the SourceTV_OnSpectatorPreConnect forward.
 *
 * @param client	The spectator client index.
 * @param name	Buffer for the client ip.
 * @param maxlen	Maximal length of the buffer.
 * @error	Invalid client index or not connected.
 */
native void SourceTV_GetClientPassword(int client, char[] password, int maxlen);

/**
 * Kick a SourceTV spectator client.
 * 
 * @param client	The spectator client index.
 * @param sReason	The kick reason.
 * @error	Invalid client index or not connected.
 */
native void SourceTV_KickClient(int client, const char[] sReason);

/**
 * Print a message to a single client's chat.
 * 
 * @param client	The spectator client index.
 * @param format	The format string.
 * @param ...	Variable number of format string arguments.
 * @error	Invalid client index or not connected.
 */
native void SourceTV_PrintToChat(int client, const char[] format, any ...);

/**
 * Print a message to a single client's console.
 * 
 * @param client	The spectator client index.
 * @param format	The format string.
 * @param ...	Variable number of format string arguments.
 * @error	Invalid client index or not connected.
 */
native void SourceTV_PrintToConsole(int client, const char[] format, any ...);

/**
 * Change the stream title only for one spectator.
 * This is like tv_title but for a single client.
 * Gets overwritten when tv_title gets changed.
 * 
 * @param client	The spectator client index.
 * @param format	The format string.
 * @param ...	Variable number of format string arguments.
 * @error	Invalid client index or not connected.
 */
native void SourceTV_SetClientTVTitle(int client, const char[] format, any ...);

/**
 * Called when a spectator wants to connect to the SourceTV server.
 * This is called before any other validation has happened.
 * Similar to the OnClientPreConnectEx forward in the Connect extension by asherkin.
 *
 * @param name		The player name.
 * @param password	The password the client used to connect. Can be overwritten.
 * @param ip		The ip address of the client.
 * @param rejectReason	Buffer to write the reject reason to, if you want to reject the client from connecting.
 * @return True to allow the client to connect, false to reject him with the given reason.
 */
forward bool SourceTV_OnSpectatorPreConnect(const char[] name, char password[255], const char[] ip, char rejectReason[255]);

/**
 * Called when a spectator client connected to the SourceTV server.
 * 
 * @param client	The spectator client index.
 */
forward void SourceTV_OnSpectatorConnected(int client);

/**
 * Called when a spectator client is about to disconnect.
 * 
 * @param client	The spectator client index.
 * @param reason	The reason for the disconnect. Can be overwritten.
 */
forward void SourceTV_OnSpectatorDisconnect(int client, char reason[255]);

/**
 * Called after a spectator client disconnected.
 * 
 * @param client	The spectator client index.
 * @param reason	The reason for the disconnect.
 */
forward void SourceTV_OnSpectatorDisconnected(int client, const char reason[255]);

/**
 * Called when a spectator client is entering the game.
 * 
 * @param client	The spectator client index.
 */
forward void SourceTV_OnSpectatorPutInServer(int client);

/**
 * Called before a spectator's chat message is sent.
 * The message and chat group can be changed.
 * Only called for directly connected clients - no proxies.
 *
 * @param client     The spectator client index.
 * @param message    The message the client typed.
 * @param chatgroup  The chatgroup this message is sent to (tv_chatgroup).
 * @return >= Plugin_Handled to block the message, Plugin_Continue to let it through.
 */
forward Action SourceTV_OnSpectatorChatMessage(int client, char message[255], char chatgroup[255]);

/**
 * Called after a spectator wrote a chat message.
 * Only called for directly connected clients - no proxies.
 *
 * @param client     The spectator client index.
 * @param message    The message the client typed.
 * @param chatgroup  The chatgroup this message is sent to (tv_chatgroup).
 */
forward void SourceTV_OnSpectatorChatMessage_Post(int client, const char[] message, const char[] chatgroup);

/**
 * Do not edit below this line!
 */
public Extension __ext_stvmngr = 
{
	name = "SourceTV Manager",
	file = "sourcetvmanager.ext",
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
public void __ext_stvmngr_SetNTVOptional()
{
	MarkNativeAsOptional("SourceTV_GetServerInstanceCount");
	MarkNativeAsOptional("SourceTV_SelectServerInstance");
	MarkNativeAsOptional("SourceTV_GetSelectedServerInstance");
	MarkNativeAsOptional("SourceTV_IsActive");
	MarkNativeAsOptional("SourceTV_IsMasterProxy");
	MarkNativeAsOptional("SourceTV_GetServerIP");
	MarkNativeAsOptional("SourceTV_GetServerPort");
	MarkNativeAsOptional("SourceTV_GetBotIndex");
	MarkNativeAsOptional("SourceTV_GetLocalStats");
	MarkNativeAsOptional("SourceTV_GetGlobalStats");
	MarkNativeAsOptional("SourceTV_GetBroadcastTick");
	MarkNativeAsOptional("SourceTV_GetDelay");
	MarkNativeAsOptional("SourceTV_BroadcastScreenMessage");
	MarkNativeAsOptional("SourceTV_BroadcastConsoleMessage");
	MarkNativeAsOptional("SourceTV_BroadcastChatMessage");
	MarkNativeAsOptional("SourceTV_GetViewEntity");
	MarkNativeAsOptional("SourceTV_GetViewOrigin");
	MarkNativeAsOptional("SourceTV_ForceFixedCameraShot");
	MarkNativeAsOptional("SourceTV_ForceChaseCameraShot");
	MarkNativeAsOptional("SourceTV_StartRecording");
	MarkNativeAsOptional("SourceTV_StopRecording");
	MarkNativeAsOptional("SourceTV_IsRecording");
	MarkNativeAsOptional("SourceTV_GetDemoFileName");
	MarkNativeAsOptional("SourceTV_GetRecordingTick");
	MarkNativeAsOptional("SourceTV_PrintToDemoConsole");
	MarkNativeAsOptional("SourceTV_GetSpectatorCount");
	MarkNativeAsOptional("SourceTV_GetMaxClients");
	MarkNativeAsOptional("SourceTV_GetClientCount");
	MarkNativeAsOptional("SourceTV_IsClientConnected");
	MarkNativeAsOptional("SourceTV_IsClientProxy");
	MarkNativeAsOptional("SourceTV_GetClientName");
	MarkNativeAsOptional("SourceTV_GetClientIP");
	MarkNativeAsOptional("SourceTV_GetClientPassword");
	MarkNativeAsOptional("SourceTV_KickClient");
	MarkNativeAsOptional("SourceTV_PrintToChat");
	MarkNativeAsOptional("SourceTV_PrintToConsole");
	MarkNativeAsOptional("SourceTV_SetClientTVTitle");
}
#endif
