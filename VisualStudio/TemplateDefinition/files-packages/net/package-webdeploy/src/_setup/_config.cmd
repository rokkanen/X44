@echo off
REM ============================================
set solutionVersion=v0.0.0
set projectOne=Company.Template.api
set projectTwo=
set binaryRepository=c:\temp\_webdeploy\%projectOne%\%solutionVersion%\app
REM ============================================
set visualStudio=2019\Enterprise
set visualStudio=2019\Professional
set msBuild="%ProgramFiles(X86)%\Microsoft Visual Studio\%visualStudio%\MSBuild\Current\Bin"\msbuild.exe
set config=release
set deliveryRoot=..\webdeploy
set logfile=build.log

@rem If you have some difficulties to run OtaServiceAdmin.deploy.cmd (Restricted access to Windows registry), unset the comment bellow:
@rem set MSDeployPath="C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\"

