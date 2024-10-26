# Description | 內容
Restart server when the last player disconnects from the server.

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* Require | 必要安裝
<br/>None

* <details><summary>How does it work?</summary>

  * When the last player disconnects from the server, this plugin will force server crash itself.
  * This plugin does not restart your server, you need to use server tools or linux system, which make server auto-restart if crash. For example
    1. LINUX
    2. WINDOWS with [seDirector](https://sedirector.net/)
  * Keep your server clean and fresh, get rid of laggy and huge memory usage
  * Unload [Accelerator extension](https://forums.alliedmods.net/showthread.php?t=277703) automatically before crash. Avoid crash report spam.
</details>

* <details><summary>ConVar | 指令</summary>

	None
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Related Plugin | 相關插件</summary>

	1. [asherkin/Accelerator](https://forums.alliedmods.net/showthread.php?t=277703): Analyses crash reports to extract useful information and uploads the crash reports
		> 伺服器崩潰會有記錄，可以查看崩潰日誌
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v3.1 (2024-10-26)
		* Optimize Code
		
	* v3.0 (2024-3-19)
		* Add log

	* v2.9 (2024-2-27)
	* v2.8 (2024-1-21)
		* Optimize Code

	* v2.4 (2023-3-29)
		* Auto detect Accelerator extension and unload extension　before shutdown
		* Remove Cvar

	* v1.0
		* Initial Release
</details>

- - - -
# 中文說明
最後一位玩家離開伺服器之後自動關閉Server並重啟

* 原理
	* 當最後一位玩家離開伺服器之後過一段時間，如果還是沒有人那麼插件會強制關閉伺服器
    * 這插件不會重啟你的伺服器，而是強制結束伺服器而已

* 用意在哪?
    * 此插件用來配合一些軟體或腳本開服，伺服器被關閉時會自己自動重啟
    * 適合7天24小時全天候開服的伺服器，持續讓你的伺服器重啟保持新的狀態，避免開服過久導致卡頓與lag

* 推薦的開服方式，伺服器被關閉時會自己自動重啟
    1. Linux系統
    2. Windows系統的[seDirector](https://sedirector.net/)開服工具

* 注意事項
    * 這插件會自動偵測伺服器有無安裝 [asherkin/Accelerator](https://forums.alliedmods.net/showthread.php?t=277703)，會在強制關閉之前卸載Accelerator，避免重複產生崩潰日誌
        * 如果沒安裝則忽略
