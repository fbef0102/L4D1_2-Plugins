# Description | 內容
Fix issues after map transitioned, transition info is still retaining when changed new map by other ways.

* Apply to | 適用於
	```
	L4D2
	```

* <details><summary>How does it work?</summary>

	* After map transitioned, transition info is still retaining when changed new map by other ways (such "changelevel" command).
		* This can cause survivors spawn dead or teleport outside the saferoom when restarting the round. 
	* This plugin will clear those transition info if no longer is transitioned map.
</details>

* Require | 必要安裝
	1. [l4d2_fix_changelevel](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d2_fix_changelevel): Fix issues due to forced changelevel.
		* 修復手動更換地圖會遇到的問題

* <details><summary>Known Issue</summary>

	1. If a player disconnects from server when map change, server loading second map too long and everyone in the server stuck in this situation
		* To this Bug, write down the following cvars in cfg/server.cfg
			```php
			// Duration (in seconds) to wait for survivors to transition across changelevels (default: 120)
			sm_cvar director_transition_timeout 50

			// Duration (in seconds) to wait to unfreeze a team after the first player has connected (default: 55)
			sm_cvar director_unfreeze_time 40
			```
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0.2 (2024-12-30)
		* Fix Gamedate wrong signature name: Signature ServerShutdown invalid.

	* v1.0.1
		* [Original Plugin by iaNanaNana](https://forums.alliedmods.net/showthread.php?t=335117)
</details>

- - - -
# 中文說明
修復中途換地圖的時候(譬如使用Changelevel指令)，會遺留上次的過關保存設定，導致滅團後倖存者被傳送到安全室之外或死亡

* 原理
	* 幫原作者修復gamedata簽證問題: Signature ServerShutdown invalid.

* <details><summary>已知問題</summary>

	1. 如果玩家在換圖過程中離線，將導致所有玩家卡在loading介面大約120秒
		* 為了修復這問題，寫入以下指令在cfg/server.cfg
			```php
			// 換圖時等待連線玩家的時間，時間到或所有玩家到齊才會載入地圖 (預設: 120)
			sm_cvar director_transition_timeout 50

			// 換圖時第一位玩家連線之後，經過的時間到才會載入地圖 (預設: 55)
			sm_cvar director_unfreeze_time 40
			```
</details>