# Description | 內容
Remove Dead Body Entity

* Apply to | 適用於
    ```
    L4D2
    ```

* <details><summary>How does it work?</summary>

	* When survivr dies, his dead boday left on the map.
		* Remove Dead Body after the certain time passed
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/clear_dead_body.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        sm_clear_dead_body_allow "1"

        // clear dead body in seconds
        sm_clear_dead_body_time "100.0"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.1
        * Initial Release
</details>

- - - -
# 中文說明
倖存者死亡之後過一段時間，移除屍體

* 原理
    * 倖存者死亡之後，如果過一段時間沒有人電擊復活，則移除屍體

* 用意在哪?
    * 避免伺服器塞滿過多的人類屍體實體導致崩潰 (伺服器實體物件空間不足)
    * 適合用於多人倖存者伺服器上

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/clear_dead_body.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        sm_clear_dead_body_allow "1"

        // 倖存者死亡後，過一段時間沒有人電擊復活則自動移除屍體
        sm_clear_dead_body_time "100.0"
        ```
</details>