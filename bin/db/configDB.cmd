@echo off
SET SRV_NAME=MSSQLLocalDB
SET DB_NAME=%1
SET DB_PATH=C:\Database

::echo setting variables - Default Server is v11 but it may be useful to evolve in a server instance of your own...
SET localdDbDir=C:\Program Files\Microsoft SQL Server\110\Tools\Binn
SET sqlCmdDir=C:\Program Files\Microsoft SQL Server\110\Tools\Binn

