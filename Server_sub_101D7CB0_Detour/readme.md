https://forums.alliedmods.net/showpost.php?p=2730868&postcount=7

# Description | 內容
Fix Crash ```server.dll + 0x1d7cbb``` null pointer

* Apply to | 適用於
	```
	L4D1 windows
	```
	
* Require | 必要安裝
	1. [[INC] MemoryEx](https://github.com/dragokas/Memory-Extended)

* How does it fix?
	* More details in [crash_data](crash_data/) folder
	* Windows
		```c
		server.dll + 0x1d7cbb
		```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0
	* Original & Credit
		* [All codes and signature by Dragokas](https://github.com/dragokas)
</details>

- - - -
# 中文說明
修正崩潰: ```server.dll + 0x1d7cbb``` 涵式內的空指針

* 原理
	* 想看更多細節查看資料夾: [crash_data](crash_data/)
	* Windows 崩潰推疊
		```c
		server.dll + 0x1d7cbb
		```