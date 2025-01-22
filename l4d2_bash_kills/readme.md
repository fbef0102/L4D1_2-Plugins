# Description | 內容
Stop special infected getting bashed to death

* Apply to | 適用於
    ```
    L4D2
    ```

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d2_bash_kills.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        l4d2_bash_kills_enable "1"

        // Prevent smoker from getting bashed to death
        l4d2_bash_kills_smoker "1"
        
        // Prevent boomer from getting bashed to death
        l4d2_bash_kills_boomer "0"

        // Prevent hunter from getting bashed to death
        l4d2_bash_kills_hunter "1"

        // Prevent spitter from getting bashed to death
        l4d2_bash_kills_spitter "0"

        // Prevent jockey from getting bashed to death
        l4d2_bash_kills_jockey "1"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.0h (2024-4-29)
        * Add cvars to control each special infected

    * v1.4
        * [From SirPlease/L4D2-Competitive-Rework](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d_bash_kills.sp)
</details>

- - - -
# 中文說明
特感不會被人類右鍵推到死去

* 原理
    * (裝此插件之前) 特感會被人類右鍵推超過五次以上會死去，Charger除外
    * (裝此插件之後) 特感不會被推死

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d2_bash_kills.cfg
        ```php
        // 啟用插件 [0-關閉,1-開啟]
        l4d2_bash_kills_enable "1"

        // 為1時，Smoker不會被推死
        l4d2_bash_kills_smoker "1"
        
        // 為1時，Boomer不會被推死
        l4d2_bash_kills_boomer "0"

        // 為1時，Hunter不會被推死
        l4d2_bash_kills_hunter "1"

        // 為1時，Spitter不會被推死
        l4d2_bash_kills_spitter "0"

        // 為1時，Jockey不會被推死
        l4d2_bash_kills_jockey "1"
        ```
</details>