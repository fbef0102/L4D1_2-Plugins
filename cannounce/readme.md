
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

* Country and City Database Installation:
	1. [Register on maxmind.com](https://www.maxmind.com/en/geolite2/signup) to be able to download databases
	2. [Go to account](https://www.maxmind.com/en/account/) -> My License Keys -> Create new license key.  
	3. Go to this page: https://www.maxmind.com/en/accounts/XXXXXX/geoip/downloads
		* XXXXXX is your account ID
		<br/>![ID](https://user-images.githubusercontent.com/12229810/205027221-05798d84-08ab-40c3-8d54-ef66a892c295.jpg)
	4. Seach "GeoLite2 Country" and "GeoLite2 City" -> download databases.
	<br/>![GeoLite2 Country](https://user-images.githubusercontent.com/12229810/204966692-ac339bc6-4760-4acc-b320-b776d46e7064.jpg)
	<br/>![GeoLite2 City](https://user-images.githubusercontent.com/12229810/204966795-a57a5949-abcf-4127-9325-90b9fdb8124f.jpg)
	5. Put mmdb database files to path addons/sourcemod/configs/geoip/ folder
	6. Recompile all plugins that use geoip.inc, done.

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

* 安裝國家與城市的資料庫:
	1. 註冊 [maxmind.com](https://www.maxmind.com/en/geolite2/signup)
	2. [到個人帳戶](https://www.maxmind.com/en/account/) -> My License Keys -> Create new license key
	3. 到這個網頁: https://www.maxmind.com/en/accounts/XXXXXX/geoip/downloads
		* XXXXXX 是你的帳戶ID
		<br/>![ID](https://user-images.githubusercontent.com/12229810/205027221-05798d84-08ab-40c3-8d54-ef66a892c295.jpg)
	4. 搜尋 "GeoLite2 Country" 和 "GeoLite2 City" -> 下載資料庫
	<br/>![GeoLite2 Country](https://user-images.githubusercontent.com/12229810/204966692-ac339bc6-4760-4acc-b320-b776d46e7064.jpg)
	<br/>![GeoLite2 City](https://user-images.githubusercontent.com/12229810/204966795-a57a5949-abcf-4127-9325-90b9fdb8124f.jpg)
	5. 放 GeoLite2-City.mmdb 與 GeoLite2-Country.mmdb 到路徑 addons/sourcemod/configs/geoip/ 資料夾
	6. 重新編譯有使用 geoip.inc 的插件，大功告成

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



