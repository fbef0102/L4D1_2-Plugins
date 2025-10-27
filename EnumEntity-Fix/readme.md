https://forums.alliedmods.net/showpost.php?p=2752346&postcount=10

# Description | 內容
Fix Crash ```CTriggerTraceEnum::EnumEntity``` null pointer

* Apply to | 適用於
	```
	L4D1 windows/linux
	```
	
* Require | 必要安裝
	1. [[INC] MemoryEx](https://github.com/dragokas/Memory-Extended)

* How does it fix?
	* More details in [crash_data](crash_data/) folder
	* Windows
		```c
		server.dll + 0x10684
		```
	* Linux
		```c
		server_srv.so!CTriggerTraceEnum::EnumEntity(I HandleEntity*) + 0x46
		```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.1
	* Original & Credit
		* [All codes and signature by Dragokas](https://github.com/dragokas)
		* [Psyk0tik - Fix detour byte](https://forums.alliedmods.net/showpost.php?p=2752346&postcount=10)
</details>

- - - -
# 中文說明
修正崩潰: ```CTriggerTraceEnum::EnumEntity``` 涵式內的空指針

* 原理
	* 想看更多細節查看資料夾: [crash_data](crash_data/)
	* Windows 崩潰推疊
		```c
		server.dll + 0x10684
		```
	* Linux 崩潰推疊
		```c
		server_srv.so!CTriggerTraceEnum::EnumEntity(I HandleEntity*) + 0x46
		```