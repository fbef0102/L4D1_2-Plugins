# Description | 內容
Maximum of tanks in server.

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * Kick AI Tank if the number of tanks exceed the cvar limit
        * Won't kick real tank player
    * I wrote this for playing custom map ["Tank Playground"](https://steamcommunity.com/sharedfiles/filedetails/?id=121108123) back in 2018
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d_tanklimit.cfg
        ```php
        // Maximum of tanks in server.
        z_tank_limit "3"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.2
        * Initial Release
</details>

- - - -
# 中文說明
在場上的Tank數量有限制，超過便處死

* 原理
    * 如果Tank數量超過指令的限制，則處死AI Tank
        * 不會處死真人玩家操控的Tank

* 用意在哪?
    * 拿來限制["Tank競技場"](https://steamcommunity.com/sharedfiles/filedetails/?id=121108123)三方圖生成Tank的數量，在2018年所寫的插件

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d_tanklimit.cfg
        ```php
        // Tank允許存在的數量
        z_tank_limit "3"
        ```
</details>
