@echo off
@call configDB.cmd %1

SqlLocalDb start %SRV_NAME%

echo Drop the database intance
pushd "%sqlCmdDir%"
sqlcmd -S "(localdb)\%SRV_NAME%" -Q "DROP DATABASE [%DB_NAME%]"
popd
echo completed