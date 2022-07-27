@echo off
SetLocal EnableExtensions enabledelayedexpansion

if exist ..\..\..\addons\sourcemod\configs\map-decals (
  set list=..\..\..\addons\sourcemod\configs\map-decals\decals.cfg
) else (
  set list=decals.cfg
)	

2>nul del "%list%"

echo "Decals">> "%list%"
echo {>> "%list%"

set tab=	
set /a count=1
for %%f in (*.vtf) do (
	if !count! == 1 (
		echo %tab%"%%~nf" //Name whatever you want>> "%list%"
		echo %tab%{>> "%list%"
		echo %tab%%tab%"path"%tab%"decals/TS_SERVER/%%~nf" //decal file path>> "%list%"
		echo %tab%}>> "%list%"
		set /a count=%count%+1
	) else (
		echo %tab%"%%~nf">>"%list%"
		echo %tab%{>> "%list%"
		echo %tab%%tab%"path"%tab%"decals/TS_SERVER/%%~nf">> "%list%"
		echo %tab%}>> "%list%"
	)
)
echo }>> "%list%"

echo File list is successfully rewrited and saved to: %list%
echo.
pause