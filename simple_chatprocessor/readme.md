# Description | 內容
Process chat and allows other plugins to manipulate chat.

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* <details><summary>How does it work?</summary>

	* Provides global forward for chat messages allowing other plugins to manipulate the display of chat messages such as
		* Change chat colors
		* Change player name
		* Change message
		* Change targets who can see the message
	* You don't have to install this plugin unless other plugins require this
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/simple_chatprocessor.cfg
		```php
		// If 1, Display Survivor *DEAD* in chatbox
		simple_chatprocessor_survivor_dead "1"

		// If 1, Display Infected *DEAD* in chatbox
		simple_chatprocessor_infected_dead "0"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* <details><summary>API | 串接</summary>

	```php
	Registers a library name: simple_chatprocessor
	```
	* ```scripting\include\simple_chatprocessor.inc```
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Related Plugin | 相關插件</summary>

	1. [sm_regexfilter](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Anti_Griefer_%E9%98%B2%E6%83%A1%E6%84%8F%E8%B7%AF%E4%BA%BA/sm_regexfilter): Filter dirty words via Regular Expressions
		* 禁詞表，任何人打字說出髒話或敏感詞彙，字詞會被屏蔽、玩家禁言並處死，網路並非法外之地
	2. [l4d_mute_player_list](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Anti_Griefer_%E9%98%B2%E6%83%A1%E6%84%8F%E8%B7%AF%E4%BA%BA/l4d_mute_player_list): Player can personally mute someone chat text and mic voice.
		* 玩家可以在個人列表上封鎖其他人的語音與聊天文字
	3. [simple-chatcolors](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Fun_%E5%A8%9B%E6%A8%82/simple-chatcolors): Changes the colors of players chat based on config file.
		* 根據管理員或玩家身分修改聊天窗口的對話顏色
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.8h (2024-8-3)
		* Update API
        * Add API OnChatMessage2_Post()
		* Change plugin name

	* v1.7h (2024-7-26)
		* Update API

	* v1.6h (2023-12-10)
		* Add Cvars to turn on/off *DEAD*(Infected), *DEAD*(Survivor) message

	* v1.5h (2023-11-19)
		* Fixed Crash "Unable to execute a new message, there is already one in progress"

	* v1.4h (2023-10-31)
		* Add *Dead* Player status when chat

	* v1.3h (2023-7-5)
		* Fixed Crash

	* v1.2h (2023-6-16)
		* Fixed error "Exception reported: Unable to end message, no message is in progress"

	* v1.1h (2023-6-15)
		* L4D1/2 Only
		* Add chinese translation 

	* v1.0h (2023-3-12)
		* Delete API OnChatMessage(int &author, ArrayList recipients, char[] name, char[] message)
        * Add API OnChatMessage2()
        * Fixed translation file error in l4d1/l4d2

	* v2.3.0
		* [JoinedSenses's fork](https://github.com/JoinedSenses/SM-Custom-ChatColors-Menu)

	* 2.0.2
		* [Original Plugin by minimoney1](https://forums.alliedmods.net/showthread.php?t=198501)
</details>

- - - -
# 中文說明
輔助插件，控制玩家在聊天窗口輸入的文字與顏色

* 原理
	* 這插件只是一個輔助插件，能夠讓其他的插件攔截玩家在聊天窗口輸入的文字，譬如
		* 改變聊天玩家的名子
		* 改變訊息文字
		* 改變文字顏色
		* 改變接收到聊天的對象
	* 等其他插件需要的時候再安裝

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/simple_chatprocessor.cfg
		```php
		// 為1時，死亡的倖存者玩家說話時顯示*DEAD*
		simple_chatprocessor_survivor_dead "1"

		// 為1時，死亡的特感玩家說話時顯示*DEAD*
		simple_chatprocessor_infected_dead "0"
		```
</details>

