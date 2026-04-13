# Description | 內容
Fixing null pointer dereference when it call SurvivorBot::IsReachable with NULL argument

* Apply to | 適用於
	```
	L4D2 Linux
	```
	
* Require | 必要安裝
<br/>None

* How does it fix?
	* [More details](https://forums.alliedmods.net/showpost.php?p=2725898&postcount=22)
	* Linux
		```c
		server_srv.so!SurvivorBot::IsReachable(CBaseEntity*) const + 0xe
		server_srv.so!SurvivorUseObject::ShouldGiveUp(SurvivorBot*) const + 0x112
		server_srv.so!SurvivorBot::ScavengeNearbyItems(Action<SurvivorBot>*) + 0x28d
		server_srv.so!SurvivorBehavior::Update(SurvivorBot*, float) + 0x4c6
		server_srv.so!Action<SurvivorBot>::InvokeUpdate(SurvivorBot*, Behavior<SurvivorBot>*, float) + 0xd2
		server_srv.so!SurvivorIntention::Update() + 0x119
		```
	* [Other useful fixes to prevent crashes](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/English/Server/Install_Fix)

* <details><summary>Changelog | 版本日誌</summary>

	* Original & Credit
		* [All codes and signature by Dragokas](https://forums.alliedmods.net/showpost.php?p=2725898&postcount=22)
</details>

- - - -
# 中文說明
修正崩潰: ```SurvivorBot::IsReachable``` 涵式內的空指針

* 原理
	* 想看更多細節查看: [Dragokas的解釋](https://forums.alliedmods.net/showpost.php?p=2725898&postcount=22)
	* Linux 崩潰推疊
		```c
		server_srv.so!SurvivorBot::IsReachable(CBaseEntity*) const + 0xe
		server_srv.so!SurvivorUseObject::ShouldGiveUp(SurvivorBot*) const + 0x112
		server_srv.so!SurvivorBot::ScavengeNearbyItems(Action<SurvivorBot>*) + 0x28d
		server_srv.so!SurvivorBehavior::Update(SurvivorBot*, float) + 0x4c6
		server_srv.so!Action<SurvivorBot>::InvokeUpdate(SurvivorBot*, Behavior<SurvivorBot>*, float) + 0xd2
		server_srv.so!SurvivorIntention::Update() + 0x119
		```
	* [安裝其他實用的修復崩潰列表](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_教學區/Chinese_繁體中文/Server/安裝實用的修復)