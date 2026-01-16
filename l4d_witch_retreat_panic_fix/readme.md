# Description | 內容
Fixed the bug that witch cancels retreat and comes back to chase survivor again if game starts panic event

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* [Video | 影片展示](https://youtu.be/wZCSs6JLvzA)
	
* Require | 必要安裝
	1. [Actions](https://forums.alliedmods.net/showthread.php?t=336374)
	2. [witch_allow_in_safezone](https://forums.alliedmods.net/showthread.php?t=315481)
	3. [witch_prevent_target_loss](https://forums.alliedmods.net/showthread.php?t=315481)

* <details><summary>How does it work?</summary>

	* How to reproduce the bug
		1. Witch kills survivor and retreat
		2. Trigger Horde Panic Event (By Alarm Car/Map Event/Game Director/Plugin Code)
		3. Witch comes back to chase survivor again
</details>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_witch_retreat_panic_fix.cfg
		```php
		// 0=Plugin off, 1=Plugin on.
		l4d_witch_retreat_panic_fix_enable "1"
		```
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0 (2025-10-5)
		* Initial Release
	
	* Original & Credit
		* [Code assist by forgetest](https://github.com/jensewe)
</details>

- - - -
# 中文說明
修復Witch撤退之後又馬上重新攻擊倖存者的Bug

* 原理
	* 如何重現這個Bug?
		1. Witch殺死人之後撤退
		2. 觸發屍潮事件 (地圖機關/插件代碼/警報車/遊戲導演系統)
		3. Witch重新追擊倖存者

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_witch_retreat_panic_fix.cfg
		```php
		// 0=關閉插件, 1=啟動插件
		l4d_witch_retreat_panic_fix_enable "1"
		```
</details>
