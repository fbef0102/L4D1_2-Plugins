
#define MSGLENGTH 		151
#define SOUNDFILE_PATH_LEN 		256
#define CHECKFLAG 		ADMFLAG_ROOT


/*****************************************************************


			G L O B A L   V A R S


*****************************************************************/
ConVar g_CvarPlaySound = null;
ConVar g_CvarPlaySoundFile = null;
char g_sCvarPlaySoundFile[128];

ConVar g_CvarPlayDiscSound = null;
ConVar g_CvarPlayDiscSoundFile = null;
char g_sCvarPlayDiscSoundFile[128];

ConVar g_CvarMapStartNoSound = null;

Handle g_hMapStartNoSoundTimer;
bool g_bMapStarted;

/*****************************************************************


			F O R W A R D   P U B L I C S


*****************************************************************/

void SetupJoinMsg()
{
	
	//cvars
	g_CvarPlaySound = CreateConVar("sm_ca_playsound", "1", "Plays a specified (sm_ca_playsoundfile) sound on player connect");
	g_CvarPlaySoundFile = CreateConVar("sm_ca_playsoundfile", "ambient/alarms/klaxon1.wav", "Sound to play on player connect if sm_ca_playsound = 1");

	g_CvarPlayDiscSound = CreateConVar("sm_ca_playdiscsound", "0", "Plays a specified (sm_ca_playdiscsoundfile) sound on player discconnect");
	g_CvarPlayDiscSoundFile = CreateConVar("sm_ca_playdiscsoundfile", "ui/beep_error01.wav", "Sound to play on player discconnect if sm_ca_playdiscsound = 1");

	g_CvarMapStartNoSound = CreateConVar("sm_ca_mapstartnosound", "30.0", "Time to ignore all player join/disconnect sounds on a map load");

	GetCvars();
	g_CvarPlaySoundFile.AddChangeHook(ConVarChanged_Cvars);
	g_CvarPlayDiscSoundFile.AddChangeHook(ConVarChanged_Cvars);
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_CvarPlaySoundFile.GetString(g_sCvarPlaySoundFile, sizeof(g_sCvarPlaySoundFile));
	g_CvarPlayDiscSoundFile.GetString(g_sCvarPlayDiscSoundFile, sizeof(g_sCvarPlayDiscSoundFile));

	if(g_bMapStarted)
	{
		if(strlen(g_sCvarPlaySoundFile) > 0)
		{
			PrecacheSound(g_sCvarPlaySoundFile);
		}

		if(strlen(g_sCvarPlayDiscSoundFile) > 0)
		{
			PrecacheSound(g_sCvarPlayDiscSoundFile);
		}
	}
}

void OnAdminMenuReady_JoinMsg()
{

}


void OnMapStart_JoinMsg()
{
	g_bMapStarted = true;

	float waitPeriod = g_CvarMapStartNoSound.FloatValue;
	
	if( waitPeriod > 0 )
	{
		delete g_hMapStartNoSoundTimer;
		g_hMapStartNoSoundTimer = CreateTimer(waitPeriod, Timer_MapStartNoSound);	
	}
}

void OnMapEnd_JoinMsg()
{
	g_bMapStarted = false;
	delete g_hMapStartNoSoundTimer;
}

void OnPostAdminCheck_Sound()
{
	if(g_hMapStartNoSoundTimer != null) return;

	//if enabled and custom sound not already played, play all player sound
	if( g_CvarPlaySound.BoolValue)
	{
		if(strlen(g_sCvarPlaySoundFile) > 0)
		{
			EmitSoundToAll(g_sCvarPlaySoundFile);
		}
	}
}

void OnClientDisconnect_Sound()
{
	if(g_hMapStartNoSoundTimer != null) return;

	if( g_CvarPlayDiscSound.BoolValue)
	{
		if(strlen(g_sCvarPlayDiscSoundFile) > 0)
		{
			EmitSoundToAll(g_sCvarPlayDiscSoundFile);
		}
	}
}


void OnPluginEnd_JoinMsg()
{		
}


Action Timer_MapStartNoSound(Handle timer)
{	
	g_hMapStartNoSoundTimer = null;
	
	return Plugin_Continue;
}


/*****************************************************************


			P L U G I N   F U N C T I O N S


*****************************************************************/
void OnConfigsExecuted_JoinMsg()
{
	GetCvars();
}