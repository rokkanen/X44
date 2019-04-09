@echo off
REM ============================================
REM FileName:		cleansln.cmd
REM Description:	Clean binaries directories : bin,obj,packages
REM Author:			Stephane ROKKANEN
REM Created:		July,16 2013
REM Version:		1.0.2
REM ============================================
set project=Company.Template
for /D %%I in (".\%project%*") do rmdir %%I\bin /s/q
for /D %%I in (".\%project%*") do rmdir %%I\obj /s/q
for /D %%I in (".\%project%*") do attrib -H %%I\StyleCop.Cache
for /D %%I in (".\%project%*") do del %%I\StyleCop.Cache

rmdir packages /s/q
rmdir TestResults /s/q
rmdir webdeploy /s/q
rmdir .vs /s/q

attrib -H StyleCop.Cache
del StyleCop.Cache
del *.log
cd _setup
del *.log
cd ..
