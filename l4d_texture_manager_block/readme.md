# Description | 內容
Kicks out clients who are potentially attempting to enable mathack

* Video | 影片展示
<br/>None

* Image | 圖示
	* Kick player using cheat command (踢出試圖使用作弊指令的玩家)
    <br/>![l4d_texture_manager_block_1](image/l4d_texture_manager_block_1.jpg)
    <br/>![l4d_texture_manager_block_2](image/l4d_texture_manager_block_2.jpg)

* <details><summary>How does it work?</summary>

    * Kick players if they try to modify the following cvars
        ```c
        mat_texture_list // show a list of used textures per frame
        mat_queue_mode // remove vomit
        mat_hdr_level // increased brightness
        mat_postprocess_enable // increased brightness
        r_drawothermodels // draw all wireframe
        l4d_bhop from l4dbhop.dll // bhop, l4d1 only
        l4d_bhop_autostrafe from l4dbhop.dll // bhop, l4d1 only
        cl_fov // change Common FOV too much, l4d1 only
        r_minlightmap // increased brightness
        mat_monitorgamma_tv_exp // increased brightness
        ```
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d_texture_manager_block.cfg
        ```php
        // 1 - kick clients, 0 - record only, in log file(sourcemod/logs/mathack_cheaters.txt), other value: ban minutes
        l4d1_penalty "1"
        ```
</details>

* <details><summary>Command | 命令</summary>
    
    None
</details>

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>Changelog | 版本日誌</summary>

    * v1.7 (2023-5-10)
        * Add more client convars

    * 1.0
        * [From L4D2-Competitive-Framework](https://github.com/Attano/L4D2-Competitive-Framework/blob/master/addons/sourcemod/scripting/l4d_texture_manager_block.sp)

    * 0.2
        * [Original Plugin by extrav3rt](https://forums.alliedmods.net/showthread.php?p=2580578)
</details>

- - - -
# 中文說明
遊戲中頻繁檢測每一位玩家並踢出可能試圖使用作弊指令的客戶

* 原理
    * 幫玩家檢測以下指令，如有發現試圖使用將踢出伺服器
        ```c
        mat_texture_list // show a list of used textures per frame
        mat_queue_mode // remove vomit
        mat_hdr_level // increased brightness
        mat_postprocess_enable // increased brightness
        r_drawothermodels // draw all wireframe
        l4d_bhop from l4dbhop.dll // bhop, l4d1 only
        l4d_bhop_autostrafe from l4dbhop.dll // bhop, l4d1 only
        cl_fov // change Common FOV too much, l4d1 only
        r_minlightmap // increased brightness
        mat_monitorgamma_tv_exp // increased brightness
        ```
    * 如你有發現更多作弊指令想新增檢測，請自行增加或洽本人

* 功能
    * 踢出或封鎖玩家
    * 紀錄文件於```sourcempd\logs\mathack_cheaters.txt```