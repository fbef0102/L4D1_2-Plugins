# Description | 內容
Records player chat messages to a file

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* Require | 必要安裝
<br/>None

* <details><summary>How does it work?</summary>

    * Save chat messages player says and save cmd player types in file
    * ```sourcemod\logs\chat\server_xxxxx_chat_yy_mm_dd.txt```
        * ```xxxxx``` is server port
        * ```yy``` is year
        * ```mm``` is month
        * ```dd``` is day
</details>

* <details><summary>Related | 相關插件</summary>

    1. [sm_regexfilter](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Source_插件/Anti_Griefer_防惡意路人/sm_regexfilter): Filter dirty words via Regular Expressions
        * 禁詞表，任何人打字說出髒話或敏感詞彙，字詞會被屏蔽、玩家禁言並處死，網路並非法外之地
</details>

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/savechat.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        savechat_enable "1"

        // If 1, Record and save console commands.
        savechat_cosole_command "1"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v2.0 (2023-10-29)

        * Optimize code
    * v1.9 (2023-6-28)
        * Optimize code
        
    * v1.8 (2023-5-9)
        * Optimize code

    * v1.7 (2023-2-21)
        * Record comamnds

    * v1.6
        * Remake code
        * Record steam id、ip

    * v1.2.1
        * [Original Plugin by citkabuto](https://forums.alliedmods.net/showthread.php?p=1071512)
</details>

- - - -
# 中文說明
紀錄玩家的聊天紀錄到文件裡

* 原理
    * 當伺服器內玩家打字聊天時，將記錄玩家的對話到文件裡
    * 當伺服器內玩家在遊戲控制台輸入指令時，將記錄指令到文件裡
    * 會記錄玩家對話當下的IP、時間、Steam ID

* 用意在哪?
    * 拿來抓鬼、看誰他馬在講管理員壞話或抱怨伺服器
    * 當玩家有吵架或比賽作弊爭議時，方便有證據檢舉
    * 看哪個混帳在控制台輸入指令導致伺服器崩潰或卡頓

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/savechat.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        savechat_enable "1"

        // 為1時，玩家在遊戲控制台輸入指令時，將記錄到文件裡
        savechat_cosole_command "1"
        ```
</details>

* <details><summary>Save Chat文件</summary>

    * * ```sourcemod\logs\chat\server_xxxxx_chat_yy_mm_dd.txt```
        * ```xxxxx``` 是伺服器的端口，也就是port
        * ```yy``` 是年份
        * ```mm``` 是月份
        * ```dd``` 是日期
</details>