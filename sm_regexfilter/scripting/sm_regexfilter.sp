/* Change Log
* 2.2 (2021/7/7)
-Fixed compatibility with plugin "lfd_noTeamSay" v2.2+ by bullet28, HarryPotter

*/

#include <sourcemod>
#include <adt_trie>
#include <regex>
#include <multicolors>
#include <basecomm>

public Plugin:myinfo = 
{
	name = "REGEX word filter",
	author = "Twilight Suzuka, HarryPotter",
	description = "Filter dirty words via Regular Expressions",
	version = "1.3",
	url = "http://www.sourcemod.net/"
};

ConVar CvarEnable;
bool g_bCvarEnable;

new Handle:REGEXSections = INVALID_HANDLE;
StringMap CurrentSection = null;
new Handle:ChatREGEXList = INVALID_HANDLE;

StringMap ClientLimits[MAXPLAYERS+1];
int iClientFlags[MAXPLAYERS+1];
bool bLateLoad = false;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	decl String:regexfile[128];
	
	BuildPath(Path_SM, regexfile ,sizeof(regexfile),"configs/regexrestrict.cfg");
	new bool:load = FileExists(regexfile);

	decl String:mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	BuildPath(Path_SM, regexfile ,sizeof(regexfile),"configs/regexrestrict_%s.cfg",mapname);
	
	new bool:load2 = FileExists(regexfile);

	if( (load == false) && (load2 == false) ) 
	{
		LogMessage("REGEXFilter has no file to filter based on. Powering down...");	
		return APLRes_SilentFailure;
	}

	bLateLoad = late;
	return APLRes_Success; 
}


public OnPluginStart()
{
	CvarEnable = CreateConVar("regexfilter_enable","1","REGEXFILTER Enabled", FCVAR_NOTIFY);

	GetCvars();
	CvarEnable.AddChangeHook(ConVarChanged_Cvars);
	
	REGEXSections = CreateArray();
	
	ChatREGEXList = CreateArray(2);
	
	decl String:mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	Format(mapname,sizeof(mapname),"configs/regexrestrict.cfg");
	
	LoadExpressions("configs/regexrestrict.cfg");
	LoadExpressions(mapname);
	
	//RegConsoleCmd("say", Command_SayHandle);
	//RegConsoleCmd("say_team", Command_SayHandle);

	AutoExecConfig(true, "sm_regexfilter");

	if(bLateLoad){	
		for (int i = 1; i < MaxClients + 1; i++) {
			if (IsClientInGame(i)) {
				OnClientPostAdminCheck(i);
			}
		}
	}
}

public void OnPluginEnd()
{
	for( int i = 1; i <= MaxClients; i++ )
	{
		delete ClientLimits[i];
	}
	delete CurrentSection;
	delete REGEXSections;
	delete ChatREGEXList;
}

ConVar g_hNoTeamSayPlugin = null;
char g_sIgnoreList[32][8];
public void OnAllPluginsLoaded()
{
	// lfd_noTeamSay
	g_hNoTeamSayPlugin = FindConVar("noteamsay_ignorelist");
	if(g_hNoTeamSayPlugin != null)
	{
		GetCvars2();
		g_hNoTeamSayPlugin.AddChangeHook(OnConVarChange2);
	}
}

public void OnConVarChange2(ConVar convar, char[] oldValue, char[] newValue) {
	GetCvars2();
}

void GetCvars2()
{
	char buffer[256];
	g_hNoTeamSayPlugin.GetString(buffer, sizeof buffer);
	for (int i = 0; i < sizeof g_sIgnoreList; i++) g_sIgnoreList[i] = "";
	ExplodeString(buffer, ",", g_sIgnoreList, sizeof g_sIgnoreList, sizeof g_sIgnoreList[]);
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = CvarEnable.BoolValue;
}

public OnMapStart() ClientLimits[0] = CreateTrie();
public OnMapEnd() delete ClientLimits[0];

public void OnClientPostAdminCheck(int client)
{
	if(!IsFakeClient(client))
	{
		iClientFlags[client] = GetUserFlagBits(client);
		ClientLimits[client] = CreateTrie();
	}
}

