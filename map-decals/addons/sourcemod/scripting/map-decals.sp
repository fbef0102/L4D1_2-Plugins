
// enforce semicolons after each code statement
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <adminmenu>

#define PLUGIN_VERSION "1.4"

// Admin Level Defines: Level for Allowing Temp.Spray/Temp.Remove of Decals and Level for Saving Decals/getting aim position
#define ADMIN_LEVEL_SPRAY	ADMFLAG_CUSTOM3
#define ADMIN_LEVEL_SAVE	ADMFLAG_ROOT

// Mode Defines for Function ReadDecals
#define READ	0
#define LIST	1

// Color Defines
#define COLOR_DEFAULT	0x01
#define COLOR_GREEN		0x04 // DOD = Red



/*****************************************************************


		P L U G I N   I N F O


*****************************************************************/

public Plugin:myinfo = {
	name = "Map decals maker",
	author = "Berni, Stingbyte, Harry Potter",
	description = "Allows admins to place any decals into the map that are defined in the the config and save them permanently for each map",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=69502"
}



/*****************************************************************


		G L O B A L   V A R S


*****************************************************************/

// ConVar Handles
new Handle:md_download_style			= INVALID_HANDLE;
new Handle:md_maxdis			= INVALID_HANDLE;
new Handle:md_pos				= INVALID_HANDLE;
new Handle:md_spraysound		= INVALID_HANDLE;

// Misc
new Handle:hAdminMenu			= INVALID_HANDLE;

new Handle:adt_decal_names		= INVALID_HANDLE;
new Handle:adt_decal_paths		= INVALID_HANDLE;
new Handle:adt_decal_precache	= INVALID_HANDLE;

new Handle:adt_decal_id			= INVALID_HANDLE;
new Handle:adt_decal_position	= INVALID_HANDLE;

new String:mapName[64];
new String:path_decals[PLATFORM_MAX_PATH];
new String:path_mapdecals[PLATFORM_MAX_PATH];



/*****************************************************************


		F O R W A R D   P U B L I C S


*****************************************************************/

public OnPluginStart() {
	
	// Commands
	RegAdminCmd("sm_paintdecal",	Command_PaintDecal, 	ADMIN_LEVEL_SPRAY, 	"Sprays a Decal by <name | id> (names specified in config)");
	RegAdminCmd("sm_removedecal",	Command_RemoveDecal, 	ADMIN_LEVEL_SPRAY, 	"Removes a Decal whilst aiming at it, [all] removes all Decals (on current Map), [id] removes a Decal by id, [last] removes last painted Decal, [name] removes all Decals by decalname (on current Map)");
	RegAdminCmd("sm_listdecal",		Command_ListDecal, 		ADMIN_LEVEL_SPRAY, 	"Shows the name of a Decal whilst aiming at it, [all] lists all Decal names available, [id] lists a Decal by id, [last] lists the last painted Decal (on current Map), [map] lists all Decals painted (on current Map), [name] lists all Decals by that Name painted (on current Map), [saved] lists all Decals saved in config File");
	RegAdminCmd("sm_savedecal",		Command_SaveDecal, 		ADMIN_LEVEL_SAVE, 	"Saves a Decal to the config whilst aiming at it, [all] saves all Decals (on current Map), [id] saves a Decal by id, [last] saves last painted Decal, [name] saves all Decals by decalname (on current Map)");
	RegAdminCmd("sm_aimpos",		Command_GetAimPos, 		ADMIN_LEVEL_SAVE, 	"Shows the position you are currently aiming at");
	RegAdminCmd("sm_decalmenu",		Command_DecalMenu,		ADMIN_LEVEL_SPRAY,	"Shows the Map Decals Menu");
	
	// ConVars
	md_download_style		= CreateConVar("md_download_style","1", "what kind of way to download decals? [0 - all at once, 1 - depend on Map specific configs]", FCVAR_NOTIFY);
	md_maxdis		= CreateConVar("md_decal_dista", "50.0", "How far away from the Decals position it will be traced to and check distance to prevent painting a Decal over another");
	md_pos			= CreateConVar("md_decal_printpos", "1", "Turns on/off printing out of decal positions");
	md_spraysound	= CreateConVar("md_decal_spraysound", "player/sprayer.wav", "Path to the spray sound used by map-decals plugin");
	
	AutoExecConfig(true, "map-decals");

	// Create our dynamic arrays we need for the keyvalues/decal data
	adt_decal_names = CreateArray(64);
	adt_decal_paths = CreateArray(PLATFORM_MAX_PATH);
	adt_decal_precache = CreateArray();
	adt_decal_id = CreateArray();
	adt_decal_position = CreateArray(3);
	
	LoadTranslations("map-decals.phrases");
	
	/* See if the menu plugin is already ready */
	new Handle:topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE)) {
		/* If so, manually fire the callback */
		OnAdminMenuReady(topmenu);
	}
}

public OnLibraryRemoved(const String:name[]) {

	if (StrEqual(name, "adminmenu")) {
		hAdminMenu = INVALID_HANDLE;
	}
}

public OnMapStart() {

	GetCurrentMap(mapName, sizeof(mapName));

	BuildPath(Path_SM, path_decals, sizeof(path_decals), "/configs/map-decals/decals.cfg");
	BuildPath(Path_SM, path_mapdecals, sizeof(path_mapdecals), "/configs/map-decals/maps/%s.cfg", mapName);

	ReadDecals(-1, READ);
	
	decl String:spraySound[PLATFORM_MAX_PATH];
	GetConVarString(md_spraysound, spraySound, sizeof(spraySound));
	Format(spraySound, sizeof(spraySound), "sound/%s", spraySound);
	AddFileToDownloadsTable(spraySound);
	
	// Precache Spray Sound
	if (!PrecacheSound(spraySound, true)) {
		LogMessage("PrecacheSound failed: %s", spraySound);
	}
}

public OnMapEnd() {
	
	ClearArray(adt_decal_names);
	ClearArray(adt_decal_paths);
	ClearArray(adt_decal_precache);
	
	ClearArray(adt_decal_id);
	ClearArray(adt_decal_position);
}

public OnClientPostAdminCheck(client) {
	
	// Show him what we have
	decl Float:position[3];
	decl id, precache;
	
	new size = GetArraySize(adt_decal_id);
	for (new i=0; i<size; ++i) {
		id = GetArrayCell(adt_decal_id, i);
		precache = GetArrayCell(adt_decal_precache, id);
		GetArrayArray(adt_decal_position, i, _:position);
		TE_SetupBSPDecal(position, 0, precache);
		TE_SendToClient(client);
	}
}

// Menu (Mostly taken from Wiki)
public OnAdminMenuReady(Handle:topmenu) {

	/* Block us from being called twice */
	if (topmenu == hAdminMenu) {

		return;
	}
	
	/* Save the Handle */
	hAdminMenu = topmenu;
	
	/* Find the "Server Commands" category */
	new TopMenuObject:server_commands = FindTopMenuCategory(hAdminMenu, ADMINMENU_SERVERCOMMANDS);
	
	AddToTopMenu(hAdminMenu,
			"sm_decalmenu",
			TopMenuObject_Item,
			AdminMenu_MapDecals,
			server_commands,
			"sm_decalmenu",
			ADMIN_LEVEL_SPRAY);
}



