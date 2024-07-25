# Description | 內容
Fixes issue when a bot die, his IDLE player become fully spectator rather than take over dead bot in 4+ survivors games

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>ConVar | 指令</summary>

	None
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h
        * [AlliedModders Post](https://forums.alliedmods.net/showpost.php?p=2772050&postcount=54)
        * Remove lots of unuse code
        * Fixes issue when a bot die, his IDLE player become fully spectator rather than take over dead bot in 4+ survivors games

	* v1.2
		* [Original Plugin by mi123645](https://forums.alliedmods.net/showthread.php?t=132409)
</details>

- - - -
# 中文說明
修正5+多人遊戲裡，當真人玩家閒置的時候如果他的Bot死亡，真人玩家不會取代死亡Bot而是變成完全旁觀者

* 原理
	* (裝此插件之前) 當真人玩家閒置的時候如果他的Bot死亡，玩家不會取代死亡Bot而是變成旁觀者 (5+多人遊戲常出現的bug)
	* (裝此插件之後) 當真人玩家閒置的時候如果他的Bot死亡，玩家會取代死亡Bot


