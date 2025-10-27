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