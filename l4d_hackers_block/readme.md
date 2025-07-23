# Description | 內容
Block hackers using some exploit to crash server

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* Require | 必要安裝
<br>None

* <details><summary>How does it work?</summary>

    * How hackers do
        1. Triggers some commands on client side to crash the server. 
            * Normally, these commands are restricted, but the attacker can trigger them somehow
        2. Stops steam server from validating steam id, so sourcemod banid not working for them (no steam id)
    * How this plugin does
        1. Register some dangerous commands and block entirely
            * Kick client if abuse crash command
        2. Kick players if client's authentication failed (steam id is not valid)
        3. Force to spec + Block chat voicecast of votes and commands while no steam id available
        4. Log record: [logs/l4d_hackers_block.log](logs/l4d_hackers_block.log)
    * What you can do to prevent hackers
        1. Set ```sm_cvar sv_allow_wait_command 0``` to your ```cfg/server.cfg``` to block certain command exploits.
        2. Check ```sv_cheats 0``` and ensure no plugins override it.
        3. Restrict Access, nobody has root(z) access or any suspicious permissions in server 
            * Type ```sm_who``` in server console to check admins in server
</details>

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d_hackers_block.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        l4d_hackers_block_enable "1"

        // Time in seconds to check if players has steam id authorized after join server
        l4d_hackers_block_time "10.0"

        // 1=Kick the player if no steam id authorized, 0=Log only
        l4d_hackers_block_kick "1"

        // If 1, Force to spec/Block chat/Block voice/Block commands while no steam id available
        l4d_hackers_block_spec "1"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.2 (2025-7-23)
        * Update cvars
        * Force to spec while no steam id available

    * v1.1 (2025-7-20)
        * Update cvars
        * Block chat voice, cast of votes and commands while no steam id available
        * Kick client if abuse crash command

    * v1.0 (2025-7-19)
        * Initial Release
        * Thanks to IfChinsCouldKill
</details>

- - - -
# 中文說明
阻止駭客利用某些漏洞導致伺服器崩潰

* 原理
    * 駭客操作
        1. 在遊戲客戶端觸發一些指令導致伺服器崩潰
            * 通常情況下，這些指令肯定被限制不能觸發，但是駭客總有辦法
        2. 繞過steam驗證，導致無法獲得該玩家的steam id，使其無法被伺服器封鎖ID (因為steam id抓不到) 
    * 這插件做了什麼
        1. 阻擋一些指令被觸發
            * 頻繁使用會被踢出伺服器
        2. 踢出steam驗證失敗的玩家 (steam id抓不到)
        3. 當玩家沒有steam id驗證時，強制旁觀、禁語音、禁言打字、禁止使用控制台發送指令給伺服器
        4. 紀錄文件: [logs/l4d_hackers_block.log](logs/l4d_hackers_block.log)
    * 你可以做甚麼防止駭客
        1. 在```cfg/server.cfg```文件中設置 ```sm_cvar sv_allow_wait_command 0```
            * 禁止客戶端使用```wait```以阻擋一些奇葩指令或自製腳本
        2. 檢查 ```sv_cheats```永遠都是保持0且沒有插件或模組覆蓋
        3. 限制管理員權限，不應該設置太多管理員擁有Z權限，或刪除具有可疑權限的玩家
            * 伺服器後台輸入 ```sm_who```可以檢查伺服器內擁有權限的玩家

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d_hackers_block.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        l4d_hackers_block_enable "1"

        // 延遲檢查玩家是否有steam id驗證的時間
        l4d_hackers_block_time "10.0"

        // 1=踢出steam驗證失敗的玩家 (steam id抓不到), 0=只記錄log文件
        l4d_hackers_block_kick "1"

        // 為1時，當玩家沒有steam id驗證時，強制旁觀、禁語音、禁言打字、禁止使用控制台發送指令給伺服器
        l4d_hackers_block_spec "1"
        ```
</details>
