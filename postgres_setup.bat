@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

echo PostgreSQL Setup Script Starting...
pause

REM --- PATH ---
set "PG_BIN=C:\Program Files\PostgreSQL\17\bin"
set "PATH=%PG_BIN%;%PATH%"

REM --- SVN credentials ---
set "SVN_USER=remoteuser"
set "SVN_PASS=InforAdm1n"

REM --- SVN URLs ---
set "SVN_BASE=http://usalvwscebld1.infor.com/svn/sce/installer/branches/CSWMS_2025.07.NK.BDEV_MTSCE-1823/src/sce-db-installer/src/components"
set "SVN_TXT=http://usalvwscebld1.infor.com/svn/sce/installer/branches/CSWMS_2025.07.NK.BDEV_MTSCE-1823/src/sce-db-installer/src/ant/POSTGRES-scripts.txt"

REM --- Input ---
set /p Inst_Dir=Install folder (e.g., C:\Infor\sce): 
if "%Inst_Dir%"=="" set "Inst_Dir=C:\Infor\sce"
set /p PGHOST=Database Hostname [localhost]: 
if "%PGHOST%"=="" set "PGHOST=localhost"

:askdb
set /p PGDATABASE=Instance Name (lowercase): 
if "%PGDATABASE%"=="" (
    echo [ERROR] Database name cannot be empty.
    goto askdb
)

:askwh
set /p No_Wh=Number of Warehouses (1-5): 
if "%No_Wh%"=="" set "No_Wh=1"
if %No_Wh% GTR 5 (
    echo [ERROR] Number of Warehouses cannot be more than 5.
    goto askwh
)

set /p PGPORT=Database Port [5432]: 
if "%PGPORT%"=="" set "PGPORT=5432"
set /p PGUSER=PostgreSQL Super User [postgres]: 
if "%PGUSER%"=="" set "PGUSER=postgres"
set /p PGPASSWORD=PostgreSQL Super User Password: 

REM --- Directories ---
set "BASE_DIR=%Inst_Dir%\%PGDATABASE%"
set "LOCAL_DIR=%BASE_DIR%"
set "DEFAULT_DATA_DIR=%BASE_DIR%\database\data"
set "DEFAULT_LOG_DIR=%BASE_DIR%\database\log"

REM --- Ensure base directory exists ---
if not exist "%LOCAL_DIR%" (
    mkdir "%LOCAL_DIR%"
    echo Created base install folder: %LOCAL_DIR%
)

echo.
set /p DATA_DIR=Postgres Data Files Location (e.g., %DEFAULT_DATA_DIR%): 
if "%DATA_DIR%"=="" set "DATA_DIR=%DEFAULT_DATA_DIR%"
echo.
set /p LOG_DIR=Postgres Log Files Location (e.g., %DEFAULT_LOG_DIR%): 
if "%LOG_DIR%"=="" set "LOG_DIR=%DEFAULT_LOG_DIR%"
echo.

if not exist "%DATA_DIR%" mkdir "%DATA_DIR%" >nul 2>&1
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1

for /f "tokens=1-4 delims=/: " %%a in ("%date% %time%") do set "TS=%%c-%%a-%%b_%%d"
set "LOGFILE=%LOG_DIR%\setup_%TS%.log"

if not exist "%LOG_DIR%" (
    echo [ERROR] Could not create log directory: %LOG_DIR%
    pause
    goto end
)

echo --- PostgreSQL Setup Log --- > "%LOGFILE%" 2>nul
echo Start: %date% %time% >> "%LOGFILE%"

echo Downloading POSTGRES-scripts.txt...
svn export --force --username %SVN_USER% --password %SVN_PASS% "%SVN_TXT%" "%LOCAL_DIR%\POSTGRES-scripts.txt"

if not exist "%LOCAL_DIR%\POSTGRES-scripts.txt" (
    echo [ERROR] POSTGRES-scripts.txt not found after download. >> "%LOGFILE%"
    echo [ERROR] POSTGRES-scripts.txt not found after download.
    pause
    goto end
)

echo Creating database %PGDATABASE%... >> "%LOGFILE%"
echo CREATE DATABASE %PGDATABASE% WITH OWNER=%PGUSER% ENCODING='UTF8' TEMPLATE=template0; > "%LOCAL_DIR%\crt_db.sql"
psql -v ON_ERROR_STOP=0 -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -f "%LOCAL_DIR%\crt_db.sql" >> "%LOGFILE%" 2>&1

REM --- Create roles before schema creation ---
echo Creating roles for standard schemas...
for %%S in (billadmin laboradmin enterprise wmsadmin wmrptuser) do (
    psql -v ON_ERROR_STOP=0 -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -c "DO $$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '%%S') THEN CREATE ROLE %%S LOGIN; END IF; END $$;" >> "%LOGFILE%" 2>&1
)

echo Creating roles for warehouse schemas...
for /L %%N in (1,1,%No_Wh%) do (
    set "ROL=wmwhse%%N"
    psql -v ON_ERROR_STOP=0 -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -c "DO $$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '!ROL!') THEN CREATE ROLE !ROL! LOGIN; END IF; END $$;" >> "%LOGFILE%" 2>&1
)

