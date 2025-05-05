# Description | 內容
Announces hunter pounces to the entire server, and save record to data/pounce_database.tx

> __Note__ <br/>
This Plugin has been discontinued, Use 
<br/>[l4d_pounce_database_remake](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_%E6%8F%92%E4%BB%B6/Hunter_Hunter/l4d_pounce_database_remake), supports mysql database

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* Image | 圖示
	* Hunter High Pounce notify and Top 5 pouncers (高撲提示與前五名)
    <br/>![pounce_database_1](image/pounce_database_1.jpg)

* <details><summary>How does it work?</summary>

	* When hunter player does 25 high pounce damage, announces to the entire server
	* And save record to [data/pounce_database.txt](data/pounce_database.txt)
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* Archived (2025-1-10)
		* This Plugin has been discontinued

	* v1.3 (2023-6-12)
		* Fix out of memory error

	* v1.2
        * Initial Release
</details>

- - - -
# 中文說明
統計高撲的數量與顯示前五名高撲的大佬 (支援文件儲存)

> __Note__ <br/>
此插件已停止更新，請使用
<br/>[l4d_pounce_database_remake](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_%E6%8F%92%E4%BB%B6/Hunter_Hunter/l4d_pounce_database_remake)

* 原理
	* 當玩家被高撲顯示提示與前五名排名
	* 高撲Bot不會生效
	* 倖存者隊伍有四位以上的真人玩家才會生效
	* 高撲的數量與統計會寫入[data/pounce_database.txt](data/pounce_database.txt)，因此就算重開服也不會重置統計