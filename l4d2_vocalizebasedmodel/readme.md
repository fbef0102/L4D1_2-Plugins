# Description | 內容
Survivors will vocalize based on their model + Fixes conversation stucks when playing with l4d1+2 survivor models in custom maps

* Apply to | 適用於
    ```
    L4D2
    ```

* [Video | 影片展示](https://youtu.be/tIFKr-Yaxyk)

* <details><summary>How does it work?</summary>

    * (Before) In some custom maps, important events often detect which survivor and play certain conversation lines, however maps may not consider different survivor character
        * For example, Bill can response to the rescue radio on a map with the L4D1 survivor set
        * But if player changes character to Nick (such as CSM), Nick can not response to the rescue radio and the map would softlock because map never considered l4d2 survivor characters.
    * (After) If a campaign sequence has a [```func_orator``` entity managing survivor conversations](https://developer.valvesoftware.com/wiki/Func_orator)
        * Whenever a survivor activates it (SpeakResponseConcept), this plugin turns a survivor to map set original character temporarily
        * For example: Survivors keep telling to turn off the alarm in The Parish Map 2, or most rescue radios keep asking if there's anyone alive.
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>Support | 支援插件</summary>

	1. [l4d2_trigger_flow_fix](/l4d2_trigger_flow_fix): Prevents custom maps from softlocking due to a poorly filter_activator_model's logic when playing with different survivor models
		* 修復不同模組的倖存者在三方地圖啟動地圖上的機關會出現問題
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.0h (2026-1-27)
        * Optimize code
        * Remove targetname bind
        * Try to fix conversation stucks when playing with l4d1+2 survivor models in custom maps
        * Add left4dhooks

    * Credit
        * [Original Plugin by TBK Duy](https://forums.alliedmods.net/showpost.php?p=2687293&postcount=147)
</details>

- - - -
# 中文說明
倖存者根據自身模組發出對應的角色語音+修復不同模組的倖存者在三方地圖無法出現語音劇情對話

* 原理
    * (Before) 在某些三方圖中，有些重要的事件會檢測倖存者角色，然後觸發語音或劇情對話，但是地圖並沒有預想過不同的倖存者角色
        * 譬如: 地圖預設的倖存者是一代角色，玩家的角色是Bill，可以與救援無線電對話，之後觸發救援
        * 但是當玩家將自己切換成二代角色Nick (如插件CSM)，那麼可能無法與救援無線電對話，進而卡關因為地圖沒有考慮過二代角色的劇情對話
    * (裝此插件之後) 如果地圖有[```func_orator```實體(常見於三方圖)，此實體管理地圖的劇情對話](https://developer.valvesoftware.com/wiki/Func_orator)
        * 當倖存者開口劇情對話時 (SpeakResponseConcept)，此插件會將玩家暫時變回地圖預設的倖存者角色
        * 譬如: 倖存者不停說者"關閉警報"、救援無線電嘗試詢問是否有人活著


