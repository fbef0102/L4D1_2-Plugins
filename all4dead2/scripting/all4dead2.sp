#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <adminmenu>
#include <left4dhooks>
#include <multicolors>
#include <spawn_infected_nolimit> //https://github.com/fbef0102/L4D1_2-Plugins/tree/master/spawn_infected_nolimit

#define PLUGIN_NAME					"All4Dead"
#define PLUGIN_TAG					"[A4D]"
#define PLUGIN_VERSION				"3.9-2024/3/30"

public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = "James Richardson (grandwazir) & HarryPotter",
	description = "Enables admins to have control over the AI Director and spawn all weapons, melee, items, special infected, and Uncommon Infected without using sv_cheats 1",
	version = PLUGIN_VERSION,
	url = "https://github.com/fbef0102/L4D1_2-Plugins/tree/master/all4dead2"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

#define ENTITY_SAFE_LIMIT 2000 //don't spawn boxes when it's index is above this

// Create ConVar Handles
ConVar notify_players;
ConVar director_panic_forever;

// Menu handlers
TopMenu top_menu;
TopMenu admin_menu;
TopMenuObject spawn_special_infected_menu;
TopMenuObject spawn_uncommon_infected_menu;
TopMenuObject spawn_weapons_menu;
TopMenuObject spawn_melee_weapons_menu;
TopMenuObject spawn_items_menu;
TopMenuObject director_menu;
TopMenuObject config_menu;

// Other stuff
char change_zombie_model_to[128] = "";
Handle refresh_timer = null;
bool automatic_placement = true;
bool g_bSpawnWitchBride;

// Global variables to hold menu position
int g_iSpecialInfectedMenuPosition[MAXPLAYERS+1];
int g_iUInfectedMenuPosition[MAXPLAYERS+1];
int g_iItemMenuPosition[MAXPLAYERS+1];
int g_iWeaponMenuPosition[MAXPLAYERS+1];
int g_iMeleeMenuPosition[MAXPLAYERS+1];

#define ZOMBIESPAWN_Attempts 6

#define	MAX_WEAPONS2		29
static char g_sWeaponModels2[MAX_WEAPONS2][] =
{
	"models/w_models/weapons/w_pistol_B.mdl",
	"models/w_models/weapons/w_desert_eagle.mdl",
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_rifle_ak47.mdl",
	"models/w_models/weapons/w_rifle_sg552.mdl",
	"models/w_models/weapons/w_desert_rifle.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_shotgun_spas.mdl",
	"models/w_models/weapons/w_shotgun.mdl",
	"models/w_models/weapons/w_pumpshotgun_A.mdl",
	"models/w_models/weapons/w_smg_uzi.mdl",
	"models/w_models/weapons/w_smg_a.mdl",
	"models/w_models/weapons/w_smg_mp5.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/weapons/w_sniper_awp.mdl",
	"models/w_models/weapons/w_sniper_military.mdl",
	"models/w_models/weapons/w_sniper_scout.mdl",
	"models/w_models/weapons/w_m60.mdl",
	"models/w_models/weapons/w_grenade_launcher.mdl",
	"models/weapons/melee/w_chainsaw.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_bile_flask.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl",
	"models/w_models/weapons/w_eq_adrenaline.mdl",
	"models/w_models/weapons/w_eq_Medkit.mdl",
	"models/w_models/weapons/w_eq_defibrillator.mdl",
	"models/w_models/weapons/w_eq_explosive_ammopack.mdl",
	"models/w_models/weapons/w_eq_incendiary_ammopack.mdl",
};

#define MODEL_COLA			"models/w_models/weapons/w_cola.mdl"
#define MODEL_GNOME			"models/props_junk/gnome.mdl"

#define MODEL_AMMO_L4D2			"models/props/terror/ammo_stack.mdl"

ArrayList
	g_aMeleeScripts;

StringMap
	g_smMeleeTrans;

public void OnPluginStart() {

	// Translations
	LoadTranslations("all4dead2.phrases");

	director_panic_forever = FindConVar("director_panic_forever");
	
	notify_players = CreateConVar("a4d_notify_players", "1", "Whether or not we announce changes in game.", FCVAR_NOTIFY);	
	AutoExecConfig(true, "all4dead2");	

	RegAdminCmd("a4d_spawn_infected", Command_SpawnInfected, ADMFLAG_ROOT);
	RegAdminCmd("a4d_spawn_uinfected", Command_SpawnUInfected, ADMFLAG_ROOT);
	RegAdminCmd("a4d_spawn_item", Command_SpawnItem, ADMFLAG_ROOT);
	RegAdminCmd("a4d_spawn_weapon", Command_SpawnItem, ADMFLAG_ROOT);

	RegAdminCmd("a4d_force_panic", Command_ForcePanic, ADMFLAG_ROOT);
	RegAdminCmd("a4d_panic_forever", Command_PanicForever, ADMFLAG_ROOT);	

	RegAdminCmd("a4d_enable_notifications", Command_EnableNotifications, ADMFLAG_ROOT);

	if (LibraryExists("adminmenu") && ((top_menu = GetAdminTopMenu()) != null))
		OnAdminMenuReady(top_menu);

	g_smMeleeTrans = new StringMap();
	g_aMeleeScripts = new ArrayList(ByteCountToCells(64));

	g_smMeleeTrans.SetString("fireaxe", "Spawn a fire axe");
	g_smMeleeTrans.SetString("frying_pan", "Spawn a frying pan");
	g_smMeleeTrans.SetString("machete", "Spawn a machete");
	g_smMeleeTrans.SetString("baseball_bat", "Spawn a baseball bat");
	g_smMeleeTrans.SetString("crowbar", "Spawn a crowbar");
	g_smMeleeTrans.SetString("cricket_bat", "Spawn a cricket bat");
	g_smMeleeTrans.SetString("tonfa", "Spawn a police baton");
	g_smMeleeTrans.SetString("katana", "Spawn a katana");
	g_smMeleeTrans.SetString("electric_guitar", "Spawn an electric guitar");
	g_smMeleeTrans.SetString("knife", "Spawn a knife");
	g_smMeleeTrans.SetString("golfclub", "Spawn a golf club");
	g_smMeleeTrans.SetString("shovel", "Spawn a shovel");
	g_smMeleeTrans.SetString("pitchfork", "Spawn a pitchfork");
	g_smMeleeTrans.SetString("riotshield", "Spawn a shield");
	g_smMeleeTrans.SetString("riot_shield", "Spawn a shield");
}