public void OnClientDisconnect(int client)
{
	delete ClientLimits[client];
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(g_bCvarEnable == false || client == 0 || !IsClientInGame(client) || IsFakeClient(client)) return Plugin_Continue;
	
	if (BaseComm_IsClientGagged(client) == true || IsChatTrigger())
		return Plugin_Continue;

	char text[512];
	Format(text, sizeof(text), "%s", sArgs);

	new begin, end = GetArraySize(ChatREGEXList), RegexError:ret = REGEX_ERROR_NONE, bool:changed = false;
	decl arr[2], Handle:CurrRegex, Handle:CurrInfo, any:val
	decl String:strval[192];
	
	while(begin != end)
	{
		GetArrayArray(ChatREGEXList,begin,arr,2)
		CurrRegex = Handle:arr[0];
		CurrInfo = Handle:arr[1];
		val = MatchRegex(CurrRegex, text, ret);
		if( (val > 0) && (ret == REGEX_ERROR_NONE) )
		{
			if(GetTrieString(CurrInfo, "immunity", strval, sizeof(strval) ))
			{
				if(HasAccess(client, strval) ) return Plugin_Continue;
			}
			
			if(GetTrieString(CurrInfo, "warn", strval, sizeof(strval) ))
			{
				if(!client) PrintToServer("[RegexFilter] %s",strval);
				else PrintToChat(client, "[RegexFilter] %s",strval);
			}
			
			if(GetTrieString(CurrInfo, "action", strval, sizeof(strval) ))
			{
				ParseAndExecute(client, strval, sizeof(strval));
			}

			if(GetTrieValue(CurrInfo, "limit", val))
			{
				new any:at;
				FormatEx(strval, sizeof(strval), "%i", CurrRegex);
				GetTrieValue(ClientLimits[client], strval, at);
					
				at++;
				
				new mod;
				if(GetTrieValue(CurrInfo, "forgive", mod))
				{
					new Float:datiem;
					FormatEx(strval, sizeof(strval), "%i-limit", CurrRegex);
					if(!GetTrieValue(ClientLimits[client], strval, any:datiem))
					{
						datiem = GetGameTime();
						SetTrieValue(ClientLimits[client], strval, any:datiem)
					}	

					datiem = GetGameTime() - datiem;
					new datiemint = RoundToCeil(datiem);
					
					at = at - (datiemint % mod);
				}
				
				SetTrieValue(ClientLimits[client], strval, at);
				
				if(at > val)
				{
					if(GetTrieString(CurrInfo, "punish", strval, sizeof(strval) ))
					{
						ParseAndExecute(client,strval, sizeof(strval) );
					}
					return Plugin_Stop;
				}
			}
						
			if(GetTrieValue(CurrInfo, "block", val))
			{
				return Plugin_Stop;
			}

			if(GetTrieString(CurrInfo, "replaceall", strval, sizeof(strval)))
			{
				changed = true;
				Format(text, sizeof(text), "%s", strval);
			}
			else if(GetTrieValue(CurrInfo, "replace", val))
			{
				changed = true;
				new rand = GetRandomInt(0, GetArraySize(Handle:val) - 1);
				
				new Handle:dp = GetArrayCell(Handle:val,rand);
				ResetPack(dp);
				new Handle:cregex = Handle:ReadPackCell(dp);
				ReadPackString(dp,strval, sizeof(strval) );
				
				if(cregex == INVALID_HANDLE) cregex = CurrRegex;
	
				rand = MatchRegex(cregex, text, ret);
	
				if( (rand > 0) && (ret == REGEX_ERROR_NONE))
				{
					decl String:strarray[rand][192];
					for(new a = 0; a < rand; a++)
					{
						GetRegexSubString(cregex, a, strarray[a], sizeof(strval) );
					}
					
					for(new a = 0; a < rand; a++)
					{
						ReplaceString(text, sizeof(text), strarray[a], strval);
					}
					
					begin = 0;
				}
			}
		}
		begin++;
	}
	
	if(changed == true) 
	{
		int team = GetClientTeam(client);
		if(team == 2) 
		{
			CPrintToChatAll("{blue}%N{default} :  %s", client, text);
		}
		else if(team == 3) 
		{
			CPrintToChatAll("{red}%N{default} :  %s", client, text);
		}
		else
		{
			CPrintToChatAll("{lightgreen}%N{default} :  %s", client, text);
		}
		return Plugin_Stop;
	}

	/*lfd_noTeamSay*/
	if(g_hNoTeamSayPlugin != null)
	{
		if (strcmp(command, "say_team", false) != 0)
			return Plugin_Continue;
			
		for (int i = 0; i < sizeof g_sIgnoreList; i++) {
			if ( g_sIgnoreList[i][0] != EOS && strncmp(sArgs, g_sIgnoreList[i], strlen(g_sIgnoreList[i])) == 0 ) {
				return Plugin_Continue;
			}
		}

		char buffer[512];
		Format(buffer, sizeof(buffer), "\x03%N\x01 :  %s", client, sArgs);

		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && !IsFakeClient(i)) {
				SayText2(i, client, buffer);
			}
		}

		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