REM --- Create schemas ---
for %%S in (billadmin laboradmin enterprise wmsadmin wmrptuser) do (
    psql -v ON_ERROR_STOP=0 -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -c "CREATE SCHEMA IF NOT EXISTS %%S AUTHORIZATION %%S;" >> "%LOGFILE%" 2>&1
)

for /L %%N in (1,1,%No_Wh%) do (
    set "SCH=wmwhse%%N"
    psql -v ON_ERROR_STOP=0 -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -c "CREATE SCHEMA IF NOT EXISTS !SCH! AUTHORIZATION !SCH!;" >> "%LOGFILE%" 2>&1
)

echo Processing scripts from POSTGRES-scripts.txt... >> "%LOGFILE%"

for /F "usebackq tokens=1,2,3 delims=;" %%A in ("%LOCAL_DIR%\POSTGRES-scripts.txt") do (
    set "LOC_DIR=%%~A"
    set "SVN_SUBDIR=%%~B"
    set "SCRIPT=%%~C"

    if /I "!LOC_DIR!"=="--admin" (
        echo Skipping folder --admin >> "%LOGFILE%"
    ) else (
        if /I "!LOC_DIR!"=="Warehouse" set "LOC_DIR=wm\Warehouse"
        if /I "!LOC_DIR!"=="Security" set "LOC_DIR=wm\Security"

        set "LOCAL_PATH=%LOCAL_DIR%\!LOC_DIR!\!SCRIPT!"
        set "SVN_PATH=%SVN_BASE%/!SVN_SUBDIR!/!SCRIPT!"

        if not exist "%LOCAL_DIR%\!LOC_DIR!" mkdir "%LOCAL_DIR%\!LOC_DIR!" >nul 2>&1

        echo Downloading !SCRIPT!... >> "%LOGFILE%"
        svn export --force --username %SVN_USER% --password %SVN_PASS% "!SVN_PATH!" "!LOCAL_PATH!"

        if exist "!LOCAL_PATH!" (
            findstr /I /C:"INSERT.*WMWHSE1" /C:"UPDATE.*WMWHSE1" /C:"wmwhse1\." "!LOCAL_PATH!" >nul 2>&1
            if not errorlevel 1 (
                echo Executing !SCRIPT! for all warehouses... >> "%LOGFILE%"
                for /L %%N in (1,1,%No_Wh%) do (
                    echo Executing for WMWHSE%%N... >> "%LOGFILE%"
                    set "TMP_FILE=%LOCAL_DIR%\!LOC_DIR!\wmwhse%%N_tmp.sql"
                    powershell -Command "(Get-Content '!LOCAL_PATH!') -replace 'WMWHSE1', 'WMWHSE%%N' | Set-Content '!TMP_FILE!'"
                    call :ExecuteSQL "!TMP_FILE!" "!SCRIPT!"
                    del /f /q "!TMP_FILE!" >nul 2>&1
                )
            ) else (
                echo Executing !SCRIPT!... >> "%LOGFILE%"
                call :ExecuteSQL "!LOCAL_PATH!" "!SCRIPT!"
            )
        ) else (
            echo [WARNING] Failed to download !SCRIPT!. >> "%LOGFILE%"
        )
    )
)

goto backup

:ExecuteSQL
set "FILE=%~1"
set "NAME=%~2"
echo %FILE% | findstr /I "_tmp.sql view.sql view_" >nul
if not errorlevel 1 (
    psql -v ON_ERROR_STOP=0 -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "%FILE%" >nul 2>&1
) else (
    psql -v ON_ERROR_STOP=0 -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "%FILE%" >> "%LOGFILE%" 2>&1
)
goto :eof

:backup
set "BACKUP_FILE=%BASE_DIR%\%PGDATABASE%_backup.dump"
set "MST_DB=%PGDATABASE%mst"

echo Backing up %PGDATABASE% to %BACKUP_FILE%... >> "%LOGFILE%"
pg_dump -h %PGHOST% -p %PGPORT% -U %PGUSER% -F c -d %PGDATABASE% -f "%BACKUP_FILE%" >> "%LOGFILE%" 2>&1 || echo Backup failed, continuing... >> "%LOGFILE%"

echo Creating clone DB %MST_DB%... >> "%LOGFILE%"
psql -v ON_ERROR_STOP=0 -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -c "DROP DATABASE IF EXISTS %MST_DB%;" >> "%LOGFILE%" 2>&1
psql -v ON_ERROR_STOP=0 -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -c "CREATE DATABASE %MST_DB% WITH OWNER=%PGUSER% ENCODING='UTF8' TEMPLATE=template0;" >> "%LOGFILE%" 2>&1

if exist "%BACKUP_FILE%" (
    echo Restoring backup to %MST_DB%... >> "%LOGFILE%"
    pg_restore -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %MST_DB% --no-owner "%BACKUP_FILE%" >> "%LOGFILE%" 2>&1 || echo Restore failed, continuing... >> "%LOGFILE%"
) else (
    echo Backup file not found, skipping restore... >> "%LOGFILE%"
)

echo Cleanup backup file...
del /f /q "%BACKUP_FILE%" >nul 2>&1
del /f /q "%LOCAL_DIR%\POSTGRES-scripts.txt" >nul 2>&1

echo [DONE] Setup complete. Log: %LOGFILE%

:end
pause
ENDLOCAL
exit /B