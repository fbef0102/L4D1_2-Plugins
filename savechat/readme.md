# Description | 內容
Records player chat messages to a file

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None


* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.7 (2023-2-21)
        * Record comamnds

	* v1.6
        * Remake code
        * Record steam id、ip

	* v1.2.1
        * [Original Plugin by citkabuto](https://forums.alliedmods.net/showthread.php?p=1071512)
</details>

* Require | 必要安裝
<br/>None

* Related | 相關插件
    1. [sm_regexfilter](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Anti_Griefer_%E9%98%B2%E6%83%A1%E6%84%8F%E8%B7%AF%E4%BA%BA/sm_regexfilter): Filter dirty words via Regular Expressions
        * 禁詞表，任何人打字說出髒話或敏感詞彙，字詞會被屏蔽、玩家禁言並處死，網路並非法外之地

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\savechat.cfg
		```php
        // If 1, Record and save console commands.
        savechat_cosole_command "1"

        // 0=Plugin off, 1=Plugin on.
        savechat_enable "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* Save Chat File
    * left4dead\addons\sourcemod\logs\chat\server_xxxxx_chat_yy_mm_dd.txt
        * ```xxxxx``` is server port
        * ```yy``` is year
        * ```mm``` is month
        * ```dd``` is day

- - - -
# 中文說明
紀錄玩家的聊天紀錄到文件裡

* 原理
    * 當伺服器內玩家打字聊天時，將記錄玩家的對話到文件裡
    * 當伺服器內玩家在遊戲控制台輸入指令時，將記錄指令到文件裡

* 用意在哪?
    * 拿來抓鬼、看誰他馬在講管理員壞話或抱怨伺服器
    * 當玩家有吵架或比賽作弊爭議時，方便有證據檢舉
    * 看哪個混帳在控制台輸入指令導致伺服器崩潰或卡頓

* 功能
    * 會記錄玩家對話當下的IP、時間、Steam ID
    * 會記錄玩家在遊戲控制台輸入的指令

* Save Chat　文件
	* left4dead\addons\sourcemod\logs\chat\server_xxxxx_chat_yy_mm_dd.txt
        * ```xxxxx``` 是伺服器的端口，也就是port
        * ```yy``` 是年份
        * ```mm``` 是月份
        * ```dd``` 是日期