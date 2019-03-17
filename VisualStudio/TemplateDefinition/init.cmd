@echo off
REM usage: init AspNetCoreAPI-SimpleProject
powershell -executionpolicy unrestricted -file xslt.ps1 %1.xml CreateDotNetCommand.xsl createnetcore.cmd
createnetcore.cmd %1
pause

