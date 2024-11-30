# Description | 內容
Executes cfg file on server startup only one time

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* <details><summary>How does it work?</summary>

	* Make server to execute ```cfg/server_startup.cfg``` only one time on server startup
</details>

* Require | 必要安裝
<br/>None

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.3 (2023-2-21)
		* Support L4D1

	* v1.2 (2023-2-4)
		* Initial Release
</details>


* <details><summary>ConVar | 指令</summary>

	None
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

- - - -
# 中文說明
開服只執行一次的cfg檔案

* 原理
    * 啟動伺服器之後自動執行一個cfg檔案，只會執行一次
		* ```cfg/server_startup.cfg```

* 用意在哪?
	* 有些指令只需要一開始設定一次就行了，不適合寫在```cfg/server.cfg```，譬如伺服器人數上限、遊戲模式等等
        * ```cfg/server.cfg``` 是每次換地圖必定會執行的檔案