/****************************************************************


		C A L L B A C K   F U N C T I O N S


****************************************************************/

public Action:Command_PaintDecal(client, args) {
	
	if (GetCmdArgs() == 0) {
		ReplyToCommand(client, "%t", "usage_paintdecal", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT);
		return Plugin_Handled;
	}
	
	decl String:decalName[64];
	
	GetCmdArg(1, decalName, sizeof(decalName));
	
	new id = StringToInt(decalName, 10);
	
	if (id == 0 || id > GetArraySize(adt_decal_names)) {
		id = FindStringInArrayCase(adt_decal_names, decalName, false);
	}
	else{
		id--;
		GetArrayString(adt_decal_names, id, decalName, sizeof(decalName));
	}
	
	if (id == -1) {
		ReplyToCommand(client, "%t", "error_decal_not_found", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT);
		return Plugin_Handled;
	}
	
	new precache = GetArrayCell(adt_decal_precache, id);
	new Float:MaxDis = GetConVarFloat(md_maxdis);
	
	decl Float:pos[3];
	decl Float:position[3];
	
	if (GetClientAimTargetEx(client, pos) >= 0) {
		new size = GetArraySize(adt_decal_id);
		for (new i=0; i<size; ++i) {
			GetArrayArray(adt_decal_position, i, _:position);
			if (GetVectorDistance(pos, position) <= MaxDis) {
				ReplyToCommand(client, "%t", "error_another_decal", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT);
				return Plugin_Handled;
			}
		}
		
		// Setup new decal
		TE_SetupBSPDecal(pos, 0, precache);
		TE_SendToAll();
		
		// Play Spraysound
		decl String:spraySound[PLATFORM_MAX_PATH];
		GetConVarString(md_spraysound, spraySound, sizeof(spraySound));
		EmitAmbientSound(spraySound, pos, SOUND_FROM_PLAYER, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, 0.0);
		
		// Save decal id and position
		PushArrayCell(adt_decal_id, id);
		PushArrayArray(adt_decal_position, _:pos);
		size = GetArraySize(adt_decal_id);
		ReplyToCommand(client, "%t", "paintdecal_aim",COLOR_DEFAULT, COLOR_GREEN, size, COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		LogAction(client, -1, "\"%L\" painted Decal \"%s\" on Map \"%s\" (Position: %f, %f, %f)", client, decalName, mapName, pos[0], pos[1], pos[2]);
		
		new DecalPos = GetConVarInt(md_pos);
		
		if (DecalPos) {
			ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, pos[0], pos[1], pos[2]);
		}
	}
	else {
		ReplyToCommand(client, "%t", "error_entity", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT);
	}
	
	return Plugin_Handled;
}