stock LoadExpressions(String:file[])
{
	decl String:regexfile[128];
	BuildPath(Path_SM, regexfile ,sizeof(regexfile), file);
	
	if(!FileExists(regexfile)) 
	{
		LogMessage("%s not parsed...file doesnt exist!", file);
		return 0;
	}
	
	new Handle:Parser = SMC_CreateParser();
	SMC_SetReaders(Parser, HandleNewSection, HandleKeyValue, HandleEndSection);
	SMC_SetParseEnd(Parser, HandleEnd);
	SMC_ParseFile(Parser, regexfile);
	CloseHandle(Parser);
	
	return 1;
}
	

public HandleEnd(Handle:smc, bool:halted, bool:failed)
{
	if (halted)
		LogError("REGEXFilter file partially parsed, please check for errors. Continuing...");
	if (failed)
		LogError("REGEXFilter file failed to parse!");
}
	
public SMCResult:HandleNewSection(Handle:smc, const String:name[], bool:opt_quotes)
{
	CurrentSection = CreateTrie();
	SetTrieString(CurrentSection, "name", name);
	PushArrayCell(REGEXSections,CurrentSection);
}

public SMCResult:HandleKeyValue(Handle:smc, const String:key[], const String:value[], bool:key_quotes, bool:value_quotes)
{
	if(!strcmp(key, "chatpattern", false)) 
	{
		RegisterExpression(value, CurrentSection, ChatREGEXList);
	}
	else if(!strcmp(key, "replace", false))
	{
		new any:val;
		if(!GetTrieValue(CurrentSection, "replace", val))
		{
			val = CreateArray();
			SetTrieValue(CurrentSection,"replace",val);
		}
		AddReplacement(value,val);
	}
	else if(!strcmp(key, "replaceall", false))
	{
		SetTrieString(CurrentSection,"replaceall",value);
	}
	else if(!strcmp(key, "replacepattern", false))
	{
		new any:val;
		if(!GetTrieValue(CurrentSection, "replace", val))
		{
			val = CreateArray();
			SetTrieValue(CurrentSection,"replace",val);
		}
		AddPatternReplacement(value,val);
	}
	else if(!strcmp(key, "block", false))
	{
		SetTrieValue(CurrentSection,"block",1);
	}
	else if(!strcmp(key, "action", false))
	{
		SetTrieString(CurrentSection,"action",value);
	}
	else if(!strcmp(key, "warn", false))
	{
		SetTrieString(CurrentSection,"warn",value);
	}
	else if(!strcmp(key, "limit", false))
	{
		SetTrieValue(CurrentSection,"limit",StringToInt(value));
	}
	else if(!strcmp(key, "forgive", false))
	{
		SetTrieValue(CurrentSection,"forgive",StringToInt(value));
	}
	else if(!strcmp(key, "punish", false))
	{
		SetTrieString(CurrentSection,"punish",value);
	}
	else if(!strcmp(key, "immunity", false))
	{
		SetTrieString(CurrentSection,"immunity",value);
	}
}

public SMCResult:HandleEndSection (Handle:smc)
{
	CurrentSection = null;
}

stock RegisterExpression(const String:key[], Handle:curr, Handle:array)
{
	decl String:expression[192];
	new flags = ParseExpression(key, expression, sizeof(expression) );
	if(flags == -1) return;
	
	decl String:errno[128], RegexError:errcode;
	new Handle:compiled = CompileRegex(expression, flags, errno, sizeof(errno), errcode);
	
	if(compiled == INVALID_HANDLE)
	{
		LogMessage("Error occured while compiling expression %s with flags %s, error: %s, errcode: %d", 
			expression, flags, errno, errcode);
	}
	else 
	{
		decl arr[2];
		arr[0] = _:compiled;
		arr[1] = _:curr;
		PushArrayArray(array, arr, 2);
	}
}

