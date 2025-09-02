@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

echo PostgreSQL Setup Script Starting...
echo Make sure you are running as Administrator.
pause

REM --- Setup PATH ---
set "PG_BIN=C:\Program Files\PostgreSQL\17\bin"
set "PATH=%PG_BIN%;%PATH%"

REM --- Define directories ---
set "SCRIPT_DIR=%~dp0"
set "SCHEMA_DIR=%SCRIPT_DIR%"
set "DB_DIR=%SCRIPT_DIR%"
set "TABLES_DIR=%SCHEMA_DIR%\tables"
set "INSERT_DIR=%SCHEMA_DIR%\Insertions"
set "TRANS_DIR=%SCHEMA_DIR%\Translations"

REM --- Prompt user input ---
set /p Inst_Dir=Install folder (e.g., C:\Infor\sce): 
if "%Inst_Dir%"=="" set "Inst_Dir=C:\Infor\sce"
set /p PGHOST=Database Hostname [localhost]: 
if "%PGHOST%"=="" set "PGHOST=localhost"
set /p PGDATABASE=Instance Name (lowercase only): 
if "%PGDATABASE%"=="" (
    echo Error: Instance name required.
    pause
    goto :EOF
)
set /p No_Wh=Number of Warehouses (1-5): 
if "%No_Wh%"=="" set "No_Wh=1"
set /a testNoWh=%No_Wh% 2>nul
if "%testNoWh%"=="" (
    echo Error: Invalid warehouse number.
    pause
    goto :EOF
)
if %No_Wh% GTR 5 (
    echo Error: Warehouse number exceeds 5.
    pause
    goto :EOF
)
echo.
set /p PGPORT=Database Port [5432]: 
if "%PGPORT%"=="" set "PGPORT=5432"
echo.
set /p PGUSER=PostgreSQL Super User [postgres]: 
if "%PGUSER%"=="" set "PGUSER=postgres"
echo.
set /p PGPASSWORD=PostgreSQL Super User Password: 
echo.
set /p DATA_DIR= Postgres Data Files Location (e.g., %Inst_Dir%\%PGDATABASE%\database\data): 
echo.
set /p LOG_DIR= Postgres Log Files Location (e.g., %Inst_Dir%\%PGDATABASE%\database\log): 
echo.

echo Confirming inputs...
echo Install Dir: %Inst_Dir%
echo Host:        %PGHOST%
echo Database:    %PGDATABASE%
echo Warehouses:  %No_Wh%
echo Port:        %PGPORT%
echo User:        %PGUSER%
echo Data Dir:    %DATA_DIR%
echo Log Dir:     %LOG_DIR%
echo.
pause

REM --- Prepare directories ---
mkdir "%LOG_DIR%" >nul 2>&1
mkdir "%DATA_DIR%" >nul 2>&1

for /f "tokens=2 delims= " %%i in ('date /t') do set today=%%i
for /f "tokens=1-3 delims=/-." %%a in ("%today%") do (
    set yyyy=%%c
    set mm=%%a
    set dd=%%b
)
set "LOGFILE=%LOG_DIR%\pg_setup_%yyyy%-%mm%-%dd%.log"
echo --- PostgreSQL Setup Log --- > "%LOGFILE%"
echo %date% %time% >> "%LOGFILE%"
echo --------------------------- >> "%LOGFILE%"

REM --- Create database ---
echo [DB] Creating database %PGDATABASE%... >> "%LOGFILE%"
echo CREATE DATABASE %PGDATABASE% WITH OWNER=%PGUSER% ENCODING='UTF8' TEMPLATE=template0; > "%DB_DIR%\crt_db.sql"
psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -f "%DB_DIR%\crt_db.sql" >> "%LOGFILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Creating database failed. >> "%LOGFILE%"
    pause
    goto :EOF
)

