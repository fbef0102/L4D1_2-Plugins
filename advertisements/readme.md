# Description | 內容
Display advertisements

* Video | 影片展示
<br/>None

* Image | 圖示
	* Display advertisements in chat box (顯示公告)
    <br/>![advertisements_1](image/advertisements_1.jpg)

* Require | 必要安裝
    1. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\advertisements.cfg
		```php
		// Enable/disable displaying advertisements.
		sm_advertisements_enabled "1"

		// File to read the advertisements from.
		sm_advertisements_file "advertisements.txt"

		// Amount of seconds between advertisements.
		sm_advertisements_interval "30"

		// Display advertisement sound file (relative to to sound/, empty=disable)
		sm_advertisements_soundfile "ui/beepclear.wav"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Reload the advertisements (Server Cmd)**
		```php
		sm_advertisements_reload
		```
</details>

* <details><summary>Data Config</summary>

	* [configs/advertisements.txt](configs/advertisements.txt)
		> Manual in this file, click for more details...
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Changelog | 版本日誌</summary>

	```php
	//DJ Tsunami @ 2008-2021
	//HarryPotter @ 2022-2023
	```
	* v2.2.1 (2023-4-22)
		* Remake Code
		* Remove updater
		* Add multicolors to support l4d1, l4d2

	* v2.1.0
		* [Original Plugin by DJ Tsunami](https://forums.alliedmods.net/showthread.php?t=155705)
</details>

- - - -
# 中文說明
廣告&公告欄插件，每隔一段時間於聊天框自動顯示一段內容

* 原理
	* 伺服器每隔一段時間會自動顯示一段內容，可以自行決定想要顯示的內容

* 用意在哪?
	* 打廣告，譬如澳門線上賭場，等你來挑戰，網址www.sexL4D2noob.com
	* 顯示公告，譬如歡迎加入XXX群組、官方FB社團XXXX、輸入XXX指令等等
	* 宣揚理念，譬如票投給美國共和黨支持XXX總統候選人

* 功能
	* 可設置廣告顯示間隔
	* 可設置廣告音效

* <details><summary>文件設定範例</summary>

	* [configs/advertisements.txt](configs/advertisements.txt)
		> 內有中文說明，可點擊查看
</details>