# Description | 內容
Prevent finale softlocks when maps use ForceFinaleStart because not all survivors are in FINALE attribute area

* [Video | 影片展示](https://youtu.be/7SCPHQQAF_M)

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>How does it work?</summary>

	* (Before) In some maps, when the map tried to force start the finale, it would sometimes fail because not all survivors are inside `FINALE` attribute NAV area.
        * In other words, the game failed to start the finale because some survivors were NOT in the rescue area.
        * Example: On maps like c1m4 and c6m3, the map automatically forces the finale to start when survivors take the elevator down.
            * However, if any survivor is outside the elevator area (e.g., still in the saferoom), the finale will fail to trigger.
            * Even after filling all the gas cans, survivors cannot escape because the finale event never actually started.
        * This bug is also common in many custom maps, and is even more likely to happen on multi-Survivor / multi-SI servers
            * Because many players tend to wander off alone.
    * (After) When the input `"ForceFinaleStart"` is detected on the [`trigger_finale` entity](https://developer.valvesoftware.com/wiki/Filter_activator_model) 
        * This plugin temporarily applies the `FINALE` attribute to all NAV areas, and restores them back on the next frame.
    * Maps that require using the radio to start the finale, such as c2m5 and c8m5, are not affected by this plugin.
</Chargedetails>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* Directory Structure | 檔案結構
    ```php
	/
	├── plugins/
	│	└── l4d_forcefinalestart_fix.smx            # Compiled plugin | 已編譯的插件   
	└── scripting/
		└── l4d_forcefinalestart_fix.sp             # Source code | 源碼
	```

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d_forcefinalestart_fix.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        l4d_forcefinalestart_fix_enable "1"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.0 (2026-10-24)
        * Initial Release

    * Credit
        * [Codes about Nav from Marttt](https://forums.alliedmods.net/showthread.php?t=333274)
</details>

- - - -
# 中文說明
防止救援無法開始而地圖卡關，當地圖使用 ForceFinaleStart 時並非所有倖存者都在 FINALE 屬性區域內

* 原理
	* (裝此插件之前) 在一些地圖當中，當地圖強制開啟救援時會失敗，因為並非所有倖存者都在 `FINALE` 屬性的NAV區域
        * 通俗點講就是有人不在救援區域內，導致遊戲無法開始救援
        * 舉例: 在c1m4與c6m3地圖中，倖存者搭乘電梯下樓，此時地圖會強制開始救援
            * 但是當有倖存者不在電梯範圍內時(譬如在安全室)，將會導致救援無法開始
            * 即使灌了所有汽油桶，依然無法上車逃離，因為救援根本就沒有開始
        * 在其他非官方地圖也很常見這種bug，多人多特感的伺服器更容易觸發這種bug
            * 因為大家都會亂跑脫離隊伍
    * (裝此插件之後) 當檢測到有 `"ForceFinaleStart"` 輸入於 [`trigger_finale` 物件 (只出現於救援關卡)](https://developer.valvesoftware.com/wiki/Filter_activator_model) 時
        * 此插件會暫時將場上所有NAV增加 `NAV_FINALE` 屬性，下一偵之後會恢復所有NAV
    * C2M5, C8M5 這些需要使用對講機頻繁觸發救援的關卡不受此插件影響

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d_forcefinalestart_fix.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        l4d_forcefinalestart_fix_enable "1"
        ```
</details>