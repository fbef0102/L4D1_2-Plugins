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

	* v1.6
        * Remake code
        * Record steam id、ip

	* v1.2.1
        * [Original Plugin by citkabuto](https://forums.alliedmods.net/showthread.php?p=1071512)
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\savechat.cfg
		```php
        // Record player Steam ID and IP address
        sc_record_detail "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* Save Chat File
    * left4dead\addons\sourcemod\logs\chat\server_xxxxx_chat_yyyy_mm_dd.txt
        * ```xxxxx``` is server port
        * ```yyyy``` is year
        * ```mm``` is month
        * ```dd``` is day

- - - -
# 中文說明
紀錄玩家的聊天紀錄到文件裡

* 原理
    * 當伺服器內玩家打字聊天時，將記錄玩家的對話到文件裡
    * 拿來抓鬼、看誰他馬講管理員壞話或抱怨伺服器
    * 當玩家有吵架或比賽作弊爭議時，方便有證據檢舉

* 功能
    * 會記錄玩家對話當下的IP、時間、Steam ID

* Save Chat　文件
	* left4dead\addons\sourcemod\logs\chat\server_xxxxx_chat_yyyy_mm_dd.txt
        * ```xxxxx``` 是伺服器的端口，也就是port
        * ```yyyy``` 是年份
        * ```mm``` 是月份
        * ```dd``` 是日期





    
