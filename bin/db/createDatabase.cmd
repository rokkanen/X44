@echo off
@call configDB.cmd %1
md %DB_PATH%

:: List SQLServer instance
SqlLocalDb i

:: Script to Create Local DB Instance and a database
::echo Creates the localDB server instance
::pushd "%localdDbDir%"
:: uncomment those lines if you want to delete existing content
::SqlLocalDb stop %SRV_NAME%
::SqlLocalDb delete %SRV_NAME%
::SqlLocalDb create %SRV_NAME%
SqlLocalDb start %SRV_NAME%
::popd

echo Create the database intance
pushd "%sqlCmdDir%"
sqlcmd -S "(localdb)\%SRV_NAME%" -Q "CREATE DATABASE [%DB_NAME%] ON PRIMARY ( NAME=[%DB_NAME%_data], FILENAME = '%DB_PATH%\%DB_NAME%_data.mdf') LOG ON (NAME=[%DB_NAME%_log], FILENAME = '%DB_PATH%\%DB_NAME%_log.ldf');"
popd
echo completed