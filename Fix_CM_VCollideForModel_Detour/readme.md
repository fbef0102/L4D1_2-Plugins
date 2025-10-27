Author: [Dragokas](https://github.com/dragokas)

# Description | 內容
Fixed server crash caused by zero pointer of model_t passed to ```CM_VCollideForModel``` function

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
		engine.dll + 0x1d024
		engine.dll + 0x416f3
		engine.dll + 0x1acbf
		```
	* Linux
		```c
		engine.so!CM_VCollideForModel(int, model_t const*) + 0x19
		engine.so!CEngineTrace::ClipRayToVPhysics(Ray_t const&, unsigned int, ICollideable*, studiohdr_t*, CGameTrace*) + 0x11d
		engine.so!CEngineTrace::ClipRayToCollideable(Ray_t const&, unsigned int, ICollideable*, CGameTrace*) + 0xe9
		```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.2 (2025-10-27)
		* Private to public release
	
	* Original & Credit
		* [All codes and signature by Dragokas](https://github.com/dragokas)
</details>

- - - -
# 中文說明
修復崩潰: 傳給```CM_VCollideForModel``` 涵式內的zero pointer

* 原理
	* 想看更多細節查看資料夾: [crash_data](crash_data/)
	* Windows 崩潰推疊
		```c
		engine.dll + 0x1d024
		engine.dll + 0x416f3
		engine.dll + 0x1acbf
		```
	* Linux 崩潰推疊
		```c
		engine.so!CM_VCollideForModel(int, model_t const*) + 0x19
		engine.so!CEngineTrace::ClipRayToVPhysics(Ray_t const&, unsigned int, ICollideable*, studiohdr_t*, CGameTrace*) + 0x11d
		engine.so!CEngineTrace::ClipRayToCollideable(Ray_t const&, unsigned int, ICollideable*, CGameTrace*) + 0xe9
		```