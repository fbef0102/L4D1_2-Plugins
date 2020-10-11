@echo off
SetLocal EnableExtensions

if exist ..\..\addons\sourcemod\data (
  set list=..\..\addons\sourcemod\data\music_mapstart.txt
) else (
  set list=music_mapstart.txt
)

2>nul del "%list%"
for %%a in (*.mp3) do >> "%list%" < NUL set /p "=%p%" & >> "%list%" echo valentine/%%a

echo File list is successfully rewrited and saved to: %list%
echo.
pause

goto :eof