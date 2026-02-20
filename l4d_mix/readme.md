# Description | 內容
L4D1/2 Mix

* Apply to | 適用於
	```
	L4D1 Versus
	L4D2 Versus
	```

* <details><summary>How does it work?</summary>

	* In Versus -> Type ```!mix``` -> all players start to choose captains via menu
		* Survivor team and infected team must be full of real players first
	* Both Captains start to choose team members via menu -> Distribute team automatically
	* Start game -> enjoy
	* Please start a mix before game starts
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?p=2684862)
	2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>Support | 支援插件</summary>

	1. [readyup](/L4D_插件/Server_伺服器/readyup): Ready Plugin
		* 所有玩家準備才能開始遊戲的插件
	2. [l4d_teamshuffle](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Versus_%E5%B0%8D%E6%8A%97%E6%A8%A1%E5%BC%8F/l4d_teamshuffle): Allows teamshuffles by voting or admin-forced before round starts.
		* 輸入!shuffle，打散玩家並隨機分配隊伍
</details>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_mix.cfg
		```php
		// How captain choose the member, 0 = ABABAB | 1 = ABBAAB | 2 = ABBABA
		l4d_mix_select_order "1"

		// If 1, specators can vote to choose the captain
		l4d_mix_spectator_vote "1"

		// If 1, players can vote the spectators to be the captain + captains can choose spectators
		l4d_mix_vote_spectator "1"

		// How to select captain ? 0=Vote, 1=Random choose from survivor team and infected team
		l4d_mix_choose_captain "0"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Initiate a player mix.**
		```php
		sm_mix
		```

	* **Initiate a player mix. Admins only. (Adm Required: ADMFLAG_ROOT)**
		```php
		sm_forcemix
		```
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.2h (2026-2-20)
		* Provide a way to randomly choose captains
		* Update cvars

	* v1.1h (2024-3-17)
		* Readyup support

	* v1.0h (2023-11-15)
		* Initial release.
		* Cleared old code, converted to new syntax and methodmaps.	
		* fix error, optimize codes, and handle exception
		* Compiled .smx plugin is now compiled with SourceMod version 1.10
		* Add A-BB-A-B-A
		* Hide ReadyUp Hud if Ready Up plugin is available
		* fix client not in game error
		* Compiled .smx plugin is now compiled with SourceMod version 1.11

	* v1.0 Credits
		* KaiN - for request and the original idea	
		* ZenServer -[ Mix ]- - for the original plugin
		* JOSHE GATITO SPARTANSKII >>> (Ex Aya Supay) - for writing  plugin again and add new commands. 
</details>

- - - -
# 中文說明
對抗模式中，投票選雙方隊長，雙方隊長再選隊員

* 原理
	* 雙方隊伍輸入```!mix``` -> 雙方隊伍開始投票選擇隊長
		* 雙方隊伍必須先滿人
	* 兩個隊長決定之後 -> 隊長開始各自選擇隊員 -> 選擇完隊員之後 -> 自動分配隊伍
	* 支援Readyup插件
	* 只限回合開始前使用

* 用意在哪？
	* 對抗模式不知道怎麼分配玩家時可以使用這個插件
	* 避免每次都是那幾個人同一個隊伍，增加隊伍多樣性

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_mix.cfg
		```php
		// 兩方的隊長如何輪流選擇隊員, 0 = ABABAB | 1 = ABBAAB | 2 = ABBABA
		l4d_mix_select_order "1"

		// 為1時，旁觀者可以投票選擇隊長
		l4d_mix_spectator_vote "1"

		// 為1時，可以投票選擇旁觀者為隊長
		// 為1時，隊長可以選擇旁觀者為隊員
		l4d_mix_vote_spectator "1"

		// 如何選出隊長 ? 0=大家投票, 1=兩隊會隨機選一位出來當隊長
		l4d_mix_choose_captain "0"
		```
</details>

* <details><summary>命令中文介紹 (點我展開)</summary>

	* **開啟Mix選擇隊長 (需要雙方隊伍同意)**
		```php
		sm_mix
		```

	* **強制Mix啟動，投票選擇隊長 (權限: ADMFLAG_ROOT)**
		```php
		sm_forcemix
		```
</details>