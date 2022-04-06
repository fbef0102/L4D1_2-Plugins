Download and play one random music on map start/round start
video showcase: https://www.youtube.com/watch?v=4ldZXjHWa5g

-ChangeLog-
v0.8
- say !mp3off to turn off round start music
- say !mp3on to turn on round start music
- list all songs in menu and you can play specific song.
- only one song will be downloaded to client each map or download all at once
- play song to client when joining server.
- player can choose a tracker from music menu(!music), all players can hear it.

v0.4
- original plugin by Dragokas: https://forums.alliedmods.net/showthread.php?p=2644771

-How to play custom music-
1.Preparation of MP3 files
	*file names
	-Ensure noone file has space or special characters like "long dash" (–) or so.

	*sample rate
	-All MP3 files must be encoded in 44100 Hz sample rate, otherwise it may not play at all.
	-To ensure, you can download [MP3 Quality Modifier tool](https://mp3-quality-modifier.en.softonic.com/download) and re-encode all files at once.

	*file size
	-Next, it is recommended every file will not be > 5 MB. in size (to improve download speed).
	-To decrease the size, sort all your files by size, send the files > 5 MB to above tool and re-encode them in 128 (or 192) Kbit/s bitrate (select "constant" mode first).

2.Preparation the list
	-Download all files(addons and sound).
	-Put them in the correct folder ("Left 4 Dead Dedicated Server\left4dead" or "Left 4 Dead 2 Dedicated Server\left4dead2" folder depending on your game).
	-Copy YOUR MP3 files to sound/valentine folder.
	-Add the path of the MP3 to the main config file "addons\sourcemod\data\music_mapstart.txt". The path has to be put relative to the materials folder.
		
3.Setup server to work with downloadable content
	*ConVars in your cfg/server.cfg should be:
	-If you are l4d1
		sm_cvar sv_allowdownload "1"
		sm_cvar sv_downloadurl "http://your-content-server.com/game/left4dead/"
	-If you are l4d2
		sm_cvar sv_allowdownload "1"
		sm_cvar sv_downloadurl "http://your-content-server.com/game/left4dead2"

4.Uploading files to server.
	-Upload "sound" folder to content-server
		*If you are l4d1,your-content-server.com/game/left4dead/sound/valentine/ <= here is your *.mp3 files
		*If you are l4d2,your-content-server.com/game/left4dead2/sound/valentine/ <= here is your *.mp3 files
	-Upload "sound" folder to basic server.
	
5.Start the server and test
	-Join Server and type !music in chatbox.
	
-ConVar-
// Delay (in sec.) playing the music to client after player joins server.
l4d_music_mapstart_delay_joinserver "3.0"

// Delay (in sec.) playing the music on round starts.
l4d_music_mapstart_delay_roundstart "1.0"

// How many random music files to download from 'data/music_mapstart.txt' each map. [0 - all at once]
l4d_music_mapstart_download_number "3"

// Enable plugin. (1 - On / 0 - Off)
l4d_music_mapstart_enable "1"

// Play the music to client after player joins server? (1 - Yes, 0 - No)
l4d_music_mapstart_play_joinserver "1"

// Play the music to everyone on round starts. (1 - Yes, 0 - No)
l4d_music_mapstart_play_roundstart "1"

// Players with these flags have access to play music that everyone can hear. (Empty = Everyone, -1: Nobody)
l4d_music_mapstart_playmusic_access_flag ""

// Time in seconds player can not chooses a track from !music menu again (0=off)
l4d_music_mapstart_playmusic_cooldown "3.0"

// Show !music menu after player joins server? (1 - Yes, 0 - No)
l4d_music_mapstart_showmenu_joinserver "0"

// Show !music menu on round start? (1 - Yes, 0 - No)
l4d_music_mapstart_showmenu_roundstart "1"

-Command-
** Player menu
	sm_music
	
** Update music list from config (Admin-Flag: ADMFLAG_BAN)
	sm_music_update

** Turn off round start music
	sm_mp3off

** Turn on round start music
	sm_mp3on


***中文說明書***
翻譯者: 壹梦

在地图开始/回合开始时下载并播放一首随机音乐
视频展示: https://www.youtube.com/watch?v=4ldZXjHWa5g)

-变更日志-
0.7
- 输入指令 !mp3off 为服务器内的玩家关闭回合音乐
- 输入指令 !mp3on 为服务器内的玩家打开回合音乐
- 菜单中列出所有歌曲并且可以从中点歌
- 可选择一个关卡只下载一个音乐或是下载全部音乐
- 玩家进服播放歌曲

0.4
- 来自 Dragokasm 的原始项目: https://forums.alliedmods.net/showthread.php?p=2644771

-如何播放自定义音乐-
1.MP3文件的准备
	*文件名
	- 确保没有文件有空格或特殊字符，如“长破折号”(–) 等。

	*采样率
	- 所有 MP3 文件必须以 44100 Hz 采样率编码，否则可能根本无法播放。
	- 为了确保，您可以下载 [MP3 质量修改器工具](https://mp3-quality-modifier.en.softonic.com/download) 并一次重新编码所有文件。

	*文件大小
	-接下来，建议每个文件不要> 5 MB。大小（以提高下载速度）。
	-要减小大小，请按大小对所有文件进行排序，将大于 5 MB 的文件发送到上述工具并以 128（或 192）Kbit/s 比特率重新编码（首先选择“恒定”模式）。

2.准备清单
	- 下载所有文件（插件和声音）。
	- 将它们放在正确的文件夹中（“Left 4 Dead Dedicated Server\left4dead”或“Left 4 Dead 2 Dedicated Server\left4dead2”文件夹，具体取决于您的游戏）。
	- 将您的 MP3 文件复制到 sound/valentine 文件夹。
	- 将音乐档案的路径添加到主配置文件"addons\sourcemod\data\music_mapstart.txt"。路径必须相对于sound资料夹，需写上副档名。。

3.设置服务器以处理可下载的内容
	*您的 cfg/server.cfg 中的 ConVars 应该是：
	-如果你是 l4d1
		sm_cvar sv_allowdownload "1"
		sm_cvar sv_downloadurl "http://your-content-server.com/game/left4dead/"
	-如果你是 l4d2
		sm_cvar sv_allowdownload "1"
		sm_cvar sv_downloadurl "http://your-content-server.com/game/left4dead2"

4.上传文件到服务器
	-将"sound"文件夹上传到网空服务器
		*如果你是 l4d1,your-content-server.com/game/left4dead/sound/valentine/ <= 这里是你的 *.mp3 文件
		*如果你是 l4d2，your-content-server.com/game/left4dead2/sound/valentine/ <= 这里是你的 *.mp3 文件
	-将"sound" 文件夹上传到基础服务器。

5.启动服务器并测试
	-加入服务器并在聊天视窗输入!music

-指令-
// 在玩家加入服务器后延迟播放音乐（以秒为单位）
l4d_music_mapstart_delay_joinserver "3.0"

// 在回合开始后延迟播放音乐（以秒为单位）
l4d_music_mapstart_delay_roundstart "1.0"

// 每张地图从 'data/music_mapstart.txt'档案随机下载并显示多少首歌曲. [0 - 全部歌曲]
l4d_music_mapstart_download_number "3"

// 启用插件 (1 - 是，0 - 否)
l4d_music_mapstart_enable "1"

// 玩家加入服务器后播放音乐？ (1 - 是，0 - 否)
l4d_music_mapstart_play_joinserver "1"

// 回合开始后播放音乐 (1 - 是，0 - 否)
l4d_music_mapstart_play_roundstart "1"

// 有这些权限的玩家才能使用点歌系统 (空白 = 每个人都能使用, -1: 禁止任何人)
l4d_music_mapstart_playmusic_access_flag ""

// 点歌之后全体玩家短时间内不能再点歌 (0 - 關閉)
l4d_music_mapstart_playmusic_cooldown "3.0"

// 玩家加入服务器后显示 !music 菜单？(1 - 是，0 - 否)
l4d_music_mapstart_showmenu_joinserver "0"

// 在回合开始时显示 !music 菜单？(1 - 是，0 - 否)
l4d_music_mapstart_showmenu_roundstart "1"

-命令-
** 音乐播放器菜单
	sm_music
	
** 从配置中更新音乐列表 (需要管理员权限: ADMFLAG_BAN)
	sm_music_update

** 关闭回合音乐
	sm_mp3off

** 打开回合音乐
	sm_mp3on