stock ParseExpression(const String:key[], String:expression[], len)
{
	strcopy(expression, len, key);
	TrimString(expression);
	
	new flags, a, b, c
	if(expression[strlen(expression) - 1] == '\'')
	{
		for(; expression[flags] != '\0'; flags++)
		{
			if(expression[flags] == '\'')
			{
				a++;
				b = c;
				c = flags;
			}
		}
		
		if(a < 2) 
		{
			LogError("REGEXFilter file line malformed: %s, please check for errors. Continuing...",key);
			return -1;
		}
		else
		{
			expression[b] = '\0'
			expression[c] = '\0';
			flags = FindREGEXFlags(expression[b + 1]);
			
			TrimString(expression);
			
			if(a > 2 && expression[0] == '\'')
			{
				strcopy(expression, strlen(expression) - 1, expression[1]);
			}
		}
	}
	
	return flags;
}

stock FindREGEXFlags(const String:flags[])
{
	decl String:buffer[7][16];
	buffer[0][0] = '\0';
	buffer[1][0] = '\0';
	buffer[2][0] = '\0';
	buffer[3][0] = '\0';
	buffer[4][0] = '\0';
	buffer[5][0] = '\0';
	buffer[6][0] = '\0';

	ExplodeString(flags, "|", buffer, 7, 16 );

	new intflags = 0;
	for(new i = 0; i < 7; i++)
	{
		if(buffer[i][0] == '\0') continue;
		
		if(!strcmp(buffer[i],"CASELESS",false) ) intflags |= PCRE_CASELESS;
		else if(!strcmp(buffer[i],"MULTILINE",false) ) intflags |= PCRE_MULTILINE;
		else if(!strcmp(buffer[i],"DOTALL",false) ) intflags |= PCRE_DOTALL;
		else if(!strcmp(buffer[i],"EXTENDED",false) ) intflags |= PCRE_EXTENDED;
		else if(!strcmp(buffer[i],"UNGREEDY",false) ) intflags |= PCRE_UNGREEDY;
		else if(!strcmp(buffer[i],"UTF8",false) ) intflags |= PCRE_UTF8 ;
		else if(!strcmp(buffer[i],"NO_UTF8_CHECK",false) ) intflags |= PCRE_NO_UTF8_CHECK;
	}
	
	return intflags;
}

stock AddReplacement(const String:val[], Handle:array)
{
	new Handle:dp = CreateDataPack();
	WritePackCell(dp, _:INVALID_HANDLE);
	WritePackString(dp, val);
	
	PushArrayCell(array,dp);
}

stock AddPatternReplacement(const String:val[], Handle:array)
{
	decl String:expression[192];
	new flags = ParseExpression(val, expression, sizeof(expression) );
	if(flags == -1) return;
	
	decl String:errno[128], RegexError:errcode;
	new Handle:compiled = CompileRegex(expression, flags, errno, sizeof(errno), errcode);
	
	if(compiled == INVALID_HANDLE)
	{
		LogMessage("Error occured while compiling expression %s with flags %s, error: %s, errcode: %d", 
			expression, flags, errno, errcode);
	}
	else
	{
		new Handle:dp = CreateDataPack();
		WritePackCell(dp,_:compiled);
		WritePackString(dp, "");
	
		PushArrayCell(array,dp);
	}
}

stock ParseAndExecute(client, String:cmd[], len)
{
	decl String:repl[192];
	
	if(client == 0) FormatEx(repl, sizeof(repl), "0");
	else FormatEx(repl, sizeof(repl), "%i", GetClientUserId(client))
	ReplaceString(cmd, len, "%u", repl); //user id
	
	if(client != 0) FormatEx(repl, sizeof(repl), "%i", client)
	ReplaceString(cmd, len, "%i", repl); //client id
	
	GetClientName(client, repl, sizeof(repl));
	ReplaceString(cmd, len, "%n", repl); //name

	GetClientAuthId(client, AuthId_Steam2, repl, sizeof(repl)-1);
	ReplaceString(cmd, len, "%s", repl); //steam id

	ServerCommand(cmd);
}

public bool HasAccess(int client, char[] g_sAcclvl)
{
	// no permissions set
	if (strlen(g_sAcclvl) == 0)
		return true;

	else if (StrEqual(g_sAcclvl, "-1"))
		return false;

	// check permissions
	if ( iClientFlags[client] & ReadFlagString(g_sAcclvl) )
	{
		return true;
	}

	return false;
}

stock void SayText2(int client, int sender, const char[] msg) {
	Handle hMessage = StartMessageOne("SayText2", client);
	if (hMessage != null) {
		BfWriteByte(hMessage, sender);
		BfWriteByte(hMessage, true);
		BfWriteString(hMessage, msg);
		EndMessage();
	}
}