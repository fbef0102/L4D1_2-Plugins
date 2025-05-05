# Description | 內容
Auto Takes Over an alive free bot UponDeath or OnBotSpawn in 5+ survivor

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/_AutoTakeOver.cfg
		```php
        // 0=Plugin off, 1=Plugin on.
        AutoTakeOver_enabled "1"

        // If 1, you will skip idle state in survival/coop/realism.
        AutoTakeOver_coop_take_over_method "0"

        // If 1, when a survivor player dies, he will take over an alive free bot if any. (Random choose bot)
        AutoTakeOver_take_over_UponDeath "1"

        // If 1, when a survivor bot spawns or replaces a player, any dead survivor player will take over bot. (Random choose dead survivor)
        AutoTakeOver_take_over_OnBotSpawn_dead "1"

        // If 1, when a survivor bot spawns or replaces a player, any free spectator player will take over bot. (Random choose free spectator)
        AutoTakeOver_take_over_OnBotSpawn_spectator "0"

        // If 1, when a player joins server, he will take over an alive free bot if any. (Random choose bot)
        AutoTakeOver_take_over_OnJoinServer "1"
		```
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v2.3
        * [AlliedModders Post](https://forums.alliedmods.net/showpost.php?p=2773718&postcount=16)
        * Remake Code
        * Add more convars
        * Use left4dhooks functions to take over free bots.

	* v2.0
		* [Original Plugin by Lux](https://forums.alliedmods.net/showthread.php?t=293770)
</details>

- - - -
# 中文說明
當真人玩家死亡時，自動取代另一個有空閒的Bot繼續遊玩倖存者

* 原理
	* 當真人玩家死亡時，自動取代另一個有空閒的Bot繼續遊玩倖存者
	* 當有空閒的Bot復活時，自動給死亡的真人玩家或旁觀者取代

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/_AutoTakeOver.cfg
		```php
        // 0=關閉插件, 1=啟動插件
        AutoTakeOver_enabled "1"

        // 為1時，玩家直接取代bot而非先閒置 (戰役/生存/寫實)
        AutoTakeOver_coop_take_over_method "0"

        // 為1時，當真人玩家死亡時，自動取代另一個有空閒的Bot (隨機挑選bot)
        AutoTakeOver_take_over_UponDeath "1"

        // 為1時，當有空閒的Bot復活時，自動給死亡的真人玩家取代 (隨機挑選死亡的真人玩家)
        AutoTakeOver_take_over_OnBotSpawn_dead "1"

        // 為1時，當有空閒的Bot復活時，自動給旁觀者取代 (隨機挑選旁觀者)
        AutoTakeOver_take_over_OnBotSpawn_spectator "0"

        // 為1時，玩家加入遊戲時，自動取代有空閒的Bot (隨機挑選bot)
        AutoTakeOver_take_over_OnJoinServer "1"
		```
</details>

