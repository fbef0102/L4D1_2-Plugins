Replacement of default player connection message, allows for custom connection messages

-ChangeLog-
v1.9
-Remake Code

v1.8
-Original Post: https://forums.alliedmods.net/showthread.php?t=77306

-Require-
1. [INC] Multi Colors: https://forums.alliedmods.net/showthread.php?t=247770
2. GeoIPCity: https://forums.alliedmods.net/showthread.php?t=132470

Edit Custom Connection Messages:
data\cannounce_settings.txt
"CountryShow"
{
	// {PLAYERNAME}: player name
	// {STEAMID}: player STEAMID
	// {PLAYERCOUNTRY}: player country name
	// {PLAYERCOUNTRYSHORT}: player country short name
	// {PLAYERCOUNTRYSHORT3}: player country another short name
	// {PLAYERCITY}: player city name
	// {PLAYERREGION}: player region name
	// {PLAYERIP}: player IP
	// {PLAYERTYPE}: player is Adm or not
	"messages" //everyone can see
	{
		"playerjoin"		"{default}[{olive}TS{default}] {blue}玩家 {green}{PLAYERNAME} {blue}來了{default}. ({green}{PLAYERCOUNTRY}{default}) {olive}<ID:{STEAMID}>"
		"playerdisc"		"{default}[{olive}TS{default}] {red}玩家 {green}{PLAYERNAME} {red}跑了{default}. ({green}{DISC_REASON}{default}) {olive}<ID:{STEAMID}>"
	}
	"messages_admin" //only adm can see
	{
		"playerjoin"		"{default}[{olive}TS{default}] {blue}玩家 {green}{PLAYERNAME} {blue}來了{default}. ({green}{PLAYERCOUNTRY}{default}) IP: {green}{PLAYERIP}{default} {olive}<ID:{STEAMID}>"
		"playerdisc"		"{default}[{olive}TS{default}] {red}玩家 {green}{PLAYERNAME} {red}跑了{default}. ({green}{DISC_REASON}{default}) IP: {green}{PLAYERIP}{default} {olive}<ID:{STEAMID}>"
	}
}


-Convar-
cfg\sourcemod\cannounce.cfg
// Always allow custom join messages for admins with the ADMIN_KICK flag
sm_ca_autoallowmsg "1"

// [1|0] if 1 then displays connect message after admin check and allows the {PLAYERTYPE} placeholder. If 0 displays connect message on client auth (earlier) and disables the {PLAYERTYPE} placeholder
sm_ca_connectdisplaytype "1"

// Prevent clients from being able to change their own custom join message
sm_ca_disableclientmsgchange "0"

// Time to ignore all player join sounds on a map load
sm_ca_mapstartnosound "30.0"

// Plays a specified (sm_ca_playdiscsoundfile) sound on player discconnect
sm_ca_playdiscsound "0"

// Sound to play on player discconnect if sm_ca_playdiscsound = 1
sm_ca_playdiscsoundfile "weapons\cguard\charging.wav"

// Plays a specified (sm_ca_playsoundfile) sound on player connect
sm_ca_playsound "1"

// Sound to play on player connect if sm_ca_playsound = 1
sm_ca_playsoundfile "ambient\alarms\klaxon1.wav"

// displays enhanced message when player connects
sm_ca_showenhanced "1"

// displays a different enhanced message to admin players (ADMFLAG_GENERIC)
sm_ca_showenhancedadmins "1"

// displays enhanced message when player disconnects
sm_ca_showenhanceddisc "1"

// shows standard player connected message
sm_ca_showstandard "0"

// shows standard player discconnected message
sm_ca_showstandarddisc "0"

