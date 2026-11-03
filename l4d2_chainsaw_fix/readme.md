# Description | 內容
Fixed server crash due to chainsaw sound and ower issue in l4d2

* Apply to | 適用於
	```
	L4D2
	```
	
* Require | 必要安裝
<br/>None

* How does it fix?
	* [Crash 1: [L4D2] Chainsaw server crash](https://github.com/ValveSoftware/Source-1-Games/issues/2526)
	* [Crash 2: [L4D2] Chainsaw server crash (again)](https://github.com/ValveSoftware/Source-1-Games/issues/3607)
	* [Crash 3: Chainsaw Owner pointer invalid or null](crash_data/CChainsaw_Drop.txt)
	* [Other useful fixes to prevent crashes](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/English/Server/Install_Fix)

* <details><summary>Changelog | 版本日誌</summary>

	* v1.1 (2026-11-3)
		* Fixed Crash "CSoundPatch::ChangePitch", prevent crash if CSoundPatch* is null
		* Fixed Crash "CSoundControllerImp::SoundChangePitch", prevent crash if CSoundControllerImp* or CSoundPatch* is null
		* Fixed Crash "CChainsaw::Drop", chainsaw owner pointer is invalid or null
		* Support windows
		* Fxxk you, valve, fix the chainsaw please

	* v1.0 (2025-10-26)
		* Combine codes and gamedata together
	
	* Original & Credit
		* [First fixed by accelerator74](https://github.com/ValveSoftware/Source-1-Games/issues/2526#issuecomment-738767488)
		* [Second fixed by Hawkins93](https://github.com/ValveSoftware/Source-1-Games/issues/3607#issuecomment-1833290785)
		* [Forgetest](https://github.com/jensewe): Provide offset to get the chainsaw owner
</details>

- - - -
# 中文說明
修復電鋸武器的音效與持有人異常引發的L4D2伺服器崩潰問題

* 原理
	* L4D2遊戲當中使用電鋸，因官方代碼問題，當音效或是持有人異常時會導致伺服器崩潰 (別問我，去問valve)
		* [崩潰1: [L4D2] Chainsaw server crash](https://github.com/ValveSoftware/Source-1-Games/issues/2526)
		* [崩潰2: [L4D2] Chainsaw server crash (again)](https://github.com/ValveSoftware/Source-1-Games/issues/3607)
		* [崩潰3: 指向電鋸持有人的指標不合法或是為空](crash_data/CChainsaw_Drop.txt)
	* [安裝其他實用的修復崩潰列表](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_教學區/Chinese_繁體中文/Server/安裝實用的修復)