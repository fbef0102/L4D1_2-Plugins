# Description | 內容
Spectator will stay as spectators on mapchange/new round.

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2024-2-19)
        * Require lef4dhooks
		* Remake code, convert code to latest syntax
		* Fix warnings when compiling on SourceMod 1.11.
		* Optimize code and improve performance
		* Support on vote change map in game
		* Support coop/survival/realism mode

	* 1.2
		* [From SirPlease/L4D2-Competitive-Rework](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/archive/l4d2_spec_stays_spec.sp)
</details>

- - - -
# 中文說明
上一回合是旁觀者的玩家, 下一回合開始時繼續待在旁觀者 (避免被自動切換到人類/特感隊伍)

* 原理
    * 上一回合是旁觀者的玩家，下一關/下一張地圖/新回合 開始時繼續待在旁觀者
	* 中途投票換圖也適用，插件會記錄玩家的Steam ID

* 用意在哪?
	* 避免旁觀者/閒雜人等被遊戲自動切換到人類/特感隊伍
