@echo off
@call _config.cmd
set server=%1
set parameters=%2
@call deployProject.cmd %server% %parameters% %projectOne%
REM @call deployProject.cmd %server% %parameters% %projectTwo%
pause

