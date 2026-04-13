Author: [Dragokas](https://github.com/dragokas)

# Description | 內容
Temp. walkaround agains wrong mem. address access in ```Tier0```, maybe some mem. scan related

* Apply to | 適用於
	```
	L4D2 windows
	```
	
* Require | 必要安裝
	1. [[INC] MemoryEx](https://github.com/dragokas/Memory-Extended)

* How does it fix?
	* Windows
		```c
		tier0.dll + 0x1991d
		```
	* [Other useful fixes to prevent crashes](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/English/Server/Install_Fix)

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0 (2025-10-27)
		* Private to public release
	
	* Original & Credit
		* [All codes and signature by Dragokas](https://github.com/dragokas)
</details>

- - - -
# 中文說明
修復崩潰 ```tier0.dll``` 涵式相關記憶體錯誤

* 原理
	* 想看更多細節查看資料夾: [crash_data](crash_data/)
	* Windows 崩潰推疊
		```c
		tier0.dll + 0x1991d
		```
	* [安裝其他實用的修復崩潰列表](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_教學區/Chinese_繁體中文/Server/安裝實用的修復)