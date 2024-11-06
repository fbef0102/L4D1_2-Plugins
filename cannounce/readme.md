# Description | 內容
Replacement of default player connection message, allows for custom connection messages

> __Note__ <br/>
🟥Dedicated Server Only<br/>
🟥只能安裝在Dedicated Server

* Video | 影片展示
<br/>None

* Image | 圖示
	<br/>![cannounce_1](image/cannounce_1.jpg)

* <details><summary>How does it work?</summary>

	* Display player connected and disconnected message
</details>

* Notice
	* To retrieve data from client, You must [install country and city database](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/English/Server/Install_Other_File#country-and-city-database)

* Require | 必要安裝
	1. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\cannounce.cfg
		```php
		// If 1, Display if player is admin on connect/disconnect message (allows the {PLAYERTYPE} placeholder)
		sm_ca_display_admin "1"

		// shows standard player connected message
		sm_ca_showstandard "0"

		// displays enhanced message when player connects
		sm_ca_showenhanced "1"

		// Plays a specified (sm_ca_playsoundfile) sound on player connect
		sm_ca_playsound "1"

		// Sound to play on player discconnect if sm_ca_playdiscsound = 1
		sm_ca_playdiscsoundfile "ambient\alarms\perimeter_alarm.wav"

		// Time to ignore all player join sounds on a map load
		sm_ca_mapstartnosound "30.0"

		// shows standard player discconnected message
		sm_ca_showstandarddisc "0"

		// displays enhanced message when player disconnects
		sm_ca_showenhanceddisc "1"

		// Plays a specified (sm_ca_playdiscsoundfile) sound on player discconnect
		sm_ca_playdiscsound "0"

		// Sound to play on player connect if sm_ca_playsound = 1
		sm_ca_playsoundfile "ambient\alarms\klaxon1.wav"

		// displays a different enhanced message to admin players (ADMFLAG_GENERIC)
		sm_ca_showenhancedadmins "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* <details><summary>Data Example</summary>

	* [data\cannounce_settings.txt](data\cannounce_settings.txt)
		> Manual in this file, click for more details...
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Translation Support | 支援翻譯</summary>

	```
	English
	繁體中文
	简体中文
	Русский
	```
</details>

* <details><summary>Similar Plugin | 相似插件</summary>

	1. [l4d_playerjoining](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Server_伺服器/l4d_playerjoining): Informs other players when a client connects to the server and changes teams.while player joins the server
    	> 當玩家更換隊伍、連線、離開伺服器之時，通知所有玩家 (簡單版的提示)
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v2.1 (2024-11-7)
		* Update sm 1.12
		* Update cvars

	* v2.0 (2022-12-1)
        * Remove GeoIPCity (GeoIP2 is now included with SourceMod 1.11.6703.)
		* Remove player custom message (No one cares about it!)

	* v1.9
        * Remake Code

	* v1.8
        * [Original Plugin by Arg!](https://forums.alliedmods.net/showthread.php?t=77306)
</details>

- - - -
# 中文說明
顯示玩家進來遊戲或離開遊戲的提示訊息 (IP、國家、Steam ID 等等)

* 原理
    * 玩家連線進來伺服器或離開伺服器時，抓取玩家的各種訊息並顯示在聊天視窗當中
    * 顯示IP、國家、Steam ID，播放玩家連線音效與玩家離開音效
	* 管理員會看到不同的提示訊息 (譬如只有管理員能看到IP與Steam ID)

* 必看步驟
	* 抓取玩家的地理位置，需[安裝國家與城市的資料庫](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/Chinese_%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87/Server/%E5%AE%89%E8%A3%9D%E5%85%B6%E4%BB%96%E6%AA%94%E6%A1%88%E6%95%99%E5%AD%B8#%E5%AE%89%E8%A3%9D%E5%9C%8B%E5%AE%B6%E8%88%87%E5%9F%8E%E5%B8%82%E7%9A%84%E8%B3%87%E6%96%99%E5%BA%AB)

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg\sourcemod\cannounce.cfg
		```php
		// 為1時，顯示該玩家是否為管理員 (data文件必須寫入{PLAYERTYPE})
		sm_ca_display_admin "1"

		// 為1時，玩家連線進來伺服器時，顯示遊戲內建的訊息
		sm_ca_showstandard "0"

		// 為1時，玩家連線進來伺服器時，顯示各種訊息
		sm_ca_showenhanced "1"

		// 為1時，玩家連線進來伺服器時，播放音效
		sm_ca_playsound "1"

		// 玩家連線進來伺服器時所播放的音效 (路徑相對於sound資料夾)
		sm_ca_playdiscsoundfile "ambient\alarms\perimeter_alarm.wav"

		// 地圖載入後30秒內 不要播放連線音效
		sm_ca_mapstartnosound "30.0"

		// 為1時，玩家離開伺服器時，顯示遊戲內建的訊息
		sm_ca_showstandarddisc "0"

		// 為1時，玩家離開伺服器時，顯示各種訊息
		sm_ca_showenhanceddisc "1"

		// 為1時，玩家離開伺服器時，播放音效
		sm_ca_playdiscsound "0"

		// 玩家離開伺服器時所播放的音效 (路徑相對於sound資料夾)
		sm_ca_playsoundfile "ambient\alarms\klaxon1.wav"

		// 為1時，給管理員顯示不同的玩家訊息 (權限所需: ADMFLAG_GENERIC)
		// (譬如只有管理員能看到玩家的IP與Steam ID)
		sm_ca_showenhancedadmins "1"
		```
</details>

* <details><summary>Data設定範例</summary>

	* [data\cannounce_settings.txt](data\cannounce_settings.txt)
		> 內有中文說明，可點擊查看
</details>