public void OnMapStart() {
	// Precache uncommon infected models
	PrecacheModel("models/infected/common_male_riot.mdl", true);
	PrecacheModel("models/infected/common_male_ceda.mdl", true);
	PrecacheModel("models/infected/common_male_clown.mdl", true);
	PrecacheModel("models/infected/common_male_mud.mdl", true);
	PrecacheModel("models/infected/common_male_roadcrew.mdl", true);
	PrecacheModel("models/infected/common_male_jimmy.mdl", true);
	PrecacheModel("models/infected/common_male_fallen_survivor.mdl", true);

	PrecacheModel(MODEL_AMMO_L4D2, true);

	int max = MAX_WEAPONS2;
	for( int i = 0; i < max; i++ )
	{
		PrecacheModel(g_sWeaponModels2[i], true);
	}

	PrecacheModel(MODEL_GNOME, true);
	PrecacheModel(MODEL_COLA, true);
	
	char mapbuf[32];
	GetCurrentMap(mapbuf, sizeof(mapbuf));	
	if(strcmp(mapbuf, "c6m1_riverbank") == 0)
		g_bSpawnWitchBride = true;
	else
		g_bSpawnWitchBride = false;

	CreateTimer(1.0, Timer_GetMeleeTable, _, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_GetMeleeTable(Handle timer)
{
	delete g_aMeleeScripts;
	g_aMeleeScripts = new ArrayList(ByteCountToCells(64));
	int table = FindStringTable("meleeweapons");
	if (table != INVALID_STRING_TABLE) {
		int num = GetStringTableNumStrings(table);
		char melee[64];
		for (int i; i < num; i++) {
			ReadStringTable(table, i, melee, sizeof melee);
			g_aMeleeScripts.PushString(melee);
		}
	}
	return Plugin_Continue;
}

public void OnPluginEnd() {
	CloseHandle(refresh_timer);
}

/// Register our menus with SourceMod
public void OnAdminMenuReady(Handle menu) {
	// Stop this method being called twice
	if (menu == admin_menu)
		return;
	admin_menu = view_as<TopMenu>(menu);
	// Add a category to the SourceMod menu called "All4Dead Commands"
	AddToTopMenu(admin_menu, "All4Dead Commands", TopMenuObject_Category, Menu_CategoryHandler, INVALID_TOPMENUOBJECT);
	// Get a handle for the catagory we just added so we can add items to it
	TopMenuObject a4d_menu = FindTopMenuCategory(admin_menu, "All4Dead Commands");
	// Don't attempt to add items to the category if for some reason the catagory doesn't exist
	if (a4d_menu == INVALID_TOPMENUOBJECT) 
		return;
	// The order that items are added to menus has no relation to the order that they appear. Items are sorted alphabetically automatically.
	// Assign the menus to global values so we can easily check what a menu is when it is chosen.
	director_menu = AddToTopMenu(admin_menu, "a4d_director_menu", TopMenuObject_Item, Menu_TopItemHandler, a4d_menu, "a4d_director_menu", ADMFLAG_ROOT);
	config_menu = AddToTopMenu(admin_menu, "a4d_config_menu", TopMenuObject_Item, Menu_TopItemHandler, a4d_menu, "a4d_config_menu", ADMFLAG_ROOT);
	spawn_special_infected_menu = AddToTopMenu(admin_menu, "a4d_spawn_special_infected_menu", TopMenuObject_Item, Menu_TopItemHandler, a4d_menu, "a4d_spawn_special_infected_menu", ADMFLAG_ROOT);
	spawn_melee_weapons_menu = AddToTopMenu(admin_menu, "a4d_spawn_melee_weapons_menu", TopMenuObject_Item, Menu_TopItemHandler, a4d_menu, "a4d_spawn_melee_weapons_menu", ADMFLAG_ROOT);
	spawn_weapons_menu = AddToTopMenu(admin_menu, "a4d_spawn_weapons_menu", TopMenuObject_Item, Menu_TopItemHandler, a4d_menu, "a4d_spawn_weapons_menu", ADMFLAG_ROOT);
	spawn_items_menu = AddToTopMenu(admin_menu, "a4d_spawn_items_menu", TopMenuObject_Item, Menu_TopItemHandler, a4d_menu, "a4d_spawn_items_menu", ADMFLAG_ROOT);
	spawn_uncommon_infected_menu = AddToTopMenu(admin_menu, "a4d_spawn_uncommon_infected_menu", TopMenuObject_Item, Menu_TopItemHandler, a4d_menu, "a4d_spawn_uncommon_infected_menu", ADMFLAG_ROOT);
}

/// Handles the top level "All4Dead" category and how it is displayed on the core admin menu
int Menu_CategoryHandler(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int client, char[] buffer, int maxlength) {
	if (action == TopMenuAction_DisplayTitle)
		Format(buffer, maxlength, Translate(client, "%t", "All4Dead Commands"));
	else if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, Translate(client, "%t", "All4Dead Commands"));

	return 0;
}
/// Handles what happens someone opens the "All4Dead" category from the menu.
int Menu_TopItemHandler(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int client, char[] buffer, int maxlength) {
/* When an item is displayed to a player tell the menu to Format the item */
	if (action == TopMenuAction_DisplayOption) {
		if (object_id == director_menu)
			Format(buffer, maxlength, Translate(client, "%t", "Director Commands"));
		else if (object_id == spawn_special_infected_menu)
			Format(buffer, maxlength, Translate(client, "%t", "Spawn Special Infected"));
		else if (object_id == spawn_uncommon_infected_menu)
			Format(buffer, maxlength, Translate(client, "%t", "Spawn Uncommon Infected"));
		else if (object_id == spawn_melee_weapons_menu)
			Format(buffer, maxlength, Translate(client, "%t", "Spawn Melee Weapons"));
		else if (object_id == spawn_weapons_menu)
			Format(buffer, maxlength, Translate(client, "%t", "Spawn Weapons"));
		else if (object_id == spawn_items_menu)
			Format(buffer, maxlength, Translate(client, "%t", "Spawn Items"));
		else if (object_id == config_menu)
			Format(buffer, maxlength, Translate(client, "%t", "Configuration Options"));
	} else if (action == TopMenuAction_SelectOption) {
		if (object_id == director_menu)
			Menu_CreateDirectorMenu(client);
		else if (object_id == spawn_special_infected_menu)
			Menu_CreateSpecialInfectedMenu(client);
		else if (object_id == spawn_uncommon_infected_menu)
			Menu_CreateUInfectedMenu(client);
		else if (object_id == spawn_melee_weapons_menu)
			Menu_CreateMeleeWeaponMenu(client);
		else if (object_id == spawn_weapons_menu)
			Menu_CreateWeaponMenu(client);
		else if (object_id == spawn_items_menu)
			Menu_CreateItemMenu(client);
		else if (object_id == config_menu)
			Menu_CreateConfigMenu(client);
	}

	return 0;
}

// Infected spawning functions

/// Creates the infected spawning menu when it is selected from the top menu and displays it to the client.
void Menu_CreateSpecialInfectedMenu(int client) {
	Menu menu;
	menu = new Menu(Menu_SpawnSInfectedHandler);
	 
	menu.SetTitle(Translate(client, "%t", "Spawn Special Infected"));
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	if (automatic_placement)
		menu.AddItem("ap", Translate(client, "%t", "Disable automatic placement"));
	else 
		menu.AddItem("ap", Translate(client, "%t", "Enable automatic placement"));
	menu.AddItem("st", Translate(client, "%t", "Spawn a tank"));
	menu.AddItem("sw", Translate(client, "%t", "Spawn a witch"));
	menu.AddItem("sb", Translate(client, "%t", "Spawn a boomer"));
	menu.AddItem("sh", Translate(client, "%t", "Spawn a hunter"));
	menu.AddItem("ss", Translate(client, "%t", "Spawn a smoker"));
	menu.AddItem("sp", Translate(client, "%t", "Spawn a spitter"));
	menu.AddItem("sj", Translate(client, "%t", "Spawn a jockey"));
	menu.AddItem("sc", Translate(client, "%t", "Spawn a charger"));
	menu.AddItem("sb", Translate(client, "%t", "Spawn a mob"));
	menu.DisplayAt(client, g_iSpecialInfectedMenuPosition[client], MENU_TIME_FOREVER);
}
/// Handles callbacks from a client using the spawning menu.
int Menu_SpawnSInfectedHandler(Menu menu, MenuAction action, int cindex, int itempos) {
	// When a player selects an item do this.		
	if (action == MenuAction_Select) {
		switch (itempos) {
			case 0:
				if (automatic_placement) 
					Do_EnableAutoPlacement(cindex, false); 
				else
					Do_EnableAutoPlacement(cindex, true);
			case 1:
				Do_SpawnInfected(cindex, "tank");
			case 2:
				Do_SpawnWitch(cindex, automatic_placement);
			case 3:
				Do_SpawnInfected(cindex, "boomer");
			case 4:
				Do_SpawnInfected(cindex, "hunter");
			case 5:
				Do_SpawnInfected(cindex, "smoker");
			case 6:
				Do_SpawnInfected(cindex, "spitter");
			case 7:
				Do_SpawnInfected(cindex, "jockey");
			case 8:
				Do_SpawnInfected(cindex, "charger");
			case 9:
				Do_SpawnInfected_Old(cindex, "mob", false);
		}
		g_iSpecialInfectedMenuPosition[cindex] = menu.Selection;
		// If none of the above matches show the menu again
		Menu_CreateSpecialInfectedMenu(cindex);
	// If someone closes the menu - close the menu
	} else if (action == MenuAction_End)
		delete menu;
	// If someone presses 'back' (8), return to main All4Dead menu */
	else if (action == MenuAction_Cancel)
		if (itempos == MenuCancel_ExitBack && admin_menu != null)
			admin_menu.Display( cindex, TopMenuPosition_LastCategory);

	return 0;
}

/// Creates the infected spawning menu when it is selected from the top menu and displays it to the client.
void Menu_CreateUInfectedMenu(int client) {
	Menu menu = new Menu(Menu_SpawnUInfectedHandler);
	menu.SetTitle(Translate(client, "%t", "Spawn Uncommon Infected"));
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	if (automatic_placement)
		menu.AddItem("ap", Translate(client, "%t", "Disable automatic placement"));
	else 
		menu.AddItem("ap", Translate(client, "%t", "Enable automatic placement"));
	menu.AddItem("s1", Translate(client, "%t", "Spawn a riot zombie"));
	menu.AddItem("s2", Translate(client, "%t", "Spawn a ceda zombie"));
	menu.AddItem("s3", Translate(client, "%t", "Spawn a clown zombie"));
	menu.AddItem("s4", Translate(client, "%t", "Spawn a mudmen zombie"));
	menu.AddItem("s5", Translate(client, "%t", "Spawn a roadworker zombie"));
	menu.AddItem("s6", Translate(client, "%t", "Spawn a jimmie gibbs zombie"));
	menu.AddItem("s7", Translate(client, "%t", "Spawn a fallen survivor zombie"));
	menu.DisplayAt(client, g_iUInfectedMenuPosition[client], MENU_TIME_FOREVER);
}
/// Handles callbacks from a client using the spawning menu.
int Menu_SpawnUInfectedHandler(Menu menu, MenuAction action, int cindex, int itempos) {
	// When a player selects an item do this.		
	if (action == MenuAction_Select) {
		switch (itempos) {
			case 0:
				if (automatic_placement) 
					Do_EnableAutoPlacement(cindex, false); 
				else
					Do_EnableAutoPlacement(cindex, true);
			case 1:
				Do_SpawnUncommonInfected(cindex, 0);
			case 2:
				Do_SpawnUncommonInfected(cindex, 1);
			case 3:
				Do_SpawnUncommonInfected(cindex, 2);
			case 4:
				Do_SpawnUncommonInfected(cindex, 3);
			case 5:
				Do_SpawnUncommonInfected(cindex, 4);
			case 6:
				Do_SpawnUncommonInfected(cindex, 5);
			case 7:
				Do_SpawnUncommonInfected(cindex, 6);
		}
		g_iUInfectedMenuPosition[cindex] = menu.Selection;
		// If none of the above matches show the menu again
		Menu_CreateUInfectedMenu(cindex);
	// If someone closes the menu - close the menu
	} else if (action == MenuAction_End)
		delete menu;
	// If someone presses 'back' (8), return to main All4Dead menu */
	else if (action == MenuAction_Cancel)
		if (itempos == MenuCancel_ExitBack && admin_menu != null)
			admin_menu.Display( cindex, TopMenuPosition_LastCategory);
	
	return 0;
}

/// Sourcemod Action for the SpawnInfected command.
Action Command_SpawnInfected(int client, int args) { 
	if (client == 0)
	{
		PrintToServer("[TS] This Command cannot be used by server.");
		return Plugin_Handled;
	}

	if (args < 1) {
		ReplyToCommand(client, "Usage: a4d_spawn_infected <infected_type> (does not work for uncommon infected, use a4d_spawn_uinfected instead)"); 
	} else {
		char type[16];
		GetCmdArg(1, type, sizeof(type));
		if (strcmp(type, "zombie") == 0)
			Do_SpawnInfected_Old(client, "zombie", true);
		else if(strcmp(type, "mob") == 0)
			Do_SpawnInfected_Old(client, "mob", false);
		else if(strcmp(type, "witch") == 0)
			Do_SpawnWitch(client, automatic_placement);
		else
			Do_SpawnInfected(client, type);
	}
	return Plugin_Handled;
}

/// Sourcemod Action for the SpawnUncommonInfected command.
Action Command_SpawnUInfected(int client, int args) { 
	if (client == 0)
	{
		PrintToServer("[TS] This Command cannot be used by server.");
		return Plugin_Handled;
	}

	if (args < 1) {
		ReplyToCommand(client, "Usage: a4d_spawn_uinfected <riot|ceda|clown|mud|roadcrew|jimmy>"); 
	} else {
		char type[32];
		GetCmdArg(1, type, sizeof(type));
		int number;
		if (strcmp(type, "riot", false) == 0) number = 0;
		else if (strcmp(type, "ceda", false) == 0) number = 1;
		else if (strcmp(type, "clown", false) == 0) number = 2;
		else if (strcmp(type, "mud", false) == 0) number = 3;
		else if (strcmp(type, "roadcrew", false) == 0) number = 4;
		else if (strcmp(type, "jimmy", false) == 0) number = 5;
		else if (strcmp(type, "fallen", false) == 0) number = 6;
		Do_SpawnUncommonInfected(client, number);
	}
	return Plugin_Handled;
}

/**
 * <summary>
 * 	Spawns one of the specified infected using the z_spawn command. 
 * </summary>
 * <param name="type">
 * 	The type of infected to spawn
 * </param>
 * <remarks>
 * 	The infected will spawn either at the crosshair of the spawning player
 * 	or at a location automatically decided by the AI Director if auto_placement
 * 	is true. Automatically falls back to a fake client if the client requesting
 * 	the action is the console.
 * </remarks>
*/
void Do_SpawnInfected(int client, const char[] type) 
{
	if(client == 0)
	{
		return;
	}
	
	if(RealFreePlayersOnInfected())
	{
		Do_SpawnInfected_Old(client, type, false);
		return;
	}

	if (GetClientCount(false) >= MaxClients)
	{
		CPrintToChat(client, "%T", "Not enough player slots", client);
		return;
	}

	int zombieclass;
	if (strcmp(type, "tank") == 0)
		zombieclass = 8;
	else if (strcmp(type, "smoker") == 0)
		zombieclass = 1;
	else if (strcmp(type, "boomer") == 0)
		zombieclass = 2;
	else if (strcmp(type, "hunter") == 0)
		zombieclass = 3;
	else if (strcmp(type, "spitter") == 0)
		zombieclass = 4;
	else if (strcmp(type, "jockey") == 0)
		zombieclass = 5;
	else if (strcmp(type, "charger") == 0)
		zombieclass = 6;

	float vPos[3], vAng[3] = {0.0, 0.0, 0.0};
	if (automatic_placement == true)
	{
		int survivor = L4D_GetHighestFlowSurvivor();
		if(survivor <= 0 || L4D_GetRandomPZSpawnPosition(survivor, zombieclass, 5, vPos) == false)
		{
			PrintToChat(client, "%T", "Could not find a valid spawn position for S.I. in 5 tries", client);
			return;
		}
	}
	else
	{
		if( !SetTeleportEndPoint(client, vPos, vAng) ) {
			PrintToChat(client, "%T", "Can not spawn, please try again", client);
			return;
		}
	}

	int bot = 0;
	switch(zombieclass)
	{
		case 1:
		{
			bot = NoLimit_CreateInfected("smoker", vPos, NULL_VECTOR);
		}
		case 2:
		{
			bot = NoLimit_CreateInfected("boomer", vPos, NULL_VECTOR);
		}
		case 3:
		{
			bot = NoLimit_CreateInfected("hunter", vPos, NULL_VECTOR);
		}
		case 4:
		{
			bot = NoLimit_CreateInfected("spitter", vPos, NULL_VECTOR);
		}
		case 5:
		{
			bot = NoLimit_CreateInfected("jockey", vPos, NULL_VECTOR);
		}
		case 6:
		{
			bot = NoLimit_CreateInfected("charger", vPos, NULL_VECTOR);
		}
		case 8:
		{
			bot = NoLimit_CreateInfected("tank", vPos, NULL_VECTOR);
		}		
	}

	if (bot > 0)
	{
		if(notify_players.BoolValue) CPrintToChatAll("%t", "has been spawned", type);
		LogAction(client, -1, "[NOTICE]: (%L) has spawned a %s", client, type);
	}
	else
	{
		CPrintToChat(client, "%T", "Not enough player slots", client);
	}
}

void Do_SpawnInfected_Old(int client, const char[] type, bool spawning_uncommon ) {

	char arguments[16];
	if (automatic_placement == true && !spawning_uncommon)
		Format(arguments, sizeof(arguments), "%s %s", type, "auto");
	else
		Format(arguments, sizeof(arguments), "%s", type);

	// If we are spawning from the console make sure we force auto placement on	
	if (client == 0) {
		return;
	} else if (spawning_uncommon) 
	{
		float vPos[3], vAng[3] = {0.0, 0.0, 0.0};
		if (automatic_placement == true)
		{
			int survivor = L4D_GetHighestFlowSurvivor();
			if(survivor <= 0 || L4D_GetRandomPZSpawnPosition(survivor, view_as<int>(L4D2ZombieClass_Hunter), 5, vPos) == false)
			{
				PrintToChat(client, "%T", "Could not find a valid spawn position for zombie in 5 tries", client);
				return;
			}
		}
		else
		{
			if( !SetTeleportEndPoint(client, vPos, vAng) ) {
				PrintToChat(client, "%T", "Can not spawn, please try again", client);
				return;
			}
		}

		int zombie = CreateEntityByName("infected");
		if (CheckIfEntitySafe( zombie ) == false)
		{
			CPrintToChat(client, "%T", "Too many enities on server", client);
			return;
		}

		SetEntityModel(zombie, change_zombie_model_to);
		int ticktime = RoundToNearest( GetGameTime() / GetTickInterval()  ) + 5;
		SetEntProp(zombie, Prop_Data, "m_nNextThinkTick", ticktime);
		DispatchSpawn(zombie);
		ActivateEntity(zombie);
		TeleportEntity(zombie, vPos, NULL_VECTOR, NULL_VECTOR);
		if(notify_players.BoolValue) CPrintToChatAll("%t", "has been spawned", type);
		LogAction(client, -1, "[NOTICE]: (%L) has spawned a %s", client, type);
		return;
	} else {
		StripAndExecuteClientCommand(client, "z_spawn_old", arguments);
	}
	if(notify_players.BoolValue) CPrintToChatAll("%t", "has been spawned", type);
	LogAction(client, -1, "[NOTICE]: (%L) has spawned a %s", client, type);
	//PrintToChatAll("Spawned a %s with automatic placement %b and uncommon %b", type, automatic_placement, spawning_uncommon);
}

void Do_SpawnWitch(const int client, const bool bAutoSpawn)
{
	float vPos[3], vAng[3] = {0.0, 0.0, 0.0};
	if (bAutoSpawn) {
		
		int survivor = L4D_GetHighestFlowSurvivor();
		if(survivor <= 0 || L4D_GetRandomPZSpawnPosition(survivor,7,ZOMBIESPAWN_Attempts,vPos) == false) {
			PrintToChat(client, "%T", "Can not spawn witch in tries at this moment", client, ZOMBIESPAWN_Attempts);
			return;
		}
	} 
	else {
		if( !SetTeleportEndPoint(client, vPos, vAng) ) {
			PrintToChat(client, "%T", "Can not spawn, please try again", client);
			return;
		}
	}

	if( g_bSpawnWitchBride ) {
		L4D2_SpawnWitchBride(vPos,NULL_VECTOR);
	}
	else {
		L4D2_SpawnWitch(vPos,NULL_VECTOR);
	}

	if(notify_players.BoolValue) CPrintToChatAll("%t", "has been spawned", "witch");
	LogAction(client, -1, "[NOTICE]: (%L) has spawned a witch", client);
}

void Do_SpawnUncommonInfected(int client, int type) {
	char model[128];
	switch (type) {
		case 0:
			Format(model, sizeof(model), "models/infected/common_male_riot.mdl");
		case 1:
			Format(model, sizeof(model), "models/infected/common_male_ceda.mdl");
		case 2:
			Format(model, sizeof(model), "models/infected/common_male_clown.mdl");
		case 3:
			Format(model, sizeof(model), "models/infected/common_male_mud.mdl");
		case 4:
			Format(model, sizeof(model), "models/infected/common_male_roadcrew.mdl");
		case 5:
			Format(model, sizeof(model), "models/infected/common_male_jimmy.mdl");
		case 6:
			Format(model, sizeof(model), "models/infected/common_male_fallen_survivor.mdl");
	}
	change_zombie_model_to = model;
	Do_SpawnInfected_Old(client, "zombie", true);
}

/**
 * <summary>
 * 	Allows (or disallows) the AI Director to place spawned infected automatically.
 * </summary>
 * <remarks>
 * 	If this is enabled the director will place mobs outside the players sight so 
 * 	it will not look like they are magically appearing. This only affects zombies
 * 	spawned through z_spawn.
 * </remarks>
*/
void Do_EnableAutoPlacement(int client, bool value) {
	automatic_placement = value;
	if (notify_players.BoolValue)
	{
		if (value == true)
			CPrintToChat(client, "%T", "Automatic placement of spawned infected has been enabled", client);
		else
			CPrintToChat(client, "%T", "Automatic placement of spawned infected has been disabled", client);
	}
	//LogAction(client, -1, "(%L) set %s to %i", client, "a4d_automatic_placement", value);	
}

// Item spawning functions

/// Creates the item spawning menu when it is selected from the top menu and displays it to the client */
void Menu_CreateItemMenu(int client) {
	Menu menu = new Menu(Menu_SpawnItemsHandler);
	menu.SetTitle(Translate(client, "%t", "Spawn Items"));
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.AddItem("sd", Translate(client, "%t", "Spawn a defibrillator"));
	menu.AddItem("sm", Translate(client, "%t", "Spawn a medkit"));
	menu.AddItem("sp", Translate(client, "%t", "Spawn some pills"));
	menu.AddItem("sa", Translate(client, "%t", "Spawn some adrenaline"));
	menu.AddItem("sv", Translate(client, "%t", "Spawn a molotov"));
	menu.AddItem("sb", Translate(client, "%t", "Spawn a pipe bomb"));
	menu.AddItem("sb", Translate(client, "%t", "Spawn a bile jar"));
	menu.AddItem("sg", Translate(client, "%t", "Spawn a gas tank"));
	menu.AddItem("st", Translate(client, "%t", "Spawn a firework"));
	menu.AddItem("so", Translate(client, "%t", "Spawn a propane tank"));
	menu.AddItem("sa", Translate(client, "%t", "Spawn an oxygen tank"));
	menu.AddItem("si", Translate(client, "%t", "Spawn an ammo pile"));
	menu.AddItem("sn", Translate(client, "%t", "Spawn laser sight pack"));
	menu.AddItem("se", Translate(client, "%t", "Spawn incendiary ammo"));
	menu.AddItem("sf", Translate(client, "%t", "Spawn explosive ammo"));
	menu.AddItem("sg", Translate(client, "%t", "Spawn a gnome"));
	menu.AddItem("sh", Translate(client, "%t", "Spawn cola bottles"));
	menu.DisplayAt( client, g_iItemMenuPosition[client], MENU_TIME_FOREVER);
}
/// Handles callbacks from a client using the spawn item menu.
int Menu_SpawnItemsHandler(Menu menu, MenuAction action, int cindex, int itempos) {
	if (action == MenuAction_Select) {
		switch (itempos) {
			case 0: {
				Do_SpawnItem(cindex, "defibrillator");
			} case 1: {
				Do_SpawnItem(cindex, "first_aid_kit");
			} case 2: {
				Do_SpawnItem(cindex, "pain_pills");
			} case 3: {
				Do_SpawnItem(cindex, "adrenaline");
			} case 4: {
				Do_SpawnItem(cindex, "molotov");
			} case 5: {
				Do_SpawnItem(cindex, "pipe_bomb");
			} case 6: {
				Do_SpawnItem(cindex, "vomitjar");
			} case 7: {
				Do_SpawnItem(cindex, "gascan");
			} case 8: {
				Do_SpawnItem(cindex, "fireworkcrate");
			} case 9: {
				Do_SpawnItem(cindex, "propanetank");
			} case 10: {
				Do_SpawnItem(cindex, "oxygentank");
			} case 11: {
				float location[3];
				if (!Misc_TraceClientViewToLocation(cindex, location)) {
					GetClientAbsOrigin(cindex, location);
				}
				Do_CreateEntity(cindex, "weapon_ammo_spawn", MODEL_AMMO_L4D2, location, false);
			} case 12: {
				float location[3];
				if (!Misc_TraceClientViewToLocation(cindex, location)) {
					GetClientAbsOrigin(cindex, location);
				}
				Do_CreateEntity(cindex, "upgrade_laser_sight", "PROVIDED", location, false);
			} case 13: {
				Do_SpawnItem(cindex, "weapon_upgradepack_incendiary");
			} case 14: {
				Do_SpawnItem(cindex, "weapon_upgradepack_explosive");	
			} case 15: {
				Do_SpawnItem(cindex, "gnome");	
			} case 16: {
				Do_SpawnItem(cindex, "cola_bottles");	
			}
		}
		g_iItemMenuPosition[cindex] = menu.Selection;
		Menu_CreateItemMenu(cindex);
	} else if (action == MenuAction_End) {
		delete menu;
	} else if (action == MenuAction_Cancel) {
		if (itempos == MenuCancel_ExitBack && admin_menu != null)
			admin_menu.Display( cindex, TopMenuPosition_LastCategory);
	}

	return 0;
}
/// Sourcemod Action for the Do_SpawnItem command.
Action Command_SpawnItem(int client, int args) { 
	if (client == 0)
	{
		PrintToServer("[TS] This Command cannot be used by server.");
		return Plugin_Handled;
	}
	
	if (args < 1) {
		ReplyToCommand(client, "Usage: a4d_spawn_item <item_type>");
	} else {
		char type[16];
		GetCmdArg(1, type, sizeof(type));
		Do_SpawnItem(client, type);
	}
	return Plugin_Handled;
}

/**
 * <summary>
 * 	Spawns one of the specified type of item using the give command. 
 * </summary>
 * <param name="type">
 * 	The type of item to spawn
 * </param>
 * <remarks>
 * 	The infected will spawn either at the crosshair of the spawning player
 * 	or at a location automatically decided by the AI Director if auto_placement
 * 	is true. Slightly misleadingly named this function is used for both items and weapons.
 * </remarks>
*/
void Do_SpawnItem(int client, const char[] type) {

	if (client == 0) {
		ReplyToCommand(client, "Can not use this command from the console."); 
	} else {
		StripAndExecuteClientCommand(client, "give", type);
		if(notify_players.BoolValue) CPrintToChat(client, "%T", "has been spawned", client, type);
		LogAction(client, -1, "[NOTICE]: (%L) has spawned a %s", client, type);
	}
}

void Do_CreateEntity(int client, const char[] name, const char[] model, float location[3], const bool zombie) {
	int entity = CreateEntityByName(name);
	if (CheckIfEntitySafe( entity ) == false)
	{
		CPrintToChat(client, "%T", "Too many enities on server", client);
		return;
	}

	if (strcmp(model, "PROVIDED") != 0)
		SetEntityModel(entity, model);
	DispatchSpawn(entity);
	if (zombie) {
		int ticktime = RoundToNearest( GetGameTime() / GetTickInterval() ) + 5;
		SetEntProp(zombie, Prop_Data, "m_nNextThinkTick", ticktime);
		location[2] -= 25.0; // reduce the 'drop' effect
	}
	// Starts animation on whatever we spawned - necessary for mobs
	ActivateEntity(entity);
	// Teleport the entity to the client's crosshair
	TeleportEntity(entity, location, NULL_VECTOR, NULL_VECTOR);
	LogAction(client, -1, "[NOTICE]: (%L) has created a %s (%s)", client, name, model);
}

// Weapon Spawning functions

/// Creates the weapon spawning menu when it is selected from the top menu and displays it to the client.
void Menu_CreateWeaponMenu(int client) {
	Menu menu = new Menu(Menu_SpawnWeaponHandler);
	menu.SetTitle(Translate(client, "%t", "Spawn Weapons"));
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	
	menu.AddItem("s1", Translate(client, "%t", "Spawn a pistol"));
	menu.AddItem("s2", Translate(client, "%t", "Spawn a magnum"));
	menu.AddItem("s3", Translate(client, "%t", "Spawn a pumpshotgun"));
	menu.AddItem("s4", Translate(client, "%t", "Spawn a shotgun chrome"));
	menu.AddItem("s5", Translate(client, "%t", "Spawn a sub machine gun"));
	menu.AddItem("s6", Translate(client, "%t", "Spawn a silenced smg"));
	menu.AddItem("s7", Translate(client, "%t", "Spawn a mp5"));
	menu.AddItem("s8", Translate(client, "%t", "Spawn an assault rifle"));
	menu.AddItem("s9", Translate(client, "%t", "Spawn a sg552 rifle"));
	menu.AddItem("s0", Translate(client, "%t", "Spawn an AK74"));
	menu.AddItem("sa", Translate(client, "%t", "Spawn a desert rifle"));
	menu.AddItem("sb", Translate(client, "%t", "Spawn a shotgun spas"));
	menu.AddItem("sc", Translate(client, "%t", "Spawn an auto shotgun"));
	menu.AddItem("sd", Translate(client, "%t", "Spawn a hunting rifle"));
	menu.AddItem("se", Translate(client, "%t", "Spawn a military sniper"));
	menu.AddItem("sf", Translate(client, "%t", "Spawn a scout"));
	menu.AddItem("sg", Translate(client, "%t", "Spawn an awp"));
	menu.AddItem("sh", Translate(client, "%t", "Spawn a grenade launcher"));
	menu.AddItem("si", Translate(client, "%t", "Spawn a m60"));
	menu.DisplayAt( client,  g_iWeaponMenuPosition[client], MENU_TIME_FOREVER);
}
/// Handles callbacks from a client using the spawn weapon menu.
int Menu_SpawnWeaponHandler(Menu menu, MenuAction action, int cindex, int itempos) {
	if (action == MenuAction_Select) {
		switch (itempos) {
			case 0: {
				Do_SpawnItem(cindex, "pistol");
			} case 1: {
				Do_SpawnItem(cindex, "pistol_magnum");
			} case 2: {
				Do_SpawnItem(cindex, "pumpshotgun");
			} case 3: {
				Do_SpawnItem(cindex, "shotgun_chrome");
			} case 4: {
				Do_SpawnItem(cindex, "smg");
			} case 5: {
				Do_SpawnItem(cindex, "smg_silenced");
			} case 6: {
				Do_SpawnItem(cindex, "smg_mp5"); 
			} case 7: {
				Do_SpawnItem(cindex, "rifle");
			} case 8: {
				Do_SpawnItem(cindex, "rifle_sg552");
			} case 9: {
				Do_SpawnItem(cindex, "rifle_ak47");
			} case 10: {
				Do_SpawnItem(cindex, "rifle_desert");
			} case 11: {
				Do_SpawnItem(cindex, "shotgun_spas");
			} case 12: {
				Do_SpawnItem(cindex, "autoshotgun");
			} case 13: {
				Do_SpawnItem(cindex, "hunting_rifle");
			} case 14: {
				Do_SpawnItem(cindex, "sniper_military");
			} case 15: {
				Do_SpawnItem(cindex, "sniper_scout");
			} case 16: {
				Do_SpawnItem(cindex, "sniper_awp");
			} case 17: {
				Do_SpawnItem(cindex, "grenade_launcher");
			} case 18: {
				Do_SpawnItem(cindex, "rifle_m60");
			}
		}
		g_iWeaponMenuPosition[cindex] = menu.Selection;
		Menu_CreateWeaponMenu(cindex);
	} else if (action == MenuAction_End)
		delete menu;
	/* If someone presses 'back' (8), return to main All4Dead menu */
	else if (action == MenuAction_Cancel)
		if (itempos == MenuCancel_ExitBack && admin_menu != null)
			admin_menu.Display( cindex, TopMenuPosition_LastCategory);

	return 0;
}

/// Creates the melee weapon spawning menu when it is selected from the top menu and displays it to the client.
void Menu_CreateMeleeWeaponMenu(int client) {
	Menu menu = new Menu(Menu_SpawnMeleeWeaponHandler);
	menu.SetTitle(Translate(client, "%t", "Spawn Melee Weapons"));
	menu.ExitBackButton = true;
	menu.ExitButton = true;

	menu.AddItem("chainsaw", Translate(client, "%t", "Spawn a chainsaw"));
	
	char melee[64];
	char trans[64];
	int count = g_aMeleeScripts.Length;
	for (int i; i < count; i++) 
	{
		g_aMeleeScripts.GetString(i, melee, sizeof melee);
		if (!g_smMeleeTrans.GetString(melee, trans, sizeof trans))
			strcopy(trans, sizeof trans, melee);

		if(TranslationPhraseExists(trans))
		{
			menu.AddItem(melee, Translate(client, "%t", trans));
		}
		else
		{
			menu.AddItem(melee, trans);
		}
	}
	
	menu.DisplayAt( client, g_iMeleeMenuPosition[client], MENU_TIME_FOREVER);
}
/// Handles callbacks from a client using the spawn weapon menu.
int Menu_SpawnMeleeWeaponHandler(Menu menu, MenuAction action, int cindex, int itempos) 
{
	if (action == MenuAction_Select) 
	{
		char item[64];
		menu.GetItem(itempos, item, sizeof item);

		Do_SpawnItem(cindex, item);

		g_iMeleeMenuPosition[cindex] = menu.Selection;
		Menu_CreateMeleeWeaponMenu(cindex);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (itempos == MenuCancel_ExitBack && admin_menu != null)
			admin_menu.Display( cindex, TopMenuPosition_LastCategory);
	}

	return 0;
}

// Additional director commands

/// Creates the director commands menu when it is selected from the top menu and displays it to the client.
void Menu_CreateDirectorMenu(int client) {
	Menu menu = new Menu(Menu_DirectorMenuHandler);
	menu.SetTitle(Translate(client, "%t", "Director Commands"));
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.AddItem("fp", Translate(client, "%t", "Force a panic event to start"));
	if (director_panic_forever.BoolValue) { menu.AddItem("pf", Translate(client, "%t", "End non-stop panic events")); } else { menu.AddItem("pf", Translate(client, "%t", "Force non-stop panic events")); }
	menu.Display( client, MENU_TIME_FOREVER);
}
/// Handles callbacks from a client using the director commands menu.
int Menu_DirectorMenuHandler(Menu menu, MenuAction action, int cindex, int itempos) {
	if (action == MenuAction_Select) {
		switch (itempos) {
			case 0: {
				Do_ForcePanic(cindex);
			} case 1: {
				if (director_panic_forever.BoolValue) 
					Do_PanicForever(cindex, false); 
				else
					Do_PanicForever(cindex, true);
			}
		}
		Menu_CreateDirectorMenu(cindex);
	} else if (action == MenuAction_End) {
		delete menu;
	} else if (action == MenuAction_Cancel) {
		if (itempos == MenuCancel_ExitBack && admin_menu != null)
			admin_menu.Display( cindex, TopMenuPosition_LastCategory);
	}

	return 0;
}

/// Sourcemod Action for the Do_ForcePanic command.
Action Command_ForcePanic(int client, int args) { 
	Do_ForcePanic(client);
	return Plugin_Handled;
}


void Do_ForcePanic(int client) {
	L4D_ForcePanicEvent();
	
	if (notify_players.BoolValue) CPrintToChatAll("%t", "The zombies are coming!");	
	LogAction(client, -1, "[NOTICE]: (%L) executed %s", client, "a4d_force_panic");
}

/// Sourcemod Action for the Do_PanicForever command.
Action Command_PanicForever(int client, int args) {
	if (args < 1) { 
		ReplyToCommand(client, "Usage: a4d_panic_forever <0|1>"); 
		return Plugin_Handled;
	}
	char value[2];
	GetCmdArg(1, value, sizeof(value));
	if (strcmp(value, "0") == 0)
		Do_PanicForever(client, false);
	else
		Do_PanicForever(client, true);
	return Plugin_Handled;
}

void Do_PanicForever(int client, bool value) {
	StripAndChangeServerConVarBool(client, director_panic_forever, value);
	if (value == true) L4D_ForcePanicEvent();
	if (notify_players.BoolValue)
	{
		if (value == true)
			CPrintToChatAll("%t", "Endless panic events have started");
		else
			CPrintToChatAll("%t", "Endless panic events have ended");
	}
}

// Configuration commands

/// Creates the configuration commands menu when it is selected from the top menu and displays it to the client.
void Menu_CreateConfigMenu(int client) {
	Menu menu = new Menu(Menu_ConfigCommandsHandler);
	menu.SetTitle(Translate(client, "%t", "Configuration Commands"));
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	if (notify_players.BoolValue) { menu.AddItem("pn", Translate(client, "%t", "Disable player notifications")); } 
	else { menu.AddItem("pn", Translate(client, "%t", "Enable player notifications")); }
	menu.Display( client, MENU_TIME_FOREVER);
}
/// Handles callbacks from a client using the configuration menu.
int Menu_ConfigCommandsHandler(Menu menu, MenuAction action, int cindex, int itempos) {
	
	if (action == MenuAction_Select) {
		switch (itempos) {
			case 0: {
				if (notify_players.BoolValue)
					Do_EnableNotifications(cindex, false); 
				else
					Do_EnableNotifications(cindex, true); 
			}
		}
		Menu_CreateConfigMenu(cindex);
	} else if (action == MenuAction_End) {
		delete menu;
	} else if (action == MenuAction_Cancel) {
		if (itempos == MenuCancel_ExitBack && admin_menu != null)
			admin_menu.Display( cindex, TopMenuPosition_LastCategory);
	}

	return 0;
}

/// Sourcemod Action for the Do_EnableNotifications command.
Action Command_EnableNotifications(int client, int args) {
	if (args < 1) { 
		ReplyToCommand (client, "Usage: a4d_enable_notifications <0|1>"); 
		return Plugin_Handled;
	}
	char value[2];
	GetCmdArg(1, value, sizeof(value));
	if (strcmp(value, "0") == 0) 
		Do_EnableNotifications(client, false);		
	else
		Do_EnableNotifications(client, true);
	return Plugin_Handled;
}


void Do_EnableNotifications(int client, bool value) {
	SetConVarBool(notify_players, value);
	if (notify_players.BoolValue) CPrintToChat(client, "%T", "Player notifications have now been enabled", client);
	LogAction(client, -1, "(%L) set %s to %i", client, "a4d_notify_players", value);	
}

// Helper functions

/// Strip and change a ConVarBool to another value. This allows modification of otherwise cheat-protected ConVars.
void StripAndChangeServerConVarBool(int client, ConVar convar, bool value) {
	char command[32];
	convar.GetName(command,32);
	convar.SetBool(value, false, false);
	LogAction(client, -1, "[NOTICE]: (%L) set %s to %i", client, command, value);	
}
/// Strip and execute a client command. This 'fakes' a client calling a specfied command. Can be used to call cheat-protected commands.
void StripAndExecuteClientCommand(int client, const char[] command, const char[] arguments) {
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
}


bool Misc_TraceClientViewToLocation(int client, float location[3]) {
	float vAngles[3], vOrigin[3];
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	// PrintToChatAll("Running Code %f %f %f | %f %f %f", vOrigin[0], vOrigin[1], vOrigin[2], vAngles[0], vAngles[1], vAngles[2]);
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	if(TR_DidHit(trace)) {
		TR_GetEndPosition(location, trace);
		CloseHandle(trace);
		// PrintToChatAll("Collision at %f %f %f", location[0], location[1], location[2]);
		return true;
	}
	CloseHandle(trace);
	return false;
}

bool TraceRayDontHitSelf(int entity, int mask, any data) {
	if(entity == data) { // Check if the TraceRay hit the itself.
		return false; // Don't let the entity be hit
	}
	return true; // It didn't hit itself
}

// ====================================================================================================
//					POSITION
// ====================================================================================================
float GetGroundHeight(float vPos[3])
{
	float vAng[3]; Handle trace = TR_TraceRayFilterEx(vPos, view_as<float>({ 90.0, 0.0, 0.0 }), MASK_ALL, RayType_Infinite, _TraceFilter);
	if( TR_DidHit(trace) )
		TR_GetEndPosition(vAng, trace);

	delete trace;
	return vAng[2];
}

// Taken from "[L4D2] Weapon/Zombie Spawner"
// By "Zuko & McFlurry"
bool SetTeleportEndPoint(int client, float vPos[3], float vAng[3])
{
	GetClientEyePosition(client, vPos);
	GetClientEyeAngles(client, vAng);

	Handle trace = TR_TraceRayFilterEx(vPos, vAng, MASK_SHOT, RayType_Infinite, _TraceFilter);

	if( TR_DidHit(trace) )
	{
		float vNorm[3];
		float degrees = vAng[1];
		TR_GetEndPosition(vPos, trace);

		GetGroundHeight(vPos);
		vPos[2] += 1.0;

		TR_GetPlaneNormal(trace, vNorm);
		GetVectorAngles(vNorm, vAng);

		if( vNorm[2] == 1.0 )
		{
			vAng[0] = 0.0;
			vAng[1] = degrees + 180;
		}
		else
		{
			if( degrees > vAng[1] )
				degrees = vAng[1] - degrees;
			else
				degrees = degrees - vAng[1];
			vAng[0] += 90.0;
			RotateYaw(vAng, degrees + 180);
		}
	}
	else
	{
		delete trace;
		return false;
	}

	vAng[1] += 90.0;
	vAng[2] -= 90.0;
	delete trace;
	return true;
}

bool _TraceFilter(int entity, int contentsMask)
{
	return entity > MaxClients || !entity;
}

void RotateYaw(float angles[3], float degree)
{
	float direction[3], normal[3];
	GetAngleVectors(angles, direction, NULL_VECTOR, normal);

	float sin = Sine(degree * 0.01745328);	 // Pi/180
	float cos = Cosine(degree * 0.01745328);
	float a = normal[0] * sin;
	float b = normal[1] * sin;
	float c = normal[2] * sin;
	float x = direction[2] * b + direction[0] * cos - direction[1] * c;
	float y = direction[0] * c + direction[1] * cos - direction[2] * a;
	float z = direction[1] * a + direction[2] * cos - direction[0] * b;
	direction[0] = x;
	direction[1] = y;
	direction[2] = z;

	GetVectorAngles(direction, angles);

	float up[3];
	GetVectorVectors(direction, NULL_VECTOR, up);

	float roll = GetAngleBetweenVectors(up, normal, direction);
	angles[2] += roll;
}

//---------------------------------------------------------
// calculate the angle between 2 vectors
// the direction will be used to determine the sign of angle (right hand rule)
// all of the 3 vectors have to be normalized
//---------------------------------------------------------
float GetAngleBetweenVectors(const float vector1[3], const float vector2[3], const float direction[3])
{
	float vector1_n[3], vector2_n[3], direction_n[3], cross[3];
	NormalizeVector(direction, direction_n);
	NormalizeVector(vector1, vector1_n);
	NormalizeVector(vector2, vector2_n);
	float degree = ArcCosine(GetVectorDotProduct(vector1_n, vector2_n )) * 57.29577951;   // 180/Pi
	GetVectorCrossProduct(vector1_n, vector2_n, cross);

	if( GetVectorDotProduct( cross, direction_n ) < 0.0 )
		degree *= -1.0;

	return degree;
}

bool RealFreePlayersOnInfected ()
{
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 3 && (IsPlayerGhost(i) || !IsPlayerAlive(i)))
				return true;
	}
	return false;
}

bool IsPlayerGhost (int client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost"))
		return true;
	return false;
}


bool CheckIfEntitySafe(int entity)
{
	if(entity == -1) return false;

	if(	entity > ENTITY_SAFE_LIMIT)
	{
		RemoveEntity(entity);
		return false;
	}
	return true;
}

// Replace original text with translated text (Zakikun)
char[] Translate(int client, const char[] format, any ...)
{
	char buffer[192];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);
	return buffer;
}