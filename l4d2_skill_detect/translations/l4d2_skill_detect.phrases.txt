/*
	支援以下顏色:
	 - {default}	(白色)
	 - {green}		(橘色)
	 - {olive}		(綠色)
	 - {lightgreen}	(淺綠色)
	 - {red}		(紅色) - 特感隊伍要有人或bot在才會顯示紅色，否則顯示橘色
	 - {blue}		(藍色) - 人類隊伍要有人或bot在才會顯示藍色，否則顯示橘色
	 注意事項: 藍色, 紅色, 淺綠色，這三種顏色的其中任意兩種不可出現在同一句話裡
*/

/*
	Following named colors are supported:
	 - {default}	(whilte)
	 - {green}		(olive color)
	 - {olive}		(green color)
	 - {lightgreen}	(light green)
	 - {red}		(red) - There must be at least one player or bot in infected team，or red will turn into {green} color
	 - {blue}		(blue) - There must be at least one player or bot in survivor team，or blue will turn into {green} color 
	 Warning:  2 of (Blue, Red, Lightgreen) colors can not be used together in one sentence
*/

"Phrases"
{
	"HandlePop_1"
	{
		"#format"		"{1:N},{2:N},{3:.1f}"
		"en"		"{lightgreen}★★ {olive}{1}{default} popped {green}{2}{default} ({3} seconds)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 安全地解决了 {green}{2}{default} ({3} 秒)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 安全地解决了 {green}{2}{default} ({3} 秒)."
	}
	"HandlePop_2"
	{
		"#format"		"{1:N},{2:.1f}"
		"en"		"{lightgreen}★★ {olive}{1}{default} popped {green}a boomer{default} ({2} seconds)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 安全地解决了 {green}Boomer{default} ({2} 秒)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 安全地解决了 {green}Boomer{default} ({2} 秒)."
	}
	"HandlePopStop_1"
	{
		"#format"		"{1:N},{2:N},{3:.1f}"
		"en"		"{lightgreen}★ {olive}{1}{default} popstopped {green}{2}{default} ({3} seconds)."
		"zho"		"{lightgreen}★ {olive}{1}{default} 推停了正在嘔吐的 {green}{2}{default} ({3} 秒)."
		"chi"		"{lightgreen}★ {olive}{1}{default} 推停了正在呕吐的 {green}{2}{default} ({3} 秒)."
	}
	"HandlePopStop_2"
	{
		"#format"		"{1:N},{2:.1f}"
		"en"		"{lightgreen}★ {olive}{1}{default} popstopped {green}a boomer{default} ({2} seconds)."
		"zho"		"{lightgreen}★ {olive}{1}{default} 推停了正在嘔吐的 {green}Boomer{default} ({2} 秒)."
		"chi"		"{lightgreen}★ {olive}{1}{default} 推停了正在呕吐的 {green}Boomer{default} ({2} 秒)."
	}
	"HandleLevel_1"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} leveled {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 近戰秒殺了衝鋒的 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 近战秒杀了冲锋的 {green}{2}{default}."
	}
	"HandleLevel_2"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} leveled {green}a charger{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 近戰秒殺了衝鋒的 {green}Charger{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 近战秒杀了冲锋的 {green}Charger{default}."
	}
	"HandleLevel_3"
	{
		"en"		"{lightgreen}★★★ {green}A charger{default} was leveled."
		"zho"		"{lightgreen}★★★ {green}Charger{default} 被 {olive}倖存者{default} 近戰秒殺了."
		"chi"		"{lightgreen}★★★ {green}Charger{default} 被 {olive}生还者{default} 近战秒杀了."
	}
	"HandleLevelHurt_1"
	{
		"#format"		"{1:N},{2:N},{3:i}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} chip-leveled {green}{2}{default} ({lightgreen}{3}{default} low damage)."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 近戰砍死了衝鋒的 {green}{2}{default} ({lightgreen}{3}{default} 低傷害)."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 近战砍死了冲锋的 {green}{2}{default} ({lightgreen}{3}{default} 低伤害)."
	}
	"HandleLevelHurt_2"
	{
		"#format"		"{1:N},{2:i}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} chip-leveled {green}a charger{default} ({lightgreen}{2}{default} low damage)."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 近戰砍死了衝鋒的 {green}Charger{default} ({lightgreen}{2}{default} 低傷害)."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 近战砍死了冲锋的 {green}Charger{default} ({lightgreen}{2}{default} 低伤害)."
	}
	"HandleLevelHurt_3"
	{
		"#format"		"{1:i}"
		"en"		"{lightgreen}★★★ {green}A charger{default} was chip-leveled ({lightgreen}{1}{default} low damage)."
		"zho"		"{lightgreen}★★★ {green}Charger{default} 被 {olive}倖存者{default} 近戰砍死了 ({lightgreen}{1}{default} 低傷害)."
		"chi"		"{lightgreen}★★★ {green}Charger{default} 被 {olive}幸存者{default} 近战砍死了.({lightgreen}{1}{default} 低伤害)."
	}
	"HandleDeadstop_1_H"
	{
		//Is Hunter
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★ {olive}{1}{default} deadstopped {green}{2}{default}."
		"zho"		"{lightgreen}★ {olive}{1}{default} 推停了飛撲的 {green}{2}{default}."
		"chi"		"{lightgreen}★ {olive}{1}{default} 推停了飞扑的 {green}{2}{default}."
	}
	"HandleDeadstop_1_J" 
	{
		//Is Jockey
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★ {olive}{1}{default} deadstopped {green}{2}{default}."
		"zho"		"{lightgreen}★ {olive}{1}{default} 推停了空中的 {green}{2}{default}."
		"chi"		"{lightgreen}★ {olive}{1}{default} 推停了空中的 {green}{2}{default}."
	}
	"HandleDeadstop_2_H"
	{
		 //Is Hunter
		 "#format"		"{1:N}"
		"en"		"{lightgreen}★ {olive}{1}{default} deadstopped {green}a hunter{default}."
		"zho"		"{lightgreen}★ {olive}{1}{default} 推停了飛撲的 {green}Hunter{default}."
		"chi"		"{lightgreen}★ {olive}{1}{default} 推停了飞扑的 {green}Hunter{default}."
	}
	"HandleDeadstop_2_J"
	{
		//Is Jockey
		"#format"		"{1:N}"
		"en"		"{lightgreen}★ {olive}{1}{default} deadstopped {green}a jockey{default}."
		"zho"		"{lightgreen}★ {olive}{1}{default} 推停了空中的 {green}Jockey{default}."
		"chi"		"{lightgreen}★ {olive}{1}{default} 推停了空中的 {green}Jockey{default}."
	}
	"HandleShove_1"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★ {olive}{1}{default} shoved {green}{2}{default}."
		"zho"		"{lightgreen}★ {olive}{1}{default} 推開了 {green}{2}{default}."
		"chi"		"{lightgreen}★ {olive}{1}{default} 推开了 {green}{2}{default}."
	}
	"HandleShove_2"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★ {olive}{1}{default} shoved {green}an SI{default}."
		"zho"		"{lightgreen}★ {olive}{1}{default} 推開了 {green}特感{default}."
		"chi"		"{lightgreen}★ {olive}{1}{default} 推开了 {green}特感{default}."
	}
	"HandleSkeetAssist_1"
	{
		"en"		"{lightgreen}Assist：{default}"
		"zho"		"{lightgreen}助攻：{default}"
		"chi"		"{lightgreen}助攻：{default}"
	}
	"HandleSkeetAssist_2"
	{
		//無法翻譯
		"#format"		"{1:N},{2:d},{3:d}"
		"en"		"{olive}{1}{default} ({green}{2}{default} shots, {green}{3}{default} dmg)"
	}
	"HandleSkeet_1_H"
	{
		//Is Hunter
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★ {green}{1}{default} was team-skeeted by {olive}{2}{default}."
		"zho"		"{lightgreen}★ {green}{1}{default} 被 {olive}{2}{default} 和隊伍合力空爆了."
		"chi"		"{lightgreen}★ {green}{1}{default} 被 {olive}{2}{default} 和队伍合力空爆了."
	}
	"HandleSkeet_1_J"
	{
		//Is Jockey
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★ {green}{1}{default} was team-skeeted by {olive}{2}{default}."
		"zho"		"{lightgreen}★ {green}{1}{default} 被 {olive}{2}{default} 和隊伍合力空爆了."
		"chi"		"{lightgreen}★ {green}{1}{default} 被 {olive}{2}{default} 和队伍合力空爆了."
	}
	"HandleSkeet_2_H"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★ {green}A hunter{default} was team-skeeted by {olive}{1}{default}."
		"zho"		"{lightgreen}★ {green}Hunter{default} 被 {olive}{1}{default} 和隊伍合力空爆了."
		"chi"		"{lightgreen}★ {green}Hunter{default} 被 {olive}{1}{default} 和队伍合力空爆了."
	}
	"HandleSkeet_2_J"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★ {green}Jockey{default} was team-skeeted by {olive}{1}{default}."
		"zho"		"{lightgreen}★ {green}Jockey{default} 被 {olive}{1}{default} 和隊伍合力空爆了."
		"chi"		"{lightgreen}★ {green}Jockey{default} 被 {olive}{1}{default} 和队伍合力空爆了."
	}
	"HandleSkeet_3_H"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★ {green}{1}{default} was team-skeeted."
		"zho"		"{lightgreen}★ {green}{1}{default} 被倖存者合力空爆了."
		"chi"		"{lightgreen}★ {green}{1}{default} 被生还者合力空爆了."
	}
	"HandleSkeet_3_J"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★ {green}{1}{default} was team-skeeted."
		"zho"		"{lightgreen}★ {green}{1}{default} 被倖存者合力空爆了."
		"chi"		"{lightgreen}★ {green}{1}{default} 被生还者合力空爆了."
	}
	"HandleSkeet_4_H"
	{
		"en"		"{lightgreen}★ {green}A hunter{default} was team-skeeted."
		"zho"		"{lightgreen}★ {green}Hunter{default} 被倖存者合力空爆了."
		"chi"		"{lightgreen}★ {green}Hunter{default} 被生还者合力空爆了."
	}
	"HandleSkeet_4_J"
	{
		"en"		"{lightgreen}★ {green}A jockey{default} was team-skeeted."
		"zho"		"{lightgreen}★ {green}Jockey{default} 被倖存者合力空爆了."
		"chi"		"{lightgreen}★ {green}Jockey{default} 被生还者合力空爆了."
	}
	"HandleSkeet_5_H"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} melee-skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 近戰秒殺了飛撲的 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 近战秒杀了飞扑的 {green}{2}{default}."
	}
	"HandleSkeet_5_J"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} melee-skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 近戰秒殺了空中的 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 近战秒杀了空中的 {green}{2}{default}."
	}
	"HandleSkeet_6_H"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} sniper-skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 狙擊空爆了 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 狙击空爆了 {green}{2}{default}."
	}
	"HandleSkeet_6_J"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} sniper-skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 狙擊空爆了 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 狙击空爆了 {green}{2}{default}."
	}
	"HandleSkeet_7_H"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} grenade-skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 榴彈擊中了飛撲的 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 榴弹击中了飞扑的 {green}{2}{default}."
	}
	"HandleSkeet_7_J"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} grenade-skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 榴彈擊中了空中的 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 榴弹击中了空中的 {green}{2}{default}."
	}
	"HandleSkeet_8_H"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} skeeted {green}{2}{default} ({lightgreen}{3}{default} shots)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}{2}{default} ({lightgreen}{3}{default} 次射擊)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}{2}{default} ({lightgreen}{3}{default} 次射击)."
	}	
	"HandleSkeet_8_J"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} skeeted {green}{2}{default} ({lightgreen}{3}{default} shots)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}{2}{default} ({lightgreen}{3}{default} 次射擊)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}{2}{default} ({lightgreen}{3}{default} 次射击)."
	}	
	"HandleSkeet_9_H"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★ {olive}{1}{default} skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}{2}{default}."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}{2}{default}."
	}
	"HandleSkeet_9_J"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★ {olive}{1}{default} skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}{2}{default}."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}{2}{default}."
	}
	"HandleSkeet_10_H"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} melee-skeeted {green}a hunter{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 近戰秒殺了飛撲的 {green}Hunter{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 近战秒杀了飞扑的 {green}Hunter{default}."
	}
	"HandleSkeet_10_J"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} melee-skeeted {green}a jockey{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 近戰秒殺了空中的 {green}Jockey{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 近战秒杀了空中的 {green}Jockey{default}."
	}
	"HandleSkeet_11_H"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} sniper-skeeted {green}a hunter{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 狙擊空爆了 {green}Hunter{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 狙击空爆了 {green}Hunter{default}."
	}
	"HandleSkeet_11_J"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} sniper-skeeted {green}a jockey{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 狙擊空爆了 {green}Jockey{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 狙击空爆了 {green}Jockey{default}."
	}
	"HandleSkeet_12_H"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} grenade-skeeted {green}a hunter{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 榴彈擊中了飛撲的 {green}Hunter{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 榴弹击中了飞扑的 {green}Hunter{default}."
	}
	"HandleSkeet_12_J"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} grenade-skeeted {green}a jockey{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 榴彈擊中了空中的 {green}Jockey{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 榴弹击中了空中的 {green}Jockey{default}."
	}
	"HandleSkeet_13_H"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} skeeted {green}a hunter{default} ({lightgreen}{2}{default} shots)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 次射擊)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 次射击)."
	}	
	"HandleSkeet_13_J"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} skeeted {green}Jockey{default} ({lightgreen}{2}{default} shots)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 次射擊)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 次射击)."
	}	
	"HandleSkeet_14_H"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★ {olive}{1}{default} skeeted {green}a hunter{default}."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}Hunter{default}."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}Hunter{default}."
	}
	"HandleSkeet_14_J"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★ {olive}{1}{default} skeeted {green}a jockey{default}."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}Jockey{default}."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 空爆了 {green}Jockey{default}."
	}
	"HandleSkeet_M_H"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} magnum-skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 麥格農空爆了 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 马格南空爆了 {green}{2}{default}."
	}
	"HandleSkeet_M_J"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} magnum-skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 麥格農空爆了 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 马格南空爆了 {green}{2}{default}."
	}
	"HandleSkeet_S_H"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} shotgun-skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 霰彈空爆了 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 散弹空爆了 {green}{2}{default}."
	}
	"HandleSkeet_S_J"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} shotgun-skeeted {green}{2}{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 霰彈空爆了 {green}{2}{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 散弹空爆了 {green}{2}{default}."
	}
	"HandleSkeet_M_S_H"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} magnum-skeeted {green}a hunter{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 麥格農空爆了 {green}Hunter{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 马格南空爆了 {green}Hunter{default}."
	}
	"HandleSkeet_M_S_J"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} magnum-skeeted {green}a jockey{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 麥格農空爆了 {green}Jockey{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 马格南空爆了 {green}Jockey{default}."
	}
	"HandleSkeet_S_S_H"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} shotgun-skeeted {green}a hunter{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 霰彈空爆了 {green}Hunter{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 散弹空爆了 {green}Hunter{default}."
	}
	"HandleSkeet_S_S_J"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★★ {olive}{1}{default} shotgun-skeeted {green}a jockey{default}."
		"zho"		"{lightgreen}★★★ {olive}{1}{default} 霰彈空爆了 {green}Jockey{default}."
		"chi"		"{lightgreen}★★★ {olive}{1}{default} 散弹空爆了 {green}Jockey{default}."
	}
	"HandleNonSkeet_1_H"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} chip-melee-skeeted {green}{2}{default} ({lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-砍死了飛撲的 {green}{2}{default} ({lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-砍死了飞扑的 {green}{2}{default} ({lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_1_J"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} chip-melee-skeeted {green}{2}{default} ({lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-砍死了空中的 {green}{2}{default} ({lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-砍死了空中的 {green}{2}{default} ({lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_2_H"
	{
		"#format"		"{1:N},{2:N},{3:d},{4:d}"
		"en"		"{lightgreen}★ {olive}{1}{default} chip-skeeted {green}{2}{default} ({lightgreen}{3}{default} shots, {lightgreen}{4}{default} dmg)."
		"zho"		"{lightgreen}★ {olive}{1}{default} 低傷害-空爆了 {green}{2}{default} ({lightgreen}{3}{default} 次射擊, {lightgreen}{4}{default} 傷害)."
		"chi"		"{lightgreen}★ {olive}{1}{default} 低伤害-空爆了 {green}{2}{default} ({lightgreen}{3}{default} 次射击, {lightgreen}{4}{default} 伤害)."
	}
	"HandleNonSkeet_2_J"
	{
		"#format"		"{1:N},{2:N},{3:d},{4:d}"
		"en"		"{lightgreen}★ {olive}{1}{default} chip-skeeted {green}{2}{default} ({lightgreen}{3}{default} shots, {lightgreen}{4}{default} dmg)."
		"zho"		"{lightgreen}★ {olive}{1}{default} 低傷害-空爆了 {green}{2}{default} ({lightgreen}{3}{default} 次射擊, {lightgreen}{4}{default} 傷害)."
		"chi"		"{lightgreen}★ {olive}{1}{default} 低伤害-空爆了 {green}{2}{default} ({lightgreen}{3}{default} 次射击, {lightgreen}{4}{default} 伤害)."
	}
	"HandleNonSkeet_3_H"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★ {olive}{1}{default} chip-skeeted {green}{2}{default} ({lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★ {olive}{1}{default} 低傷害-空爆了 {green}{2}{default} ({lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★ {olive}{1}{default} 低伤害-空爆了 {green}{2}{default} ({lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_3_J"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★ {olive}{1}{default} chip-skeeted {green}{2}{default} ({lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★ {olive}{1}{default} 低傷害-空爆了 {green}{2}{default} ({lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★ {olive}{1}{default} 低伤害-空爆了 {green}{2}{default} ({lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_4_H"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} chip-melee-skeeted {green}a hunter{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-砍死了飛撲的 {green}Hunter{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-砍死了飞扑的 {green}Hunter{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleNonSkeet_4_J"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} chip-melee-skeeted {green}a jockey{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-砍死了空中的 {green}Jockey{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-砍死了空中的 {green}Jockey{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleNonSkeet_5_H"
	{
		"#format"		"{1:N},{2:d},{3:d}"
		"en"		"{lightgreen}★ {olive}{1}{default} chip-skeeted {green}a hunter{default} ({lightgreen}{2}{default} shots, {lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★ {olive}{1}{default} 低傷害-空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 次射擊, {lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★ {olive}{1}{default} 低伤害-空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 次射击, {lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_5_J"
	{
		"#format"		"{1:N},{2:d},{3:d}"
		"en"		"{lightgreen}★ {olive}{1}{default} chip-skeeted {green}a jockey{default} ({lightgreen}{2}{default} shots, {lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★ {olive}{1}{default} 低傷害-空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 次射擊, {lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★ {olive}{1}{default} 低伤害-空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 次射击, {lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_6_H"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★ {olive}{1}{default} chip-skeeted {green}a hunter{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★ {olive}{1}{default} 低傷害-空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★ {olive}{1}{default} 低伤害-空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleNonSkeet_6_J"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★ {olive}{1}{default} chip-skeeted {green}a jockey{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★ {olive}{1}{default} 低傷害-空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★ {olive}{1}{default} 低伤害-空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleNonSkeet_SN_H"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} sniper-chip-skeeted {green}{2}{default} ({lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-狙擊空爆了 {green}{2}{default} ({lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-狙击空爆了 {green}{2}{default} ({lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_SN_J"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} sniper-chip-skeeted {green}{2}{default} ({lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-狙擊空爆了 {green}{2}{default} ({lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-狙击空爆了 {green}{2}{default} ({lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_M_H"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} magnum-chip-skeeted {green}{2}{default} ({lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-麥格農空爆了 {green}{2}{default} ({lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-马格南空爆了 {green}{2}{default} ({lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_M_J"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} magnum-chip-skeeted {green}{2}{default} ({lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-麥格農空爆了 {green}{2}{default} ({lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-马格南空爆了 {green}{2}{default} ({lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_S_H"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} shotgun-chip-skeeted {green}{2}{default} ({lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-霰彈空爆了 {green}{2}{default} ({lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-散弹空爆了 {green}{2}{default} ({lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_S_J"
	{
		"#format"		"{1:N},{2:N},{3:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} shotgun-chip-skeeted {green}{2}{default} ({lightgreen}{3}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-霰彈空爆了 {green}{2}{default} ({lightgreen}{3}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-散弹空爆了 {green}{2}{default} ({lightgreen}{3}{default} 伤害)."
	}
	"HandleNonSkeet_SN_S_H"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} sniper-chip-skeeted {green}a hunter{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-狙擊空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-狙击空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleNonSkeet_SN_S_J"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} sniper-chip-skeeted {green}a jockey{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-狙擊空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-狙击空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleNonSkeet_M_S_H"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} magnum-chip-skeeted {green}a hunter{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-麥格農空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-马格南空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleNonSkeet_M_S_J"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} magnum-chip-skeeted {green}a jockey{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-麥格農空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-马格南空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleNonSkeet_S_S_H"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} shotgun-chip-skeeted {green}a hunter{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-霰彈空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-散弹空爆了 {green}Hunter{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleNonSkeet_S_S_J"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} shotgun-chip-skeeted {green}a jockey{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 低傷害-霰彈空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 低伤害-散弹空爆了 {green}Jockey{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleCrown_1"
	{
		"#format"		"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {olive}{1}{default} crowned {green}a witch{default} ({lightgreen}{2}{default} dmg)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 秒殺了 {green}Witch{default} ({lightgreen}{2}{default} 傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 秒杀了 {green}Witch{default} ({lightgreen}{2}{default} 伤害)."
	}
	"HandleCrown_2"
	{
		"en"		"{lightgreen}★★ {green}A witch{default} was crowned."
		"zho"		"{lightgreen}★★ {green}Witch{default} 被秒殺了."
		"chi"		"{lightgreen}★★ {green}Witch{default} 被秒杀了."
	}
	"HandleDrawCrown_1"
	{
		"#format"		"{1:N},{2:i},{3:i}"
		"en"		"{lightgreen}★★ {olive}{1}{default} draw-crowned {green}a witch{default} ({lightgreen}{2}{default} dmg, {green}{3}{default} chip)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 引秒-爆殺了 {green}Witch{default} ({lightgreen}{2}{default} 最終傷害, {green}{3}{default} 初始傷害)."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 引秒-爆杀了 {green}Witch{default} ({lightgreen}{2}{default} 最终伤害, {green}{3}{default} 初始伤害)."
	}
	"HandleDrawCrown_2"
	{
		"#format"		"{1:i},{2:i}"
		"en"		"{lightgreen}★★ {green}A witch{default} was draw-crowned ({lightgreen}{1}{default} dmg, {green}{2}{default} chip)."
		"zho"		"{lightgreen}★★ {green}Witch{default} 被引秒-爆殺了 ({lightgreen}{1}{default} 最終傷害, {green}{2}{default} 初始傷害)."
		"chi"		"{lightgreen}★★ {green}Witch{default} 被引秒-爆杀了 ({lightgreen}{1}{default} 最终伤害, {green}{2}{default} 初始伤害)."
	}
	"HandleTongueCut_1"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{lightgreen}★★ {olive}{1}{default} cut {green}{2}{default}'s tongue."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 近戰砍斷了 {green}{2}{default} 的舌頭."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 近战砍断了 {green}{2}{default} 的舌头."
	}
	"HandleTongueCut_2"
	{
		"#format"		"{1:N}"
		"en"		"{lightgreen}★★ {olive}{1}{default} cut {green}smoker{default} tongue."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 近戰砍斷了 {green}Smoker{default} 的舌頭."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 近战砍断了 {green}Smoker{default} 的舌头."
	}
	"HandleSmokerSelfClear_1_S"
	{
		"#format"		"{1:s},{2:s}"
		"en"		"{lightgreen}★★ {olive}{1}{default} self-cleared from {green}{2}{default}'s tongue by shoving."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 推開自解了 {green}{2}{default} 的舌頭."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 推开自解了 {green}{2}{default} 的舌头."
	}
	"HandleSmokerSelfClear_1_O"
	{
		"#format"		"{1:s},{2:s}"
		"en"		"{lightgreen}★★ {olive}{1}{default} self-cleared from {green}{2}{default}'s tongue."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 自解了 {green}{2}{default} 的舌頭."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 自解了 {green}{2}{default} 的舌头."
	}
	"HandleSmokerSelfClear_2_S"
	{
		"#format"		"{1:s}"
		"en"		"{lightgreen}★★ {olive}{1}{default} self-cleared from {green}a smoker{default} tongue by shoving."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 推開自解了 {green}Smoker{default} 的舌頭."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 推开自解了 {green}Smoker{default} 的舌头."
	}
	"HandleSmokerSelfClear_2_O"
	{
		"#format"		"{1:s}"
		"en"		"{lightgreen}★★ {olive}{1}{default} self-cleared from {green}a smoker{default} tongue."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 自解了 {green}Smoker{default} 的舌頭."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 自解了 {green}Smoker{default} 的舌头."
	}
	"Tank_Rock"
	{
		"en"		"rock"
		"zho"		"石頭"
		"chi"		"石头"
	}
	"Tree"
	{
		"en"		"tree trunk"
		"zho"		"樹樁"
		"chi"		"树桩"
	}
	"Throwable"
	{
		"en"		"throwable object"
		"zho"		"投擲物"
		"chi"		"投掷物"
	}
	"HandleRockSkeeted_1"
	{
		"#format"		"{1:N},{2:N},{3:t}"
		"en"		"{lightgreen}★★ {olive}{1}{default} melee-skeeted {green}{2}{default}'s {3}."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 近戰砍碎了 {green}{2}{default} 的{3}."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 近战砍碎了 {green}{2}{default} 的{3}."
	}
	"HandleRockSkeeted_2"
	{
		"#format"		"{1:N},{2:N},{3:t}"
		"en"		"{lightgreen}★ {olive}{1}{default} skeeted {green}{2}{default}'s {3}."
		"zho"		"{lightgreen}★ {olive}{1}{default} 打碎了 {green}{2}{default} 的{3}."
		"chi"		"{lightgreen}★ {olive}{1}{default} 打碎了 {green}{2}{default} 的{3}."
	}
	"HandleRockSkeeted_3"
	{
		"#format"		"{1:N},{2:t}"
		"en"		"{lightgreen}★★ {olive}{1}{default} melee-skeeted {green}a tank{default} {2}."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 近戰砍碎了 {green}Tank{default} 的{2}."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 近战砍碎了 {green}Tank{default} 的{2}."
	}
	"HandleRockSkeeted_4"
	{
		"#format"		"{1:N},{2:t}"
		"en"		"{lightgreen}★ {olive}{1}{default} skeeted {green}a tank{default} {2}."
		"zho"		"{lightgreen}★ {olive}{1}{default} 打碎了 {green}Tank{default} 的{2}."
		"chi"		"{lightgreen}★ {olive}{1}{default} 打碎了 {green}Tank{default} 的{2}."
	}
	"HandleHunterDP_1"
	{
		"#format"		"{1:N},{2:N},{3:i},{4:i}"
		"en"		"{lightgreen}★★ {green}{1}{1}{default} high-pounced {olive}{2}{default} ({lightgreen}{3}{default} dmg, height: {green}{4}{default})."
		"zho"		"{lightgreen}★★ {green}{1}{default} 高撲砸到 {olive}{2}{default} ({lightgreen}{3}{default} 傷害, 高度 {green}{4}{default})."
		"chi"		"{lightgreen}★★ {green}{1}{default} 高扑砸到 {olive}{2}{default} ({lightgreen}{3}{default} 伤害, 高度 {green}{4}{default})."
	}
	"HandleHunterDP_2"
	{
		"#format"		"{1:N},{2:i},{3:i}"
		"en"		"{lightgreen}★★ {green}A hunter{default} high-pounced {olive}{1}{default} ({lightgreen}{2}{default} dmg, height: {green}{3}{default})."
		"zho"		"{lightgreen}★★ {green}Hunter{default} 高撲砸到 {olive}{1}{default} ({lightgreen}{2}{default} 傷害, 高度 {green}{3}{default})."
		"chi"		"{lightgreen}★★ {green}Hunter{default} 高扑砸到 {olive}{1}{default} ({lightgreen}{2}{default} 伤害, 高度 {green}{3}{default})."
	}
	"HandleJockeyDP_1"
	{
		"#format"		"{1:N},{2:N},{3:i}"
		"en"		"{lightgreen}★★ {green}{1}{default} jockey high-pounced {olive}{2}{default} (height: {green}{3}{default})."
		"zho"		"{lightgreen}★★ {green}{1}{default} 高空騎到 {olive}{2}{default} 的臉上 (高度 {green}{3}{default})."
		"chi"		"{lightgreen}★★ {green}{1}{default} 高空骑到 {olive}{2}{default} 的脸上 (高度 {green}{3}{default})."
	}
	"HandleJockeyDP_2"
	{
		"#format"		"{1:N},{2:i}"
		"en"		"{lightgreen}★★ {green}A Jockey{default} high-pounced {olive}{1}{default} (height: {green}{2}{default})."
		"zho"		"{lightgreen}★★ {green}Jockey{default} 高空騎到 {olive}{1}{default} 的臉上 (高度 {green}{2}{default})."
		"chi"		"{lightgreen}★★ {green}Jockey{default} 高空骑到 {olive}{1}{default} 的脸上 (高度 {green}{2}{default})."
	}
	"HandleDeathCharge_1"
	{
		"#format"		"{1:N},{2:N},{3:i}"
		"en"		"{lightgreen}★★★★ {green}{1}{default} death-charged {olive}{2}{default} (height: {green}{3}{default})."
		"zho"		"{lightgreen}★★★★ {green}{1}{default} 衝鋒帶走了 {olive}{2}{default} (高度 {green}{3}{default})."
		"chi"		"{lightgreen}★★★★ {green}{1}{default} 冲锋带走了 {olive}{2}{default} (高度 {green}{3}{default})."
	}
	"HandleDeathCharge_2"
	{
		"#format"		"{1:N},{2:N},{3:i}"
		"en"		"{lightgreen}★★★★ {green}{1}{default} death-charged {olive}{2}{default} by bowling (height: {green}{3}{default})."
		"zho"		"{lightgreen}★★★★ {green}{1}{default} 衝鋒撞飛了 {olive}{2}{default} (高度 {green}{3}{default})."
		"chi"		"{lightgreen}★★★★ {green}{1}{default} 冲锋撞飞了 {olive}{2}{default} (高度 {green}{3}{default})."
	}
	"HandleDeathCharge_3"
	{
		"#format"		"{1:N},{2:i}"
		"en"		"{lightgreen}★★★★ {green}A charger{default} death-charged {olive}{1}{default} (height: {green}{2}{default})."
		"zho"		"{lightgreen}★★★★ {green}Charger{default} 衝鋒帶走了 {olive}{1}{default} (高度 {green}{2}{default})."
		"chi"		"{lightgreen}★★★★ {green}Charger{default} 冲锋带走了 {olive}{1}{default} (高度 {green}{2}{default})."
	}
	"HandleDeathCharge_4"
	{
		"#format"		"{1:N},{2:i}"
		"en"		"{lightgreen}★★★★ {green}A charger{default} death-charged {olive}{1}{default} by bowling (height: {green}{2}{default})."
		"zho"		"{lightgreen}★★★★ {green}Charger{default} 衝鋒撞飛了 {olive}{1}{default} (高度 {green}{2}{default})."
		"chi"		"{lightgreen}★★★★ {green}Charger{default} 冲锋撞飞了 {olive}{1}{default} (高度 {green}{2}{default})."
	}
	"HandleClear_1"
	{
		"#format"		"{1:s},{2:.2f},{3:s},{4:s},{5:s}"
		"en"		"{lightgreen}★★ {olive}{1}{default} insta-cleared {olive}{5}{default} from {green}{3}{default} ({4}) ({2} seconds)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 在 {green}{2}{default} 秒內從 {green}{3}{default} ({4}) 手裡救出 {olive}{5}{default}."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 在 {green}{2}{default} 秒内从 {green}{3}{default} ({4}) 手里救出 {olive}{5}{default}."
	}
	"HandleClear_2"
	{
		"#format"		"{1:s},{2:.2f},{3:s},{4:s}"
		"en"		"{lightgreen}★★ {olive}{1}{default} insta-cleared {olive}a teammate{default} from {green}{3}{default} ({4}) ({green}{2}{default} seconds)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 在 {green}{2}{default} 秒內從 {green}{3}{default} ({4}) 手裡救出 {olive}隊友{default}."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 在 {green}{2}{default} 秒内从 {green}{3}{default} ({4}) 手里救出 {olive}队友{default}."
	}
	"HandleClear_3"
	{
		"#format"		"{1:s},{2:.2f},{3:s},{4:s}"
		"en"		"{lightgreen}★★ {olive}{1}{default} insta-cleared {olive}{4}{default} from {green}a {3}{default} ({green}{2}{default} seconds)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 在 {green}{2}{default} 秒內從特感 {olive}{3}{default} 手裡救出 {olive}{4}{default}."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 在 {green}{2}{default} 秒内从特感 {olive}{3}{default} 手里救出 {olive}{4}{default}."
	}
	"HandleClear_4"
	{
		"#format"		"{1:s},{2:.2f},{3:s}"
		"en"		"{lightgreen}★★ {olive}{1}{default} insta-cleared {olive}a teammate{default} from {green}a {3}{default} ({green}{2}{default} seconds)."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 在 {green}{2}{default} 秒內從特感 {olive}{3}{default} 手裡救出 {olive}隊友{default}."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 在 {green}{2}{default} 秒内从特感 {olive}{3}{default} 手里救出 {olive}队友{default}."
	}
	"HandleBHopStreak_1"
	{
		"#format"		"{1:s},{2:d},{3:.1f},{4:s}"
		"en"		"{lightgreen}★★ {olive}{1}{default} got {green}{2}{default} bunnyhop{4} in a row (top speed: {green}{3}{default})."
		"zho"		"{lightgreen}★★ {olive}{1}{default} 連跳 {green}{2}{default} 次 (最高速度 {green}{3}{default})."
		"chi"		"{lightgreen}★★ {olive}{1}{default} 连跳 {green}{2}{default} 次 (最高速度 {green}{3}{default})."
	}
	"HandleCarAlarmTriggered_1"
	{
		"#format"		"{1:N}"
		"en"		"{olive}{1}{default} triggered an alarm with a hit."
		"zho"		"{olive}{1}{default} 打到了警報車."
		"chi"		"{olive}{1}{default} 打到了警报车."
	}
	"HandleCarAlarmTriggered_2"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{green}{1}{default} made {olive}{2}{default} trigger an alarm."
		"zho"		"{green}{1}{default} 攜帶 {olive}{2}{default} 觸碰了警報車."
		"chi"		"{green}{1}{default} 携带 {olive}{2}{default} 触碰了警报车."
	}
	"HandleCarAlarmTriggered_3"
	{
		"#format"		"{1:N}"
		"en"		"{olive}{1}{default} triggered an alarm with {green}a smoker{default}."
		"zho"		"{olive}{1}{default} 因為被 {green}Smoker{default} 拉走而觸碰了警報車."
		"chi"		"{olive}{1}{default} 因为被 {green}Smoker{default} 拉走而触碰了警报车."
	}
	"HandleCarAlarmTriggered_4"
	{
		"#format"		"{1:N}"
		"en"		"{olive}{1}{default} triggered an alarm with {green}a jockey{default}."
		"zho"		"{olive}{1}{default} 因為被 {green}Jockey{default} 騎而觸碰了警報車."
		"chi"		"{olive}{1}{default} 因为被 {green}Jockey{default} 骑而触碰了警报车."
	}
	"HandleCarAlarmTriggered_5"
	{
		"#format"		"{1:N}"
		"en"		"{olive}{1}{default} triggered an alarm with {green}a charger{default}."
		"zho"		"{olive}{1}{default} 因為被 {green}Charger{default} 撞而觸碰了警報車."
		"chi"		"{olive}{1}{default} 因为被 {green}Charger{default} 撞而触碰了警报车."
	}
	"HandleCarAlarmTriggered_6"
	{
		"#format"		"{1:N}"
		"en"		"{olive}{1}{default} triggered an alarm with {green}an SI{default}."
		"zho"		"{olive}{1}{default} 因為被 {green}AI特感{default} 抓住而觸碰了警報車."
		"chi"		"{olive}{1}{default} 因为被 {green}AI特感{default} 抓住而触碰了警报车."
	}
	"HandleCarAlarmTriggered_7"
	{
		"#format"		"{1:N}"
		"en"		"{olive}{1}{default} touched an alarmed car."
		"zho"		"{olive}{1}{default} 觸碰了警報車."
		"chi"		"{olive}{1}{default} 触碰了警报车."
	}
	"HandleCarAlarmTriggered_8"
	{
		"#format"		"{1:N}"
		"en"		"{olive}{1}{default} triggered an alarm with an explosion."
		"zho"		"{olive}{1}{default} 製造爆炸觸發了警報車."
		"chi"		"{olive}{1}{default} 制造爆炸触发了警报车."
	}
	"HandleCarAlarmTriggered_9"
	{
		"#format"		"{1:N},{2:N}"
		"en"		"{olive}{1}{default} triggered an alarm by killing a boomer {green}{2}{default}."
		"zho"		"{olive}{1}{default} 因為打死 {green}{2}{default} (Boomer) 而觸發警報車."
		"chi"		"{olive}{1}{default} 因为打死 {green}{2}{default} (Boomer) 而触发警报车."
	}
	"HandleCarAlarmTriggered_10"
	{
		"#format"		"{1:N}"
		"en"		"{olive}{1}{default} triggered an alarm by killing {green}a boomer{default}."
		"zho"		"{olive}{1}{default} 因為打死 {green}Boomer{default} 而觸發警報車."
		"chi"		"{olive}{1}{default} 因为打死 {green}Boomer{default} 而触发警报车."
	}
	"HandleCarAlarmTriggered_11"
	{
		"#format"		"{1:N}"
		"en"		"{olive}{1}{default} triggered an alarm."
		"zho"		"{olive}{1}{default} 觸發了警報車."
		"chi"		"{olive}{1}{default} 触发了警报车."
	}
	"HandleVomitLanded_1"
	{
		"#format"	"{1:N},{2:d}"
		"en"		"{lightgreen}★★ {green}{1}{default} vomit all {olive}{2}{default} survivors"
		"zho"		"{lightgreen}★★ {green}{1}{default} 嘔吐到 {olive}{2}{default} 位倖存者."
		"chi"		"{lightgreen}★★ {green}{1}{default} 呕吐到 {olive}{2}{default} 位生还者."
	}
}