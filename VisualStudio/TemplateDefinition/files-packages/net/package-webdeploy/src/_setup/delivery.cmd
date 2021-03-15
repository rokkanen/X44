@echo off
REM ============================================
REM FileName:    delivery.cmd
REM Description: Copy WebDeploy packages localy to binary repository share
REM Author:      Stephane ROKKANEN
REM Created:     March 05,2021
REM Version:     1.0.0
REM ============================================

@call _config.cmd

md %binaryRepository%
copy /Y %deliveryRoot% %binaryRepository% >> %logfile% 2>&1
start %binaryRepository%

