REM ============================================
REM FileName:	 buildpackage02-copy.cmd
REM Description: Create WebDeploy packages - copy configuraton and addition deployment utilities
REM Authors:	 Stephane ROKKANEN
REM Created:	 December 14,2015
REM Updated:     March 05,2021
REM Version:	 2.0.0
REM ============================================

copy /Y %configDirectory%\SetParameters-*.xml %deliveryRoot% >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error

copy /Y environments.xml %deliveryRoot% >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error

copy /Y _config.cmd %deliveryRoot% >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error

copy /Y _setup.hta %deliveryRoot% >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error

copy /Y deploy.webdeploy %deliveryRoot% >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error

copy /Y deployProject.webdeploy %deliveryRoot% >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error

move /Y %deliveryRoot%\deploy.webdeploy %deliveryRoot%\deploy.cmd >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error

move /Y %deliveryRoot%\deployProject.webdeploy %deliveryRoot%\deployProject.cmd >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error

echo **************************************** >> %logfile%
echo Copy OK. >> %logfile%
echo **************************************** >> %logfile%
exit /B 0

:error
echo ########################################
echo ERROR: Copy failed See %logfile%
echo ########################################
exit /B 1
