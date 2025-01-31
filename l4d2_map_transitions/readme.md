# Description | 內容
Define map transitions to combine campaigns in versus

* Apply to | 適用於
	```
	L4D2 versus
	```

* <details><summary>How does it work?</summary>

	* Change map to another map when versus second round ends
	* For example: write down the following in ```cfg/server.cfg```
		```php
		// Change map to c7m1_docks when versus second round ends in c6m2_bedlam
		sm_add_map_transition c6m2_bedlam c7m1_docks

		// Change map to c9m2_lots when versus second round ends in c14m1_junkyard
		sm_add_map_transition c9m2_lots c14m1_junkyard
		```
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>Recommand Install | 推薦安裝</summary>

	1. [l4d2_fix_changelevel](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d2_fix_changelevel): Fix issues due to forced changelevel.
		> 修復手動更換地圖會遇到的問題
	2. [l4d2_transition_info_fix](/l4d2_transition_info_fix): Fix issues after map transitioned, transition info is still retaining when changed new map by other ways.
		> 修復中途換地圖的時候(譬如使用Changelevel指令)，會遺留上次的過關保存設定，導致滅團後倖存者被傳送到安全室之外或死亡
</details>

* <details><summary>Command | 命令</summary>

	* **Change to ending map when versus second round ends in starting map**
		```php
		sm_add_map_transition <starting map name> <ending map name>
		```
</details>

* <details><summary>API | 串接</summary>

	* [l4d2_map_transitions.inc](scripting/include/l4d2_map_transitions.inc)
		```php
		library name: l4d2_map_transitions
		```
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2025-1-30)
		* API & Native

	* Original
		* [SirPlease/L4D2-Competitive-Rework](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_map_transitions.sp)
</details>

- - - -
# 中文說明
對抗模式第二回合結束時從地圖A切換成地圖B

* 原理
	* 從ZoneMode拿過來修改，整合地圖用
	* 舉例：寫以下內容到 ```cfg/server.cfg```
		```php
		// c6m2_bedlam 關卡結束時切換到 c7m1_docks (對抗模式第二回合結束)
		sm_add_map_transition c6m2_bedlam c7m1_docks

		// c9m2_lots 關卡結束時切換到 c14m1_junkyard (對抗模式第二回合結束)
		sm_add_map_transition c9m2_lots c14m1_junkyard
		```

* <details><summary>命令中文介紹 (點我展開)</summary>

	* **對抗模式第二回合結束時從關卡A切換成關卡B**
		```php
		sm_add_map_transition <關卡A> <關卡B>
		```
</details>