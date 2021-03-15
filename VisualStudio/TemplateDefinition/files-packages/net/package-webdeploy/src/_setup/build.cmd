@echo off
REM ============================================
REM FileName:    build.cmd
REM Description: Create WebDeploy package - Entry point
REM Author:      Stephane ROKKANEN
REM Created:     July 02,2014
REM Updated:     March 05,2021 
REM Version:	 2.0.0
REM ============================================
@call _config.cmd
echo Started at %date% %time% > %logfile%
rem nuget restore

REM ============================================
REM add or remove project here:
REM --------------------------
@call buildpackage01-msbuild.cmd %projectOne%
if not %ERRORLEVEL%==0  goto errorBuild
REM @call buildpackage01-msbuild.cmd %projectTwo%
REM if not %ERRORLEVEL%==0  goto error
REM ============================================

@call buildpackage02-copy.cmd
if not %ERRORLEVEL%==0  goto errorCopy

echo --------------------------------------------------------------
echo * Setup package is created in : %directoryDelivery% directory 
echo * For interactive setup, run _setup.hta
echo --------------------------------------------------------------
echo BUILD Process Done.
echo -------------------
pause
start %deliveryRoot%
exit /B 0

:errorBuild
echo ERROR: BUILD Process failed. >> %logfile%
echo ########################################
echo ERROR: BUILD Process failed. See %logfile%
echo ########################################
pause
exit /B 1

:errorCopy
echo ########################################
echo ERROR: Copy files failed. See %logfile%
echo ########################################
pause
exit /B 1

