# Description | 內容
Forces AI tank to leave stasis and attack while spawn in coop/realism.

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* <details><summary>How does it work?</summary>

	* (Before) AI Tank will stand still until survivors come over and see the tank in coop/realism mode
	* (After) AI Tank will move forward to attack survivors when spawned in coop/realism mode
	* Make 1-Damage-point of random alive survivor on ai tank to make tank leave stasis
		* [Can't set 0 damage](https://developer.valvesoftware.com/wiki/Point_hurt), go ask valve
</details>

* Apply to | 適用於
	```
	L4D1 Coop
	L4D2 Coop/Realism
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.1h (2023-8-19)
		* Optimize Code

	* v1.0h (2023-7-27)
		* Remake Code
		* Add ConVar

	* v0.1
		* [Original Plugin by XDglory](https://forums.alliedmods.net/showpost.php?p=2679726&postcount=13)
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\l4d_tankAttackOnSpawn.cfg
		```php
		// 0=Plugin off, 1=Plugin on.
		l4d_tankAttackOnSpawn_allow "1"

		// Tank chases survivors in seconds after tank spawns in coop
		l4d_tankAttackOnSpawn_seconds "3.0"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

- - - -
# 中文說明
戰役/寫實模式下，AI Tank一生成會直接往前進並攻擊倖存者，而非待在原地等待

* 原理
	* (安裝此插件之前) 戰役/寫實模式下，AI Tank 會原地不動，等待倖存者走過來發現
	* (安裝此插件之後) 戰役/寫實模式下，AI Tank 一生成會直接往前攻擊倖存者
	* 此插件製造1滴血的倖存者傷害給AI Tank，使Tank直接往前攻擊，因此Tank血量會少1
		* [無法設定0傷](https://developer.valvesoftware.com/wiki/Point_hurt), 去問Valve

* 用在意哪?
	* 增加遊戲難度
