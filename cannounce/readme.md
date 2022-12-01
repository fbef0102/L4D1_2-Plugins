
# Description | 內容
Replacement of default player connection message, allows for custom connection messages

* Video | 影片展示
<br/>None

* Image | 圖示
	* Display player connected and disconnected  message
		> 當玩家連線進來或離開遊戲時顯示
		<br/>![cannounce_1](image/cannounce_1.jpg)


* Apply to | 適用於
```
L4D1
L4D2
```

* <details><summary>Changelog | 版本日誌</summary>

	* v2.0 (2022-12-1)
        * Remove GeoIPCity (GeoIP2 is now included with SourceMod 1.11.6703.)
		* Remove player custom message (No one cares about it!)

	* v1.9
        * Remake Code

	* v1.8
        * [Original Plugin by Arg!](https://forums.alliedmods.net/showthread.php?t=77306)
</details>

* Require | 必要安裝
	1. [[INC] Multi Colors](https://forums.alliedmods.net/showthread.php?t=247770)

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\cannounce.cfg
		```php
		// [1|0] if 1 then displays connect message after admin check and allows the {PLAYERTYPE} placeholder. If 0 displays connect message on client auth (earlier) and disables the {PLAYERTYPE} placeholder
		sm_ca_connectdisplaytype "1"

		// Time to ignore all player join sounds on a map load
		sm_ca_mapstartnosound "30.0"

		// Plays a specified (sm_ca_playdiscsoundfile) sound on player discconnect
		sm_ca_playdiscsound "0"

		// Sound to play on player discconnect if sm_ca_playdiscsound = 1
		sm_ca_playdiscsoundfile "weapons\cguard\charging.wav"

		// Plays a specified (sm_ca_playsoundfile) sound on player connect
		sm_ca_playsound "1"

		// Sound to play on player connect if sm_ca_playsound = 1
		// -
		// Default: "ambient\alarms\klaxon1.wav"
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
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* Notice
	* To retrieve data from client, You must [install country and city database](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/English/Server/Install_Other_File#country-and-city-database)

* Data Example
	* data\cannounce_settings.txt
	```php
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

		// You can't use {lightgreen}, {red}, {blue} at the same message
		// {default}: white
		// {green}: orange
		// {olive}: green
		// {lightgreen}: lightgreen
		// {red}: red
		// {blue}: blue
		"messages" //display message to everyone (Non-admin)
		{
			"playerjoin"		"{default}[{olive}TS{default}] {blue}Player {green}{PLAYERNAME} {blue}connected{default}. ({green}{PLAYERCOUNTRY}{default}) {olive}<ID:{STEAMID}>"
			"playerdisc"		"{default}[{olive}TS{default}] {red}Player {green}{PLAYERNAME} {red}disconnected{default}. ({green}{DISC_REASON}{default}) {olive}<ID:{STEAMID}>"
		}
		"messages_admin" //only display message to adm
		{
			"playerjoin"		"{default}[{olive}TS{default}] {blue}Player {green}{PLAYERNAME} {blue}connected{default}. ({green}{PLAYERCOUNTRY}{default}) IP: {green}{PLAYERIP}{default} {olive}<ID:{STEAMID}>"
			"playerdisc"		"{default}[{olive}TS{default}] {red}Player {green}{PLAYERNAME} {red}disconnected{default}. ({green}{DISC_REASON}{default}) IP: {green}{PLAYERIP}{default} {olive}<ID:{STEAMID}>"
		}
	}
	```

- - - -
# 中文說明
顯示玩家進來遊戲或離開遊戲的提示訊息 (IP、國家、Steam ID 等等)

* 原理
    * 玩家連線進來伺服器之後，抓取玩家的各種訊息並顯示在聊天視窗當中
    * IP、國家、Steam ID

* 功能
    * 可顯示IP、國家、Steam ID 等等
    * 可播放玩家連線音效與玩家離開音效
    * 管理員會看到不同的提示訊息 (譬如只有管理員能看到IP與Steam ID)

* 必看步驟
	* 抓取玩家的地理位置，需[安裝國家與城市的資料庫](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/Chinese_%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87/Server/%E5%AE%89%E8%A3%9D%E5%85%B6%E4%BB%96%E6%AA%94%E6%A1%88%E6%95%99%E5%AD%B8#%E5%AE%89%E8%A3%9D%E5%9C%8B%E5%AE%B6%E8%88%87%E5%9F%8E%E5%B8%82%E7%9A%84%E8%B3%87%E6%96%99%E5%BA%AB)


* Data設定範例
	* data\cannounce_settings.txt
	```php
	"CountryShow"
	{
		// {PLAYERNAME}: 玩家名稱
		// {STEAMID}: 玩家steam id
		// {PLAYERCOUNTRY}: 玩家的國家
		// {PLAYERCOUNTRYSHORT}: 玩家的國家短代號
		// {PLAYERCOUNTRYSHORT3}: 玩家的國家短代號(多一些代號)
		// {PLAYERCITY}: 玩家的城市
		// {PLAYERREGION}: 玩家的地區(省,州)
		// {PLAYERIP}: 玩家IP
		// {PLAYERTYPE}: 玩家是否為管理員

		// 你不能同時在一個訊息內使用顏色 {lightgreen}, {red}, {blue}
		// {default}: 白色
		// {green}: 橘色
		// {olive}: 綠色
		// {lightgreen}: 淺綠色
		// {red}: 紅色
		// {blue}: 藍色
		"messages" //除了管理員外所有人會看到的
		{
			"playerjoin"		"{default}[{olive}TS{default}] {blue}玩家 {green}{PLAYERNAME} {blue}來了{default}. ({green}{PLAYERCOUNTRY}{default})"
			"playerdisc"		"{default}[{olive}TS{default}] {red}玩家 {green}{PLAYERNAME} {red}跑了{default}. ({green}{DISC_REASON}{default})"
		}
		"messages_admin" //管理員會看到的
		{
			"playerjoin"		"{default}[{olive}TS{default}] {blue}玩家 {green}{PLAYERNAME} {blue}來了{default}. ({green}{PLAYERCOUNTRY}{default}) IP: {green}{PLAYERIP}{default} {olive}<ID:{STEAMID}>"
			"playerdisc"		"{default}[{olive}TS{default}] {red}玩家 {green}{PLAYERNAME} {red}跑了{default}. ({green}{DISC_REASON}{default}) IP: {green}{PLAYERIP}{default} {olive}<ID:{STEAMID}>"
		}
	}
	```



