REM ============================================
REM FileName:	 buildpackage01-msbuild.cmd
REM Description: Create WebDeploy package - MsBuild process
REM Authors:	 Stephane ROKKANEN
REM Created:	 December 14,2015
REM Updated:     March 05,2021
REM Version:	 2.0.0
REM ============================================
set projectName=%1
set deliveryRepository=..\webdeploy\%projectName%
REM ============================================
set projectBuild=..\%projectName%\%projectName%.csproj
set configDirectory=..\%projectName%\_config
set webdeployDirectory=%deliveryRoot%
set optionsBuildPackage=/p:PublishProfile="WebDeployProfile" /p:DeployOnBuild=true /p:DesktopBuildPackageLocation=%webdeployDirectory%
REM ============================================
echo --------------------------------------------------------------
echo Packaging %projectName%, wait a moment please...
echo --------------------------------------------------------------
echo *************************** >> %logfile%
echo Build %project% >> %logfile%
echo %date% %time% >> %logfile%
echo *************************** >> %logfile%

echo 1/3 - Cleaning ************************************************************************************************** >> %logfile%
%msBuild%  %projectBuild% /t:clean >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error
echo ***********>> %logfile%
echo STEP 1 - OK>> %logfile%
echo ***********>> %logfile%

echo 2/3 - Building ************************************************************************************************** >> %logfile%
%msBuild%  %projectBuild% /t:Build /p:Configuration=%config% >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error
echo ***********>> %logfile%
echo STEP 2 - OK>> %logfile%
echo ***********>> %logfile%

echo 3/3 - Packaging ************************************************************************************************* >> %logfile%
echo %msBuild% %projectBuild% %optionsBuildPackage% >> %logfile% 2>&1 >> %logfile% 2>&1
%msBuild% %projectBuild% %optionsBuildPackage% >> %logfile% 2>&1
if not %ERRORLEVEL%==0  goto error
echo ***********>> %logfile%
echo STEP 3 - OK>> %logfile%
echo ***********>> %logfile%

echo **************************************** >> %logfile%
echo BUILD %projectName% OK. >> %logfile%
echo **************************************** >> %logfile%
echo BUILD %projectName% OK.
exit /B 0

:error
echo ######################################## >> %logfile%
echo BUILD %projectName% ERROR >> %logfile%
echo ######################################## >> %logfile%
echo ########################################
echo BUILD %projectName% ERROR: See %logfile%
echo ########################################
exit /B 1