REM --- Wait for DB availability ---
set retries=5
:WAIT_DB
timeout /t 2 >nul
psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -c "\q" >nul 2>&1
if errorlevel 1 (
    set /a retries-=1
    if !retries! gtr 0 goto WAIT_DB
    echo [ERROR] Database not accessible. >> "%LOGFILE%"
    pause
    goto :EOF
)

REM --- Run foundational SQL ---
echo [SQL] Running foundational scripts... >> "%LOGFILE%"
for %%F in (crt_roles.sql pwds_roles.sql) do (
    if exist "%SCHEMA_DIR%\%%F" (
        psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "%SCHEMA_DIR%\%%F" >> "%LOGFILE%" 2>&1
    )
)

REM --- Create fixed schemas ---
echo [SQL] Creating base schemas... >> "%LOGFILE%"
for %%S in (billadmin laboradmin enterprise wmsadmin wmrptuser) do (
    psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -c "CREATE SCHEMA IF NOT EXISTS %%S AUTHORIZATION %%S;" >> "%LOGFILE%" 2>&1
)

REM --- Create wmwhse schemas ---
echo [SQL] Creating wmwhse schemas... >> "%LOGFILE%"
for /L %%N in (1,1,%No_Wh%) do (
    call :CREATE_WH %%N
)

REM --- Grant roles ---
if exist "%SCHEMA_DIR%\grnt_roles.sql" (
    echo [SQL] Granting roles... >> "%LOGFILE%"
    psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "%SCHEMA_DIR%\grnt_roles.sql" >> "%LOGFILE%" 2>&1
)

REM --- Process tables ---
if exist "%TABLES_DIR%\order.txt" (
    echo [SQL] Processing tables... >> "%LOGFILE%"
    for /F "usebackq tokens=*" %%F in ("%TABLES_DIR%\order.txt") do (
        set "SCRIPT_FILE=%%F"
        call :CHECK_WARE_SKIP "!SCRIPT_FILE!" && (
            echo Skipping %%F due to warehouse limit >> "%LOGFILE%"
        ) || (
            call :RUN_FILE "%TABLES_DIR%\%%F"
        )
    )
)

REM --- Process schema folders ---
echo [SQL] Processing schema folders... >> "%LOGFILE%"
for /D %%S in ("%SCHEMA_DIR%\*") do (
    set "FOLDER=%%~nxS"
    set "SKIP=0"
    if /I not "!FOLDER!"=="tables" if /I not "!FOLDER!"=="Insertions" if /I not "!FOLDER!"=="Translations" (
        echo !FOLDER! | findstr /R /I "^wmwhse[1-5]$" >nul
        if !errorlevel! == 0 (
            for /F %%n in ('powershell -nologo -command "$m='!FOLDER!' -match 'wmwhse(\d+)'; if ($m) { $matches[1] }"') do (
                set /A W=%%n
                if !W! GTR %No_Wh% set SKIP=1
            )
        )
        if !SKIP! EQU 0 if exist "%%S\order.txt" (
            for /F "usebackq tokens=*" %%F in ("%%S\order.txt") do (
                call :RUN_FILE "%%S\%%F"
            )
        )
    )
)

REM --- Grant view roles ---
if exist "%SCHEMA_DIR%\grnts_views.sql" (
    echo [SQL] Granting roles for views... >> "%LOGFILE%"
    psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "%SCHEMA_DIR%\grnts_views.sql" >> "%LOGFILE%" 2>&1
)

REM --- Process Insertions and Translations ---
echo [SQL] Processing Insertions and Translations... >> "%LOGFILE%"
for %%D in ("%INSERT_DIR%" "%TRANS_DIR%") do (
    if exist "%%~D\order.txt" (
        pushd %%~D
        for /F "usebackq tokens=*" %%F in ("order.txt") do (
            call :RUN_FILE "%%~D\%%F"
        )
        popd
    )
)

REM --- Backup and clone the installed DB into <dbname>mst ---
set "BACKUP_FILE=%SCRIPT_DIR%\%PGDATABASE%_temp_backup.dump"
set "MST_DB=%PGDATABASE%mst"

