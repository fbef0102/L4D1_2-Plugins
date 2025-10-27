Author: [Dragokas](https://github.com/dragokas)

# Description | 內容
Fixing the crash with null pointer dereference in ```CM_GetCollideableTriggerTestBox```

* Apply to | 適用於
	```
	L4D2 windows/linux
	```
	
* Require | 必要安裝
<br/>None

* How does it fix?
	* More details in [crash_data](crash_data/) folder
	* Windows
		```c
		engine.dll + 0x20fbad
		```

	* Linux
		```c
		engine_srv.so!CM_GetCollideableTriggerTestBox(ICollideable*, Vector*, Vector*, bool) + 0x90
		engine_srv.so!SV_SolidMoved(edict_t*, ICollideable*, Vector const*, bool) + 0x78
		server_srv.so!CBaseEntity::PhysicsTouchTriggers(Vector const*) + 0x15d
		server_srv.so!CBaseEntity::PhysicsRigidChild() + 0x1a2
		```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.1 (2025-10-27)
		* Private to public release
	
	* Original & Credit
		* [All codes and signature by Dragokas](https://github.com/dragokas)
</details>

- - - -
# 中文說明
修復崩潰 ```CM_GetCollideableTriggerTestBox``` 涵式內的空指針

* 原理
	* 想看更多細節查看資料夾: [crash_data](crash_data/)
	* Windows 崩潰堆疊追蹤
		```c
		engine.dll + 0x20fbad
		```

	* Linux 崩潰堆疊追蹤
		```c
		engine_srv.so!CM_GetCollideableTriggerTestBox(ICollideable*, Vector*, Vector*, bool) + 0x90
		engine_srv.so!SV_SolidMoved(edict_t*, ICollideable*, Vector const*, bool) + 0x78
		server_srv.so!CBaseEntity::PhysicsTouchTriggers(Vector const*) + 0x15d
		server_srv.so!CBaseEntity::PhysicsRigidChild() + 0x1a2
		```