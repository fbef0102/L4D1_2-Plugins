# Description | 內容
Prevents custom maps from softlocking due to a poorly filter_activator_model's logic when playing with different survivor models

* Apply to | 適用於
    ```
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * (Before) In some custom maps, important events often detect survivor's model and trigger some button or event, however maps may not consider different survivor models
        * For example, Bill's model can activate important event on a map with the L4D1 survivor set
        * But if player changes model to Nick (such as CSM), the map would softlock because the entity flow never considered Nick's model.
    * (After) The fix is done by manipulating the entity [```filter_activator_model```'s logic](https://developer.valvesoftware.com/wiki/Filter_activator_model), so it would also fix problems if your server has custom models.
</details>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>Support | 支援插件</summary>

    1. [l4d2_vocalizebasedmodel](/l4d2_vocalizebasedmodel): Survivors will vocalize based on their model + Fixes conversation stucks when playing with l4d1+2 survivor models in custom maps
        * 倖存者根據自身模組發出對應的角色語音+修復不同模組的倖存者在三方地圖無法出現語音劇情對話
</details>

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d2_trigger_flow_fix.cfg
        ```php
        // Enables Survivor Set Trigger Fix
        sm_l4d2_survivorsetfix_enabled "1"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.0h (2026-1-27)
        * Fixed character model
        * Remove code about SpeakResponseConcept (fixing conversation line)

    * Credit
        * [Original Plugin by gabuch2](https://forums.alliedmods.net/showthread.php?t=339155)
</details>

- - - -
# 中文說明
修復不同模組的倖存者在三方地圖啟動地圖上的機關會出現問題

* 原理
    * (裝此插件之前) 在某些三方圖中，有些重要的事件會檢測倖存者的模型，然後觸發機關或是劇情，但是地圖並沒有預想過不同的倖存者模型
        * 譬如: 地圖預設的倖存者是一代角色，玩家的模型是Bill，可以觸發地圖機關
        * 但是當玩家將自己的模型切換成二代角色Nick模型 (如插件CSM)，那麼地圖可能會卡關因為地圖沒有考慮過二代倖存者的模型
    * (裝此插件之後) 此插件嘗試操控[```filter_activator_model```實體的邏輯(常見於三方圖)](https://developer.valvesoftware.com/wiki/Filter_activator_model)，即使玩家使用不同的模型也會通過

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d2_trigger_flow_fix.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        sm_l4d2_survivorsetfix_enabled "1"
        ```
</details>