echo [BACKUP] Dumping %PGDATABASE% to %BACKUP_FILE%... >> "%LOGFILE%"
pg_dump -h %PGHOST% -p %PGPORT% -U %PGUSER% -F c -d %PGDATABASE% -f "%BACKUP_FILE%" >> "%LOGFILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Backup of %PGDATABASE% failed. >> "%LOGFILE%"
    echo Backup failed. Check log file: %LOGFILE%
    pause
    goto :EOF
)

if not exist "%BACKUP_FILE%" (
    echo [ERROR] Backup file not created: %BACKUP_FILE% >> "%LOGFILE%"
    echo Backup file missing. Aborting.
    pause
    goto :EOF
)

echo [RESTORE] Creating clone database %MST_DB%... >> "%LOGFILE%"
psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -c "DROP DATABASE IF EXISTS %MST_DB%;" >> "%LOGFILE%" 2>&1
psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -c "CREATE DATABASE %MST_DB% WITH OWNER=%PGUSER% ENCODING='UTF8' TEMPLATE=template0;" >> "%LOGFILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Creating clone DB %MST_DB% failed. >> "%LOGFILE%"
    echo Failed to create clone DB %MST_DB%. Aborting.
    pause
    goto :EOF
)

echo [RESTORE] Restoring data into %MST_DB%... >> "%LOGFILE%"
pg_restore -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %MST_DB% -j 4 --no-owner "%BACKUP_FILE%" >> "%LOGFILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Restore to %MST_DB% failed. >> "%LOGFILE%"
    echo Restore failed. Check log file.
    pause
    goto :EOF
)

echo [CLEANUP] Removing temp backup file... >> "%LOGFILE%"
del /f /q "%BACKUP_FILE%" >nul 2>&1

echo [DONE] Backup and clone to %MST_DB% completed successfully. >> "%LOGFILE%"
echo Script completed successfully. >> "%LOGFILE%"
echo PostgreSQL setup complete! Log at %LOGFILE%

pause
ENDLOCAL
goto :EOF

:CREATE_WH
    setlocal ENABLEDELAYEDEXPANSION
    set "IDX=%~1"
    set "SCH=wmwhse!IDX!"
    echo [SQL] CREATE SCHEMA !SCH!... >> "%LOGFILE%"
    psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -c "CREATE SCHEMA IF NOT EXISTS !SCH! AUTHORIZATION !SCH!;" >> "%LOGFILE%" 2>&1
    endlocal
    goto :EOF

:CHECK_WARE_SKIP
    setlocal
    set "FNAME=%~1"
    echo !FNAME! | findstr /R /I "WMWHSE[1-5]" >nul && (
        for /F %%N in ('powershell -nologo -command "$m='!FNAME!' -match 'WMWHSE(\d+)'; if ($m) { $matches[1] }"') do (
            set /A IDX=%%N
            if !IDX! GTR %No_Wh% (endlocal & exit /B 0)
        )
    )
    endlocal & exit /B 1

:RUN_FILE
    setlocal ENABLEDELAYEDEXPANSION
    set "FP=%~1"
    set "FN=%~nx1"
    set "FOLDER_PATH=%~dp1"

    echo !FP! | findstr /R /I "wmwhse[1-5]" >nul && (
        for /F %%N in ('powershell -nologo -command "$m='!FP!' -match 'wmwhse(\d+)'; if ($m.Success) { $m.Groups[1].Value }"') do (
            set /A IDX=%%N
            if !IDX! GTR %No_Wh% (
                echo Skipping !FP! (wmwhse!IDX! > %No_Wh%) >> "%LOGFILE%"
                endlocal & goto :EOF
            )
        )
    )

    echo !FN! | findstr /R /I "view_.*\.sql" >nul && (
        psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "!FP!" >nul 2>&1
        endlocal & goto :EOF
    )

    echo Executing !FN!... >> "%LOGFILE%"
    psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "!FP!" >> "%LOGFILE%" 2>&1
    endlocal
    goto :EOF