public Action:Command_RemoveDecal(client, args) {

	decl String:decalName[64];
	decl Float:position[3];
	new size = GetArraySize(adt_decal_id);
	
	if (size < 1) {
		ReplyToCommand(client, "%t", "no_decal", COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		return Plugin_Handled;
	}
	// Remove by aim position
	if (GetCmdArgs() == 0) {
		decl Float:pos[3];
		if (GetClientAimTargetEx(client, pos) >= 0) {
			new Float:MaxDis = GetConVarFloat(md_maxdis);
			for (new i=0; i<size; ++i) {
				GetArrayArray(adt_decal_position, i, _:position);
				if (GetVectorDistance(pos, position) <= MaxDis) {
					new decal = GetArrayCell(adt_decal_id, i);
					GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
					RemoveFromArray(adt_decal_id, i);
					RemoveFromArray(adt_decal_position, i);
					ReplyToCommand(client, "%t", "removedecal", COLOR_DEFAULT, COLOR_GREEN, i+1, COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
					LogAction(client, -1, "\"%L\" removed Decal \"%s\" from Map \"%s\" (Position: %f, %f, %f)", client, decalName, mapName, position[0], position[1], position[2]);
					new DecalPos = GetConVarInt(md_pos);
					if (DecalPos)
						ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
					return Plugin_Handled;
				}
			} 
		}
		
		ReplyToCommand(client, "%t", "no_decal_found", COLOR_DEFAULT, COLOR_GREEN);
		
		return Plugin_Handled;
	}
	
	decl String:action[64];
	
	GetCmdArg(1, action, sizeof(action));
	
	// Remove all on current map
	
	if (strcmp(action ,"all", false) == 0) {
		ClearArray(adt_decal_id);
		ClearArray(adt_decal_position);
		if (size==1)
			ReplyToCommand(client, "%t", "removedecal_all_single", COLOR_DEFAULT, COLOR_GREEN, size, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		else
			ReplyToCommand(client, "%t", "removedecal_all", COLOR_DEFAULT, COLOR_GREEN, size, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		LogAction(client, -1, "\"%L\" removed all %d Decal(s) from Map \"%s\"", client, size, mapName);
		return Plugin_Handled;
	}
	
	// Remove last painted decal on current map
	if (strcmp(action ,"last", false)==0) {
		new decal = GetArrayCell(adt_decal_id, size-1);
		GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
		GetArrayArray(adt_decal_position, size-1, _:position);
		RemoveFromArray(adt_decal_id, size-1);
		RemoveFromArray(adt_decal_position, size-1);
		ReplyToCommand(client, "%t", "removedecal", COLOR_DEFAULT, COLOR_GREEN, size, COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		LogAction(client, -1, "\"%L\" removed Decal \"%s\" from Map \"%s\" (Position: %f, %f, %f)", client, decalName, mapName, position[0], position[1], position[2]);
		new DecalPos = GetConVarInt(md_pos);
		if (DecalPos) {
			ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
		}
		
		return Plugin_Handled;
	}
	
	// Remove by Name
	new index = FindStringInArrayCase(adt_decal_names, action, false);
	if (index != -1) {
		GetArrayString(adt_decal_names, index, decalName, sizeof(decalName));
		new removepos = FindValueInArray(adt_decal_id, index);
		if (removepos != -1) {
			while(removepos != -1) {
				GetArrayArray(adt_decal_position, removepos, _:position);
				RemoveFromArray(adt_decal_id, removepos);
				RemoveFromArray(adt_decal_position, removepos);
				ReplyToCommand(client, "%t", "removedecal_name", COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
				LogAction(client, -1, "\"%L\" removed Decal \"%s\" from Map \"%s\" (Position: %f, %f, %f)", client, decalName, mapName, position[0], position[1], position[2]);
				new DecalPos = GetConVarInt(md_pos);
				if (DecalPos) {
					ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
				}
				removepos = FindValueInArray(adt_decal_id, index);
			}
			new cursize = GetArraySize(adt_decal_id); 
			if (cursize == 0 && size > 1)
				ReplyToCommand(client, "%t", "removedecal_names",COLOR_DEFAULT, COLOR_GREEN, size, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
			if (cursize > 1)
				ReplyToCommand(client, "%t", "removedecal_names",COLOR_DEFAULT, COLOR_GREEN, size-cursize, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
			return Plugin_Handled;
		}
		ReplyToCommand(client, "%t", "decals_named", COLOR_DEFAULT, COLOR_GREEN, action, COLOR_DEFAULT);
		return Plugin_Handled;
	}
	
	// Remove by ID
	index = StringToInt(action);
	if (index != 0 && index <= size) {
		index--;
		new decal = GetArrayCell(adt_decal_id, index);
		GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
		GetArrayArray(adt_decal_position, index, _:position);
		RemoveFromArray(adt_decal_id, index);
		RemoveFromArray(adt_decal_position, index);
		ReplyToCommand(client, "%t", "removedecal", COLOR_DEFAULT, COLOR_GREEN, index+1, COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		LogAction(client, -1, "\"%L\" removed Decal \"%s\" from Map \"%s\" (Position: %f, %f, %f)", client, decalName, mapName, position[0], position[1], position[2]);
		new DecalPos = GetConVarInt(md_pos);
		if (DecalPos)
			ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
		return Plugin_Handled;
	}
	ReplyToCommand(client, "%t", "usage_removedecal", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT);
	return Plugin_Handled;
}

public Action:Command_ListDecal(client, args) {
	
	new size = GetArraySize(adt_decal_id);
	// List by aim position
	decl Float:position[3];
	decl String:decalName[64];
	if (GetCmdArgs() == 0) {
		decl Float:pos[3];
		if (GetClientAimTargetEx(client, pos) >= 0) {
			new Float:MaxDis = GetConVarFloat(md_maxdis);
			for (new i=0; i<size; ++i) {
				GetArrayArray(adt_decal_position, i, _:position);
				if (GetVectorDistance(pos, position) <= MaxDis) {
					new decal = GetArrayCell(adt_decal_id, i);
					GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
					ReplyToCommand(client, "%t", "list_decal_id_name",COLOR_DEFAULT, COLOR_GREEN, i+1, COLOR_DEFAULT, COLOR_GREEN, decalName);
					new DecalPos = GetConVarInt(md_pos);
					if (DecalPos)
						ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
					return Plugin_Handled;
				}
			} 
		}
		ReplyToCommand(client, "%t", "no_decal_found", COLOR_DEFAULT, COLOR_GREEN);
		return Plugin_Handled;
	}
	
	// List all Decals available in config File
	decl String:action[64];
	GetCmdArg(1, action, sizeof(action));
	if (strcmp(action ,"all", false) == 0) {
		new nsize = GetArraySize(adt_decal_names);
		if (nsize>0)
			ReplyToCommand(client, "%t", "available_decals", COLOR_DEFAULT, COLOR_GREEN);
		
		else
			ReplyToCommand(client, "%t", "no_decals_available", COLOR_DEFAULT, COLOR_GREEN);
		for (new i=0; i<nsize; ++i) {
			GetArrayString(adt_decal_names, i, decalName, sizeof(decalName));
			ReplyToCommand(client, "%t", "listdecal",COLOR_DEFAULT, COLOR_GREEN, i+1, COLOR_DEFAULT, COLOR_GREEN, decalName);
		}
		return Plugin_Handled;
	}
	
	// List saved Decals
	if (strcmp(action, "saved", false) == 0) {
		ReplyToCommand(client, "%t", "decals_file", COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		ReadDecals(client, LIST);
		return Plugin_Handled;
	}
	
	if (size < 1) {
		ReplyToCommand(client, "%t", "no_decal", COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		return Plugin_Handled;
	}
	
	// List last painted Decal on current Map
	if (strcmp(action ,"last", false) == 0) {
		new decal = GetArrayCell(adt_decal_id, size-1);
		GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
		GetArrayArray(adt_decal_position, size-1, _:position);
		ReplyToCommand(client, "%t", "last_decal",COLOR_DEFAULT, COLOR_GREEN, size, COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT);
		
		new DecalPos = GetConVarInt(md_pos);
		if (DecalPos) {
			ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
		}
		return Plugin_Handled;
	}
	
	// List by Name on current Map
	if (FindStringInArrayCase(adt_decal_names, action, false) > -1) {
		new status = 0;
		ReplyToCommand(client, "%t", "decals_name_on_map", COLOR_DEFAULT, COLOR_GREEN, action, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		for (new i=0; i<size; ++i) {
			new index = GetArrayCell(adt_decal_id, i);
			GetArrayString(adt_decal_names, index, decalName, sizeof(decalName));
			if (strcmp(action,decalName, false)==0) {
				GetArrayArray(adt_decal_position, i, _:position);
				ReplyToCommand(client, "%t", "listdecal",COLOR_DEFAULT, COLOR_GREEN, i+1, COLOR_DEFAULT, COLOR_GREEN, decalName);
				status = 1;
				new DecalPos = GetConVarInt(md_pos);
				if (DecalPos)
					ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
			}
		}
		if (!status)
			ReplyToCommand(client, "%t", "decals_named", COLOR_DEFAULT, COLOR_GREEN, action, COLOR_DEFAULT);
		return Plugin_Handled;
	}
	
	// List all on current Map
	if (strcmp(action ,"map", false)==0) {

		ReplyToCommand(client, "%t", "decals_on_map", COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		for (new i=0; i<size; ++i) {
			new decal = GetArrayCell(adt_decal_id, i);
			GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
			GetArrayArray(adt_decal_position, i, _:position);
			ReplyToCommand(client, "%t", "listdecal",COLOR_DEFAULT, COLOR_GREEN, i+1, COLOR_DEFAULT, COLOR_GREEN, decalName);
			new DecalPos = GetConVarInt(md_pos);
			if (DecalPos) {
				ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
			}
		}
		return Plugin_Handled;
	}
	
	// List by ID
	new index = StringToInt(action);
	if (index != 0 && index<=size) {

		index -= 1;
		new decal = GetArrayCell(adt_decal_id, index);
		GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
		GetArrayArray(adt_decal_position, index, _:position);
		ReplyToCommand(client, "%t", "listdecal",COLOR_DEFAULT, COLOR_GREEN, index+1, COLOR_DEFAULT, COLOR_GREEN, decalName);
		new DecalPos = GetConVarInt(md_pos);
		if (DecalPos)
			ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "%t", "usage_listdecal", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT);
	
	return Plugin_Handled;
}

public Action:Command_SaveDecal(client, args) {
	
	decl Float:position[3];
	decl Float:pos[3];
	decl String:decalName[64];
	decl String:strpos[8];
	new n=1;
	new saved = 0;
	decl index;
	new size = GetArraySize(adt_decal_id);
	new Handle:kv = CreateKeyValues("Positions");
	// Save by aim position
	if (GetCmdArgs() == 0) {
		if (GetClientAimTargetEx(client, pos) >= 0) {
			new Float:MaxDis = GetConVarFloat(md_maxdis);
			for (new i=0; i<size; ++i) {
				GetArrayArray(adt_decal_position, i, _:position);
				if (GetVectorDistance(pos, position) <= MaxDis) {
					CreateFileIfNotExist(path_mapdecals);
					ReplyToCommand(client, "%t", "savedecal_file",COLOR_DEFAULT, COLOR_GREEN, path_mapdecals, COLOR_DEFAULT);
					new decal = GetArrayCell(adt_decal_id, i);
					GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
					FileToKeyValues(kv, path_mapdecals);
					if (KvJumpToKey(kv, decalName, false)) {
						Format(strpos, sizeof(strpos), "pos%d", n);
						KvGetVector(kv, strpos, pos);
						while (pos[0] != 0 && pos[1] != 0 && pos[2] != 0) {
							if (RoundFloat(GetVectorDistance(pos, position)) == 0) {
									saved = 1;
									break;
							}
							n++;
							Format(strpos, sizeof(strpos), "pos%d", n);
							KvGetVector(kv, strpos, pos);
						}
						KvRewind(kv);
					}
					if (saved)
						ReplyToCommand(client, "%t", "error_decal_in_file",COLOR_DEFAULT,COLOR_GREEN,COLOR_DEFAULT);
					else{
						KvJumpToKey(kv, decalName, true);
						Format(strpos, sizeof(strpos), "pos%d", n);
						KvSetVector(kv, strpos, position);
						KvRewind(kv);
						KeyValuesToFile(kv, path_mapdecals);
						ReplyToCommand(client, "%t", "saved_aim",COLOR_DEFAULT, COLOR_GREEN, 1, COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT);
						new DecalPos = GetConVarInt(md_pos);
						if (DecalPos)
							ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
						LogAction(client, -1, "\"%L\" saved Decal \"%s\" on Map \"%s\" (Position: %f, %f, %f)",client, decalName, mapName, position[0], position[1], position[2]);
					}	
					CloseHandle(kv);
					return Plugin_Handled;
				}
			} 
		}
		
		ReplyToCommand(client, "%t", "no_decal_found", COLOR_DEFAULT, COLOR_GREEN); 
		CloseHandle(kv);
		
		return Plugin_Handled;
	}
	
	decl String:action[64];		
	// Save all on current Map to File
	GetCmdArg(1, action, sizeof(action));
	if (strcmp(action ,"all", false)==0) {
		CreateFileIfNotExist(path_mapdecals);
		ReplyToCommand(client, "%t", "savedecals_file", COLOR_DEFAULT, COLOR_GREEN, path_mapdecals, COLOR_DEFAULT);
		new Handle:trie = CreateTrie();
		size = GetArraySize(adt_decal_id);
		for (new i=0; i<size; ++i) {
			new decal = GetArrayCell(adt_decal_id, i);
			GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
			GetArrayArray(adt_decal_position, i, _:position);
		
			KvJumpToKey(kv, decalName, true);
			Format(strpos, sizeof(strpos), "pos%d", NextPosFromTrie(trie, decalName));
			KvSetVector(kv, strpos, position);
		
			KvRewind(kv);
		}
		KeyValuesToFile(kv, path_mapdecals);
		CloseHandle(kv);
		CloseHandle(trie);
		
		if (size == 1) {
			ReplyToCommand(client, "%t", "saved_one", COLOR_DEFAULT, COLOR_GREEN, size, COLOR_DEFAULT);
		}
		else {
			ReplyToCommand(client, "%t", "saved_more", COLOR_DEFAULT, COLOR_GREEN, size, COLOR_DEFAULT);
		}
		
		LogAction(client, -1, "\"%L\" saved all Decals on Map \"%s\"", client, mapName);
		
		return Plugin_Handled;
	}
	
	if (size < 1) {
		ReplyToCommand(client, "%t", "no_decals_available_map", COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		return Plugin_Handled;
	}
	
	// Save last painted Decal to File
	if (strcmp(action ,"last", false)==0) {
		CreateFileIfNotExist(path_mapdecals);
		ReplyToCommand(client, "%t", "saving_last", COLOR_DEFAULT, COLOR_GREEN, path_mapdecals, COLOR_DEFAULT);
		new decal = GetArrayCell(adt_decal_id, size-1);
		GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
		GetArrayArray(adt_decal_position, size-1, _:position);
		FileToKeyValues(kv, path_mapdecals);
		if (KvJumpToKey(kv, decalName, false)) {
			Format(strpos, sizeof(strpos), "pos%d", n);
			KvGetVector(kv, strpos, pos);
			while (pos[0] != 0 && pos[1] != 0 && pos[2] != 0) {
				if (RoundFloat(GetVectorDistance(pos, position)) == 0) {
					saved = 1;
					break;
				}
				n++;
				Format(strpos, sizeof(strpos), "pos%d", n);
				KvGetVector(kv, strpos, pos);
			}
			KvRewind(kv);
		}
		if (saved)
			ReplyToCommand(client, "%t", "error_decal_in_file", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT);
		else{
			KvJumpToKey(kv, decalName, true);
			Format(strpos, sizeof(strpos), "pos%d", n);
			KvSetVector(kv, strpos, position);
			KvRewind(kv);
			KeyValuesToFile(kv, path_mapdecals);
			ReplyToCommand(client, "%t", "saved_last", COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT);
			new DecalPos = GetConVarInt(md_pos);
			if (DecalPos)
				ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
			LogAction(client, -1, "\"%L\" saved Decal \"%s\" on Map \"%s\" (Position: %f, %f, %f)", client, decalName, mapName, position[0], position[1], position[2]);
		}	
		CloseHandle(kv);
		return Plugin_Handled;
	}
	
	// Save by Name
	new found = FindStringInArrayCase(adt_decal_names, action, false);
	if (found > -1) {
		GetArrayString(adt_decal_names,found, action, sizeof(action)); 
		new count = 0;
		CreateFileIfNotExist(path_mapdecals);
		ReplyToCommand(client, "%t", "savedecals_file", COLOR_DEFAULT, COLOR_GREEN, path_mapdecals, COLOR_DEFAULT);
		FileToKeyValues(kv, path_mapdecals);
		for (new i=0; i<size; ++i) {
			index = GetArrayCell(adt_decal_id, i);
			GetArrayString(adt_decal_names, index, decalName, sizeof(decalName));
			if (strcmp(action,decalName, false)==0) {
				GetArrayArray(adt_decal_position, i, _:position);		
				if (KvJumpToKey(kv, decalName, false)) {
					Format(strpos, sizeof(strpos), "pos%d", n);
					KvGetVector(kv, strpos, pos);
					while (pos[0] != 0 && pos[1] != 0 && pos[2] != 0) {
						if (RoundFloat(GetVectorDistance(pos, position)) == 0) {
							saved = 1;
							break;
						}
						n++;
						Format(strpos, sizeof(strpos), "pos%d", n);
						KvGetVector(kv, strpos, pos);
					}
					KvRewind(kv);
				}
				if (!saved) {
					KvJumpToKey(kv, decalName, true);
					Format(strpos, sizeof(strpos), "pos%d", n);
					KvSetVector(kv, strpos, position);
					KvRewind(kv);
					LogAction(client, -1, "\"%L\" saved Decal \"%s\" on Map \"%s\" (Position: %f, %f, %f)", client, decalName, mapName, position[0], position[1], position[2]);
					n = 1;
					count++;
				}
				else{
					n = 1;
					saved = 0;
				}
			}
		}
		if (count == 1) {

			ReplyToCommand(client, "%t", "saved_one_name", COLOR_DEFAULT, COLOR_GREEN, count, COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT);
			new DecalPos = GetConVarInt(md_pos);
			if (DecalPos) {
				ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
			}
		}
		else
			ReplyToCommand(client, "%t", "saved_more",COLOR_DEFAULT, COLOR_GREEN, count, COLOR_DEFAULT, COLOR_GREEN, decalName, COLOR_DEFAULT);
		KeyValuesToFile(kv, path_mapdecals);
		CloseHandle(kv);
		return Plugin_Handled;
	}
	
	// Save by ID
	index = StringToInt(action);
	if (index != 0 && index <= size) {
		CreateFileIfNotExist(path_mapdecals);
		ReplyToCommand(client, "%t", "savedecal_file", COLOR_DEFAULT, COLOR_GREEN, path_mapdecals, COLOR_DEFAULT);
		index -= 1;
		new decal = GetArrayCell(adt_decal_id, index);
		GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
		GetArrayArray(adt_decal_position, index, _:position);
		FileToKeyValues(kv, path_mapdecals);
		if (KvJumpToKey(kv, decalName, false)) {
			Format(strpos, sizeof(strpos), "pos%d", n);
			KvGetVector(kv, strpos, pos);
			while (pos[0] != 0 && pos[1] != 0 && pos[2] != 0) {
				if (RoundFloat(GetVectorDistance(pos, position)) == 0) {
					saved = 1;
					break;
				}
				n++;
				Format(strpos, sizeof(strpos), "pos%d", n);
				KvGetVector(kv, strpos, pos);
			}
			KvRewind(kv);
		}
		if (saved)
			ReplyToCommand(client, "%t", "error_decal_in_file", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT);
		else {
			KvJumpToKey(kv, decalName, true);
			Format(strpos, sizeof(strpos), "pos%d", n);
			KvSetVector(kv, strpos, position);
			KvRewind(kv);
			KeyValuesToFile(kv, path_mapdecals);
			ReplyToCommand(client, "%t", "saved_id", COLOR_DEFAULT, COLOR_GREEN, 1, COLOR_DEFAULT, COLOR_GREEN, index+1, COLOR_DEFAULT);
			new DecalPos = GetConVarInt(md_pos);
			if (DecalPos)
				ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);
			LogAction(client, -1, "\"%L\" saved Decal \"%s\" from Map \"%s\" (Position: %f, %f, %f)", client, decalName, mapName, position[0], position[1], position[2]);
		}	
		CloseHandle(kv);
		return Plugin_Handled;
	}
	ReplyToCommand(client, "%t", "usage_savedecal", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT);
	CloseHandle(kv);
	return Plugin_Handled;
}

public Action:Command_GetAimPos(client, args) {
	
	new Float:pos[3];
	if (GetClientAimTargetEx(client, pos) >= 0) {
		ReplyToCommand(client, "%t", "aimpos",COLOR_DEFAULT, COLOR_GREEN, pos[0], pos[1], pos[2]);
	}
	else {
		ReplyToCommand(client, "%t", "error_entity", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT);
	}	
	return Plugin_Handled;
}

public Action:Command_DecalMenu(client, args) {
	
	decl String:action[64];
	decl String:buffer[128];
	
	new Handle:menu = CreateMenu(DecalMenuHandler);
	Format(buffer, sizeof(buffer), "%T", "decal_menu_title", client);
	SetMenuTitle(menu, buffer);
	if (GetCmdArgs() != 0) {
		GetCmdArg(1, action, sizeof(action));
	}
	
	if (strcmp(action, "admin", false) == 0) {
		SetMenuExitBackButton(menu, true);
		Format(buffer, sizeof(buffer), "%T", "paint_decal", client);
		AddMenuItem(menu, "paintdecal_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "remove_decal", client);
		AddMenuItem(menu, "removedecal_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "list_decal_menu", client);
		AddMenuItem(menu, "listdecal_admin", buffer);
		if (CheckCommandAccess(client, "sm_savedecal_admin", ADMIN_LEVEL_SAVE, false)) {
			Format(buffer, sizeof(buffer), "%T", "save_decal", client);
			AddMenuItem(menu, "savedecal_admin", buffer);
			Format(buffer, sizeof(buffer), "%T", "aim_position_menu", client);
			AddMenuItem(menu, "aimpos_admin", buffer);
		}
	}
	else {
		Format(buffer, sizeof(buffer), "%T", "paint_decal", client);
		AddMenuItem(menu, "paintdecal", buffer);
		Format(buffer, sizeof(buffer), "%T", "remove_decal", client);
		AddMenuItem(menu, "removedecal", buffer);
		Format(buffer, sizeof(buffer), "%T", "list_decal_menu", client);
		AddMenuItem(menu, "listdecal", buffer);
		if (CheckCommandAccess(client, "sm_savedecal", ADMIN_LEVEL_SAVE, false)) {
			Format(buffer, sizeof(buffer), "%T", "save_decal", client);
			AddMenuItem(menu, "savedecal", buffer);
			Format(buffer, sizeof(buffer), "%T", "aim_position_menu", client);
			AddMenuItem(menu, "aimpos", buffer);
		}
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public DecalMenuHandler(Handle:menu, MenuAction:action, param1, param2) {

	/* If an option was selected, tell the client about the item. */
	if (action == MenuAction_Select) {
		decl String:info[64];
		new bool:found = GetMenuItem(menu, param2, info, sizeof(info));
		if (found) {
			if (StrContains(info, "aimpos", false) > -1) {
				FakeClientCommand(param1, "say /aimpos");
				if (StrContains(info, "admin", false) > -1)
					FakeClientCommand(param1, "sm_decalmenu admin");
				else
					Command_DecalMenu(param1, -1);
			}
			else if (StrContains(info, "paintdecal", false) > -1)
				Command_OptionsMenu(param1, info);
			else
				Command_SubMenu(param1, info);
		}
	}
	/* If the menu was cancelled, check for param and redisplay AdminMenu. */
	else if (action == MenuAction_Cancel) {

		if (param2 == MenuCancel_ExitBack) {
			RedisplayAdminMenu(hAdminMenu, param1);
		}
	}
	/* If the menu has ended, destroy it */
	else if (action == MenuAction_End) {

		CloseHandle(menu);
	}
}

public bool:TraceEntityFilterPlayer(entity, contentsMask) {
	
 	return entity > MAXPLAYERS;
}

// Menu Option
public AdminMenu_MapDecals(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength) {

	if (action == TopMenuAction_DisplayOption) {

		Format(buffer, maxlength, "%T", "admin_menu_title", param);
	}
	else if (action == TopMenuAction_SelectOption) {

		FakeClientCommand(param, "sm_decalmenu admin");
	}
}

public SubMenuHandler(Handle:submenu, MenuAction:action, param1, param2) {

	decl String:info[64];
	/* If an option was selected, tell the client about the item. */
	if (action == MenuAction_Select) {

		new bool:found = GetMenuItem(submenu, param2, info, sizeof(info));
		if (found) {
			if (StrContains(info, "savedecal_all", false) > -1) {
				FakeClientCommand(param1, "say /savedecal all");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "savedecal_admin");
				else
					Command_SubMenu(param1, "savedecal");
			}
			else if (StrContains(info, "savedecal_aim", false) > -1) {
				FakeClientCommand(param1, "say /savedecal");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "savedecal_admin");
				else
					Command_SubMenu(param1, "savedecal");
			}
			else if (StrContains(info, "savedecal_last", false) > -1) {
				FakeClientCommand(param1, "say /savedecal last");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "savedecal_admin");
				else
					Command_SubMenu(param1, "savedecal");
			}
			else if (StrContains(info, "removedecal_all", false) > -1) {
				FakeClientCommand(param1, "say /removedecal all");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "removedecal_admin");
				else
					Command_SubMenu(param1, "removedecal");
			}
			else if (StrContains(info, "removedecal_aim", false) > -1) {
				FakeClientCommand(param1, "say /removedecal");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "removedecal_admin");
				else
					Command_SubMenu(param1, "removedecal");
			}
			else if (StrContains(info, "removedecal_last", false) > -1) {
				FakeClientCommand(param1, "say /removedecal last");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "removedecal_admin");
				else
					Command_SubMenu(param1, "removedecal");
			}
			else if (StrContains(info, "listdecal_all", false) > -1) {
				FakeClientCommand(param1, "say /listdecal all");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "listdecal_admin");
				else
					Command_SubMenu(param1, "listdecal");
			}
			else if (StrContains(info, "listdecal_aim", false) > -1) {
				FakeClientCommand(param1, "say /listdecal");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "listdecal_admin");
				else
					Command_SubMenu(param1, "listdecal");
			}
			else if (StrContains(info, "listdecal_last", false) > -1) {
				FakeClientCommand(param1, "say /listdecal last");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "listdecal_admin");
				else
					Command_SubMenu(param1, "listdecal");
			}
			else if (StrContains(info, "listdecal_map", false) > -1) {
				FakeClientCommand(param1, "say /listdecal map");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "listdecal_admin");
				else
					Command_SubMenu(param1, "listdecal");
			}
			else if (StrContains(info, "listdecal_saved", false) > -1) {
				FakeClientCommand(param1, "say /listdecal saved");
				if (StrContains(info, "admin", false) > -1)
					Command_SubMenu(param1, "listdecal_admin");
				else
					Command_SubMenu(param1, "listdecal");
			}
			else
				Command_OptionsMenu(param1, info);
		}
	}
	
	/* If the menu was cancelled, check for info and redisplay previous menu. */
	else if (action == MenuAction_Cancel) {

		if (param2 == MenuCancel_ExitBack) {

			GetMenuItem(submenu, 0, info, sizeof(info));
			if (StrContains(info, "admin", false) > -1) {
				FakeClientCommand(param1, "sm_decalmenu admin");
			}
			else {
				Command_DecalMenu(param1, -1);
			}
		}
	}
	/* If the menu has ended, destroy it */
	else if (action == MenuAction_End) {

		CloseHandle(submenu);
	}
}



/*****************************************************************


		P L U G I N   F U N C T I O N S


*****************************************************************/

public NextPosFromTrie(Handle:trie, String:key[]) {
	
	new pos = 1;
	if (GetTrieValue(trie, key, pos)) {
		pos++;
	}
	SetTrieValue(trie, key, pos);
	return pos;
}

Command_SubMenu(client, String:info[]) {
	
	new Handle:submenu = CreateMenu(SubMenuHandler);
	new DecalPos = GetConVarInt(md_pos);
	decl String:buffer[128];

	if (strcmp(info, "savedecal") == 0) {

		Format(buffer, sizeof(buffer), "%T", "save_decal_title", client);
		SetMenuTitle(submenu, buffer);
		Format(buffer, sizeof(buffer), "%T", "all", client);
		AddMenuItem(submenu, "savedecal_all", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_aim", client);
		AddMenuItem(submenu, "savedecal_aim", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_id", client);
		AddMenuItem(submenu, "savedecal_id", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_name", client);
		AddMenuItem(submenu, "savedecal_name", buffer);
		Format(buffer, sizeof(buffer), "%T", "last_painted", client);
		AddMenuItem(submenu, "savedecal_last", buffer);
	}
	else if (strcmp(info, "savedecal_admin") == 0) {

		Format(buffer, sizeof(buffer), "%T", "save_decal_title", client);
		SetMenuTitle(submenu, buffer);
		Format(buffer, sizeof(buffer), "%T", "all", client);
		AddMenuItem(submenu, "savedecal_all_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_aim", client);
		AddMenuItem(submenu, "savedecal_aim_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_id", client);
		AddMenuItem(submenu, "savedecal_id_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_name", client);
		AddMenuItem(submenu, "savedecal_name_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "last_painted", client);
		AddMenuItem(submenu, "savedecal_last_admin", buffer);
	}
	else if (strcmp(info, "removedecal") == 0) {

		Format(buffer, sizeof(buffer), "%T", "remove_decal_title", client);
		SetMenuTitle(submenu, buffer);
		Format(buffer, sizeof(buffer), "%T", "all", client);
		AddMenuItem(submenu, "removedecal_all", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_aim", client);
		AddMenuItem(submenu, "removedecal_aim", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_id", client);
		AddMenuItem(submenu, "removedecal_id", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_name", client);
		AddMenuItem(submenu, "removedecal_name", buffer);
		Format(buffer, sizeof(buffer), "%T", "last_painted", client);
		AddMenuItem(submenu, "removedecal_last", buffer);
	}
	else if (strcmp(info, "removedecal_admin") == 0) {

		Format(buffer, sizeof(buffer), "%T", "remove_decal_title", client);
		SetMenuTitle(submenu, buffer);
		Format(buffer, sizeof(buffer), "%T", "all", client);
		AddMenuItem(submenu, "removedecal_all_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_aim", client);
		AddMenuItem(submenu, "removedecal_aim_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_id", client);
		AddMenuItem(submenu, "removedecal_id_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_name", client);
		AddMenuItem(submenu, "removedecal_name_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "last_painted", client);
		AddMenuItem(submenu, "removedecal_last_admin", buffer);
	}
	else if (strcmp(info, "listdecal") == 0) {

		Format(buffer, sizeof(buffer), "%T", "list_decal_title", client);
		SetMenuTitle(submenu, buffer);
		Format(buffer, sizeof(buffer), "%T", "all_list", client);
		AddMenuItem(submenu, "listdecal_all", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_aim", client);
		AddMenuItem(submenu, "listdecal_aim", buffer);
		if (DecalPos) {
			Format(buffer, sizeof(buffer), "%T", "by_id", client);
			AddMenuItem(submenu, "listdecal_id", buffer);
		}
		Format(buffer, sizeof(buffer), "%T", "by_name", client);
		AddMenuItem(submenu, "listdecal_name", buffer);
		Format(buffer, sizeof(buffer), "%T", "last_painted", client);
		AddMenuItem(submenu, "listdecal_last", buffer);
		Format(buffer, sizeof(buffer), "%T", "map", client);
		AddMenuItem(submenu, "listdecal_map", buffer);
		Format(buffer, sizeof(buffer), "%T", "saved", client);
		AddMenuItem(submenu, "listdecal_saved", buffer);
	}
	else if (strcmp(info, "listdecal_admin") == 0) {

		Format(buffer, sizeof(buffer), "%T", "list_decal_title", client);
		SetMenuTitle(submenu, buffer);
		Format(buffer, sizeof(buffer), "%T", "all_list", client);
		AddMenuItem(submenu, "listdecal_all_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "by_aim", client);
		AddMenuItem(submenu, "listdecal_aim_admin", buffer);
		if (DecalPos) {
			Format(buffer, sizeof(buffer), "%T", "by_id", client);
			AddMenuItem(submenu, "listdecal_id_admin", buffer);
		}
		Format(buffer, sizeof(buffer), "%T", "by_name", client);
		AddMenuItem(submenu, "listdecal_name_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "last_painted", client);
		AddMenuItem(submenu, "listdecal_last_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "map", client);
		AddMenuItem(submenu, "listdecal_map_admin", buffer);
		Format(buffer, sizeof(buffer), "%T", "saved", client);
		AddMenuItem(submenu, "listdecal_saved_admin", buffer);
	}

	SetMenuExitBackButton(submenu, true);
	SetMenuExitButton(submenu, true);
	DisplayMenu(submenu, client, MENU_TIME_FOREVER);
}

public Command_OptionsMenu(client, String:info[]) {
	
	new Handle:optionsmenu = CreateMenu(OptionsMenuHandler);
	decl String:id[64];
	decl String:buffer[128];
	decl String:decalName[128];
	decl size;
	Format(buffer, sizeof(buffer), "%T", "options_menu_title", client);
	SetMenuTitle(optionsmenu, buffer);
	if (StrContains(info, "id", false) > -1) {
		size = GetArraySize(adt_decal_id);
		for (new i=0; i<size; ++i) {
			new decal = GetArrayCell(adt_decal_id, i);
			GetArrayString(adt_decal_names, decal, decalName, sizeof(decalName));
			if (size>7) {
				IntToString(i+1, id, sizeof(id));
				StrCat(decalName, sizeof(decalName), " (");
				StrCat(decalName, sizeof(decalName), id);
				StrCat(decalName, sizeof(decalName), ")");
			}
			AddMenuItem(optionsmenu, info, decalName);
		}
	}
	else {
		size = GetArraySize(adt_decal_names);
		for (new i=0; i<size; ++i) {
			GetArrayString(adt_decal_names, i, decalName, sizeof(decalName));
			if (size>7) {
				IntToString(i+1, id, sizeof(id));
				StrCat(decalName, sizeof(decalName), " (");
				StrCat(decalName, sizeof(decalName), id);
				StrCat(decalName, sizeof(decalName), ")");
			}
			AddMenuItem(optionsmenu, info, decalName);
		}
	}
	if (size == 0) {
		PrintToChat(client, "%t", "no_decals_in_file", COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		if (StrContains(info, "admin", false) > -1)
			FakeClientCommand(client, "sm_decalmenu admin");
		else
			Command_DecalMenu(client, -1);
	}
	else {
		SetMenuExitBackButton(optionsmenu, true);
		SetMenuExitButton(optionsmenu, true);
		DisplayMenu(optionsmenu, client, MENU_TIME_FOREVER);
	}
}

public OptionsMenuHandler(Handle:optionsmenu, MenuAction:action, param1, param2) {

	decl String:info[64];
	decl String:name[64];
	decl flag;

	/* If an option was selected, tell the client about the item. */
	if (action == MenuAction_Select) {

		new bool:found = GetMenuItem(optionsmenu, param2, info, sizeof(info), flag, name, sizeof(name));
		if (found) {
			if (StrContains(info, "paintdecal") > -1) {
				FakeClientCommand(param1, "say /paintdecal %s", name);
				if (StrContains(info, "admin", false) > -1)
					Command_OptionsMenu(param1, "paintdecal_admin");
				else
					Command_OptionsMenu(param1, "paintdecal");
			}
			else if (StrContains(info, "savedecal_id") > -1) {
				FakeClientCommand(param1, "say /savedecal %d", param2+1);
				if (StrContains(info, "admin", false) > -1)
					Command_OptionsMenu(param1, "savedecal_id_admin");
				else
					Command_OptionsMenu(param1, "savedecal_id");
			}
			else if (StrContains(info, "savedecal_name") > -1) {
				FakeClientCommand(param1, "say /savedecal %s", name);
				if (StrContains(info, "admin", false) > -1)
					Command_OptionsMenu(param1, "savedecal_name_admin");
				else
					Command_OptionsMenu(param1, "savedecal_name");
			}
			else if (StrContains(info, "removedecal_id") > -1) {
				FakeClientCommand(param1, "say /removedecal %d", param2+1);
				if (StrContains(info, "admin", false) > -1)
					Command_OptionsMenu(param1, "removedecal_id_admin");
				else
					Command_OptionsMenu(param1, "removedecal_id");
			}
			else if (StrContains(info, "removedecal_name") > -1) {
				FakeClientCommand(param1, "say /removedecal %s", name);
				if (StrContains(info, "admin", false) > -1)
					Command_OptionsMenu(param1, "removedecal_name_admin");
				else
					Command_OptionsMenu(param1, "removedecal_name");
			}
			else if (StrContains(info, "listdecal_id") > -1) {
				FakeClientCommand(param1, "say /listdecal %d", param2+1);
				if (StrContains(info, "admin", false) > -1)
					Command_OptionsMenu(param1, "listdecal_id_admin");
				else
					Command_OptionsMenu(param1, "listdecal_id");
			}
			else if (StrContains(info, "listdecal_name") > -1) {
				FakeClientCommand(param1, "say /listdecal %s", name);
				if (StrContains(info, "admin", false) > -1)
					Command_OptionsMenu(param1, "listdecal_name_admin");
				else
					Command_OptionsMenu(param1, "listdecal_name");
			}
		}
	}
	
	/* If the menu was cancelled, check for info and redisplay previous menu. */
	else if (action == MenuAction_Cancel) {

		if (param2 == MenuCancel_ExitBack) {

			GetMenuItem(optionsmenu, 0, info, sizeof(info));
			if (StrContains(info, "paintdecal", false) > -1 && StrContains(info, "admin", false) > -1) {
				FakeClientCommand(param1, "sm_decalmenu admin");
			}
			else if (StrContains(info, "paintdecal", false) > -1) {
				Command_DecalMenu(param1, -1);
			}

			if (StrContains(info, "savedecal", false) > -1 && StrContains(info, "admin", false) > -1) {
				Command_SubMenu(param1, "savedecal_admin");
			}
			else if (StrContains(info, "savedecal", false) > -1) {
				Command_SubMenu(param1, "savedecal");
			}

			if (StrContains(info, "removedecal", false) > -1 && StrContains(info, "admin", false) > -1) {
				Command_SubMenu(param1, "removedecal_admin");
			}
			else if (StrContains(info, "removedecal", false) > -1) {
				Command_SubMenu(param1, "removedecal");
			}

			if (StrContains(info, "listdecal", false) > -1 && StrContains(info, "admin", false) > -1) {
				Command_SubMenu(param1, "listdecal_admin");
			}
			else if (StrContains(info, "listdecal", false) > -1) {
				Command_SubMenu(param1, "listdecal");
			}
		}
	}
	/* If the menu has ended, destroy it */
	else if (action == MenuAction_End)
	{
		CloseHandle(optionsmenu);
	}
}

public bool:ReadDecals(client, mode) {
	
	decl String:buffer[PLATFORM_MAX_PATH];
	decl String:download[PLATFORM_MAX_PATH];
	decl Handle:kv;
	decl Handle:vtf;
	new download_style = GetConVarInt(md_download_style);
	// Read Decal config File
	if (mode == READ) {

		kv = CreateKeyValues("Decals");
		FileToKeyValues(kv, path_decals);

		if (!KvGotoFirstSubKey(kv)) {

			LogMessage("CFG File not found: %s", path_decals);
			CloseHandle(kv);
			return false;
		}
		do {

			KvGetSectionName(kv, buffer, sizeof(buffer));
			PushArrayString(adt_decal_names, buffer);
			KvGetString(kv, "path", buffer, sizeof(buffer));
			PushArrayString(adt_decal_paths, buffer);
			new precacheId = PrecacheDecal(buffer, true);
			PushArrayCell(adt_decal_precache, precacheId);
			decl String:decalpath[PLATFORM_MAX_PATH];
			Format(decalpath, sizeof(decalpath), buffer);
			if(download_style == 0)
			{
				Format(download, sizeof(download), "materials/%s.vmt", buffer);
				AddFileToDownloadsTable(download);
			}
			vtf = CreateKeyValues("LightmappedGeneric");
			FileToKeyValues(vtf, download);
			KvGetString(vtf, "$basetexture", buffer, sizeof(buffer), buffer);
			CloseHandle(vtf);
			if(download_style == 0)
			{
				Format(download, sizeof(download), "materials/%s.vtf", buffer);
				AddFileToDownloadsTable(download);
			}
		} while (KvGotoNextKey(kv));
		CloseHandle(kv);
	}
	// Read Map config File
	kv = CreateKeyValues("Positions");
	FileToKeyValues(kv, path_mapdecals);

	if (!KvGotoFirstSubKey(kv)) {

		if (mode == READ) {
			LogMessage("CFG File for Map %s not found", mapName);
		}
		else {
			ReplyToCommand(client, "%t", "cfg_file_not_found", COLOR_DEFAULT, COLOR_GREEN, COLOR_DEFAULT, COLOR_GREEN, mapName, COLOR_DEFAULT);
		}

		CloseHandle(kv);
		return false;
	}
	do {
		KvGetSectionName(kv, buffer, sizeof(buffer));
		new id = FindStringInArray(adt_decal_names, buffer);
		if (id != -1) {

			if (mode == LIST) {
				ReplyToCommand(client, "%t", "list_decal", COLOR_DEFAULT, COLOR_GREEN, buffer);
			}

			new Float:position[3];
			decl String:strpos[8];
			new n=1;
			Format(strpos, sizeof(strpos), "pos%d", n);
			KvGetVector(kv, strpos, position);
			while (position[0] != 0 && position[1] != 0 && position[2] != 0) {
				
				if (mode == READ) {
					PushArrayCell(adt_decal_id, id);
					PushArrayArray(adt_decal_position, _:position);

					if(download_style == 1)
					{
						GetArrayString(adt_decal_paths, id, buffer, sizeof(buffer));
						Format(download, sizeof(download), "materials/%s.vmt", buffer);
						AddFileToDownloadsTable(download);//LogMessage("%d - %s",id,download);
						Format(download, sizeof(download), "materials/%s.vtf", buffer);
						AddFileToDownloadsTable(download);//LogMessage("%d - %s",id,download);
					}
					
				}
				else {
					ReplyToCommand(client, "%t", "list_decal_id", COLOR_DEFAULT, COLOR_GREEN, n);
					new DecalPos = GetConVarInt(md_pos);
					if (DecalPos)
						ReplyToCommand(client, "%t", "decal_position",COLOR_DEFAULT, COLOR_GREEN, position[0], position[1], position[2]);		
				}
				n++;
				Format(strpos, sizeof(strpos), "pos%d", n);
				KvGetVector(kv, strpos, position);
			}	
		}
	} while (KvGotoNextKey(kv));
	CloseHandle(kv);
	return true;
}

TE_SetupBSPDecal(const Float:vecOrigin[3], entity, index) {
	
	TE_Start("BSP Decal");
	TE_WriteVector("m_vecOrigin",vecOrigin);
	TE_WriteNum("m_nEntity",entity);
	TE_WriteNum("m_nIndex",index);
}

FindStringInArrayCase(Handle:array, const String:item[], bool:caseSensitive=true) {
	
	decl String:str[256];
	new size = GetArraySize(array);
	for (new i=0; i<size; ++i) {

		GetArrayString(array, i, str, sizeof(str));
		if (strcmp(str, item, caseSensitive) == 0) {
			return i;
		}
	}
	return -1;
}

GetClientAimTargetEx(client, Float:pos[3]) {

	if (client < 1) {
		return -1;
	}

	decl Float:vAngles[3], Float:vOrigin[3];
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_ALL, RayType_Infinite, TraceEntityFilterPlayer);
	
	if (TR_DidHit(trace)) {
		
		TR_GetEndPosition(pos, trace);
		new entity = TR_GetEntityIndex(trace);
		CloseHandle(trace);
		
		return entity;
	}
	
	CloseHandle(trace);
	
	return -1;
}

void CreateFileIfNotExist(const char[] file)
{
	Handle fileHandle = OpenFile(file, "a");  /* Append */
	if(fileHandle == null)
	{
		CreateDirectory("/addons/sourcemod/configs/map-decals/maps", 755);
		fileHandle = OpenFile(file, "a"); //open again
	}
	delete fileHandle;
}