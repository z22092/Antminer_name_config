@echo off
endlocal
::
:: BatchGotAdmin
:: adaptation From stackoverflow.com
:-------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\icacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo args = "" >> "%temp%\getadmin.vbs"
    echo For Each strArg in WScript.Arguments >> "%temp%\getadmin.vbs"
    echo args = args ^& strArg ^& " "  >> "%temp%\getadmin.vbs"
    echo Next >> "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", args, "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs" %*
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
:_beginning_ini
setlocal  EnableDelayedExpansion
:_log_ini
If not exist ._LOG ( MKDIR ._LOG )
IF NOT DEFINED _DATA_GENERAL ( set "_DATA_GENERAL=%date:~0,2%-%date:~3,2%-%date:~8,4%" )
IF NOT DEFINED _lOG_NAME ( set "_lOG_NAME=%RANDOM:~-3%%RANDOM:~-3%%RANDOM:~-3%-!_DATA_GENERAL!" )
IF NOT DEFINED _LOG ( set "_LOG=._LOG\!_lOG_NAME!.txt")
:_any_way
IF "%1"=="" GOTO :_config_ini
if ["%~1"] NEQ [""] (
IF /I ["%~1"] EQU ["_after_reboot"] ( GOTO :_after_reboot ))
:_config_ini
If not exist ._Config (
    ECHO _CONFIG_INI "!_DATA_GENERAL!" BEGINNING TIME !TIME! >> !_LOG!
    ECHO +===============================::===============================+
    ECHO + By reviewing all the items needed for this application to work +
    echo +         may be need to install a third-party package.          +
    ECHO +===============================::===============================+
    ECHO.
    ECHO Agree, proceed y or n
    choice /c YN /N
    if %errorlevel% equ 2 goto :_Exit_ini
    if %errorlevel% equ 1 goto :_reviewing_ini
    :_after_reboot
    ::
    ECHO _after_reboot "!_DATA_GENERAL!" BEGINNING TIME !TIME! >> !_LOG!
    Schtasks /delete /F /TN "Continue_instalation" > NUL 2>&1
    set "_mes=  one More time"
    ECHO _after_reboot "!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
    ::
    :_reviewing_ini
    ECHO _CONFIG_INI "!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
    ECHO _reviewing_ini "!_DATA_GENERAL!" BEGINNING TIME !TIME! >> !_LOG!
    cls
    ECHO +===============================::===============================+
    ECHO +                      Verifying OS version                      +
    ECHO +===============================::===============================+
    echo%_mes%.
    timeout 2  > NUL 2>&1 
    for /f "delims=. tokens=3" %%a in ( 'ver' ) do set "_ini_test=%%a"
    cls
    if !_ini_test! GEQ 16215 ( 
    ECHO +===============================::===============================+
    ECHO +               Verifying Windows Subsystem Linux                +
    ECHO +===============================::===============================+
    echo%_mes%.
    timeout 2  > NUL 2>&1 
    for /f "tokens=3" %%b in ( 'powershell "Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux" ^| find /I "State"' ) do set "_ini_test2=%%b"
    cls
    if "!_ini_test2!" NEQ "Enabled" (
            ECHO +===============================::===============================+
            ECHO +               Installing Windows Subsystem Linux               +
            ECHO +===============================::===============================+
            timeout 2  > NUL 2>&1 
        powershell Set-Executionpolicy  -force  -Confirm:$False  unrestricted > NUL 2>&1 
        powershell Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName Microsoft-Windows-Subsystem-Linux > NUL 2>&1
        Schtasks /Create /tn "Continue_instalation" /sc ONLOGON  /RL HIGHEST /tr "%cd%\ASIC_CONFIG.BAT _after_reboot" > NUL 2>&1
        ECHO Schtasks errorlevel %errorlevel% "!_DATA_GENERAL!" BEGINNING TIME !TIME! >> !_LOG!
        reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "VerifyDrivers" /f > NUL 2>&1
        reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "VerifyDriverLevel" /f > NUL 2>&1
        ::reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce" /V "Continue_instalation" /t REG_SZ /F /D "cmd /c '%cd%\ASIC_CONFIG.BAT'" > NUL 2>&1
        ECHO REB00T "!_DATA_GENERAL!" BEGINNING TIME !TIME! >> !_LOG!
		
        shutdown /r /f 
        exit /b )) else (
    Echo Your OS is not compatible of this program - please install windows 10 pro ^/ Enterprise version 16215 or updated 
    exit /b )
    ECHO +===============================::===============================+
    ECHO +                        Verifying Ubuntu                        +
    ECHO +===============================::===============================+
    echo%_mes%.
    timeout 2  > NUL 2>&1 
    for /f "tokens=2" %%c in ( 'bash -c "lsb_release -a" ^| find "Description:"'  ) do set "_ini_test3=%%c"
    cls
    if "!_ini_test3!" NEQ "Ubuntu" (
	CLS
    ECHO +===============================::===============================+
    ECHO +                       Installing Ubuntu                        +
    ECHO +===============================::===============================+
    echo.
    echo   ++ Keep calm it's only a terminal emulator for windows :-^} ++
    echo.
    lxrun /install /y
    set "_mes= Again"
    ECHO _reviewing_ini "!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
    goto :_reviewing_ini)
	CLS
    ECHO +===============================::===============================+
    ECHO +                        update Ubuntu                           +
    ECHO +===============================::===============================+
    bash -c "apt-get  -y update && apt-get -y upgrade"
	CLS
    ECHO +===============================::===============================+
    ECHO +                  Installing Ubuntu Programs                    +
    ECHO +===============================::===============================+
    bash -c "apt-get -y Install sshpass"
	bash -c "apt-get -y Install expect"
    MKDIR ._Config 
    Goto :_config_ini 
	)

:_check_config.ini
If not exist ._Config\.config.ini (
	CLS
		ECHO +===============================::===============================+
		ECHO +                     Generate config files                      +
		ECHO +===============================::===============================+
	::
	ECHO +===============================::===============================+ >> ._Config\.config.ini
	echo General configuration file; >> ._Config\.config.ini
	ECHO +===============================::===============================+ >> ._Config\.config.ini
	echo S9_config_file_path="%cd%\._Config\.S9.Config";>> ._Config\.config.ini
	echo T9_config_file_path="%cd%\._Config\.T9.Config";>> ._Config\.config.ini
	echo L3_config_file_path="%cd%\._Config\.L3.Config";>> ._Config\.config.ini
	ECHO defaut_password=admin>> ._Config\.config.ini
	echo new_password=SenhadaFarmpy1>> ._Config\.config.ini
	echo new_old_password=F@rMisN3vrD0wn;>> ._Config\.config.ini
	ECHO COMPANY=company name;>> ._Config\.config.ini
	echo Help file;>> ._Config\.config.ini
	goto :_check_config.ini; 
	)
	::lixo no codigo
	
	::/www/pages/cgi-bin#
::	curl --digest --anyauth --user root:root --verbose http://172.16.1.59/cgi-bin/get_system_info.cgi
::	curl --digest --anyauth --user root:root --verbose http://172.16.1.59/cgi-bin/minerStatus.cgi
::	curl --digest --anyauth --user root:root --verbose http://172.16.1.59/cgi-bin/get_miner_conf.cgi
:: curl -d current_pw=root -d new_pw=F@rMisN3vrD0wn -d new_pw_ctrl=F@rMisN3vrD0wn -X POST --digest --anyauth --user root:root http://172.16.1.59/cgi-bin/passwd.cgi
::  bash -c "echo -n \"stats\" ^| nc 172.16.1.59 4028"
::curl --digest -i -X POST -H "Content-Type: multipart/form-data" --form 'filename=Antminer-T9-PLUS-all-201711242319-autofreq-user-Update2UBI-NF.tar.gz'  --anyauth  --user root:roor http://172.16.1.59/cgi-bin/upgrade_clear.cgi

::curl --digest --anyauth  --user root:roor  Content-Type:multipart/form-data -X POST -H  'Content-Disposition:form-data' -X POST -H 'Content-Type:application/x-gzip'
::-X POST -H name=\"datafile\" -X POST -H filename=\"Antminer-T9-PLUS-all-201711242319-autofreq-user-Update2UBI-NF.tar.gz\"
::Content-Type: application/x-gzip --data '@Antminer-T9-PLUS-all-201711242319-autofreq-user-Update2UBI-NF.tar.gz' http://172.16.1.59/cgi-bin/upgrade_clear.cgi



If not exist ._Config\.S9.Config (
ECHO +===============================::===============================+ >> ._Config\.s9.Config
echo S9 general configuration file; >> ._Config\.S9.Config
ECHO +===============================::===============================+ >> ._Config\.s9.Config
echo pool1=_address one;>> ._Config\.S9.Config
echo pool2=_address two;>> ._Config\.S9.Config
echo pool3=_address tree;>> ._Config\.S9.Config
echo poolacout=Acount;>> ._Config\.S9.Config
echo poolpass=password;>> ._Config\.S9.Config
echo coin=BTC;>> ._Config\.S9.Config
echo model=S9;>> ._Config\.S9.Config
echo Freq="550";>> ._Config\.S9.Config
ECHO NAME_CONF=bmminer.conf;>> ._Config\.S9.Config
echo S9-voltage=\"bitmain-voltage\" : \"0600\",\n;>> ._Config\.S9.Config
goto :_check_config.ini 
)
::


If not exist ._Config\.T9.Config (
ECHO +===============================::===============================+ >> ._Config\.T9.Config
echo T9 general configuration file; >> ._Config\.T9.Config
ECHO +===============================::===============================+ >> ._Config\.T9.Config
echo pool1=_address one;>> ._Config\.T9.Config
echo pool2=_address two;>> ._Config\.T9.Config
echo pool3=_address tree;>> ._Config\.T9.Config
echo poolacout=Acount;>> ._Config\.T9.Config
echo poolpass=password;>> ._Config\.T9.Config
echo coin=BCH;>> ._Config\.T9.Config
echo model=T9;>> ._Config\.T9.Config
echo Freq="550";>> ._Config\.T9.Config
ECHO NAME_CONF=bmminer.conf;>> ._Config\.T9.Config
goto :_check_config.ini 
)
::
If not exist ._Config\.L3.Config (
ECHO +===============================::===============================+ >> ._Config\.L3.Config
echo L3 general configuration file; >> ._Config\.L3.Config
ECHO +===============================::===============================+ >> ._Config\.L3.Config
echo pool1=_address one;>> ._Config\.L3.Config
echo pool2=_address two;>> ._Config\.L3.Config
echo pool3=_address tree;>> ._Config\.L3.Config
echo poolacout=Acount;>> ._Config\.L3.Config
echo poolpass=password;>> ._Config\.L3.Config
echo coin=LTC;>> ._Config\.L3.Config
echo model=L3;>> ._Config\.L3.Config
echo Freq=380;>> ._Config\.L3.Config
ECHO NAME_CONF=cgminer.conf;>> ._Config\.L3.Config
goto :_check_config.ini 
)
::
if not exist ._plugin ( MKDIR ._Plugin 
)
IF NOT EXIST ._plugin\WinDump.exe (
	if not exist plugin.zip (
			echo.
			ECHO +===============================::===============================+
			ECHO +                              ERRO                              +
			ECHO +===============================::===============================+
			echo.
			echo MISS FILE TO INSTALLATION "PLUGIN.ZIP".
			ECHO THIS MISSING FILE CONTENT 2 SOFTWARES WIN10CAP.MSI AND WINDUMP.EXE.
			ECHO.
			ECHO MISSING PLUGIN.ZIP  "!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
			PAUSE  > NUL 2>&1 
	)
	ECHO +===============================::===============================+
	ECHO +                 INSTALLING WINPCAP AND WIMDUMP                 +
	ECHO +===============================::===============================+
	powershell Expand-Archive -LiteralPath plugin.zip -DestinationPath ._plugin\ > NUL 2>&1
	msiexec /i ._plugin\WinPcap.msi /passive > NUL 2>&1
	ECHO UNZIP AND INSTALL PLUGINS "!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
	PAUSE
)		
		
ECHO All need programs are installented "!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
:_config
cls
    ECHO +===============================::===============================+
    ECHO +                      Using defaut config?                      +
    ECHO +===============================::===============================+
	echo.
	choice /t 5 /c snr /N /d r /m "-( S or N )"
	::
	if %errorlevel% EQU 3 goto :_defaut_config
	if %errorlevel% EQU 2 goto :_custom_config
	if %errorlevel% EQU 1 goto :_defaut_config
	::
	:_defaut_config
	ECHO select defaut config file "!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
	GOTO :_set_config.ini
	::
	:_custom_config
	ECHO select custon config file "!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
	IF NOT EXIST ._config\BKP MKDIR ._config\BKP 
	copy /y ._config\.config.ini ._config\BKP\.config-%_DATA_GENERAL%.ini > NUL 2>&1
	copy /y ._config\.S9.Config ._config\.S9-%_DATA_GENERAL%.Config > NUL 2>&1
	copy /y ._config\.T9.Config ._config\.T9-%_DATA_GENERAL%.Config  > NUL 2>&1
	copy /y ._config\.L3.Config ._config\.L3-%_DATA_GENERAL%.Config > NUL 2>&1	
	notepad.exe ._config\.config.ini
	notepad.exe ._Config\.S9.Config
	notepad.exe ._Config\.T9.Config
	notepad.exe ._Config\.L3.Config
	echo.
	GOTO :_set_config.ini
:_set_config.ini
::
SET /A ERRORNUMB=%ERRORNUMB%+1
IF %ERRORNUMB% EQU 10 (
	:error_config
    ECHO +===============================::===============================+
    ECHO +   A ERROR OCURREND IN A CONFIG.INI FILE, REVIW OR REINSTALL    +
    ECHO +===============================::===============================+
	ECHO CONFIG.INI ERROR "!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
	PAUSE
	GOTO _Exit_ini )
::
IF NOT DEFINED defaut_password (
FOR /F "delims=;" %%a in ( 'type ._config\.config.ini ^| find "defaut_password"' ) do (
set "%%a" 
GOTO :_set_config.ini
) )

IF NOT DEFINED new_old_password (
FOR /F "delims=;" %%a in ( 'type ._config\.config.ini ^| find "new_old_password"' ) do (
set "%%a" 
GOTO :_set_config.ini
) )

IF NOT DEFINED new_password (
FOR /F "delims=;" %%a in ( 'type ._config\.config.ini ^| find "new_password"' ) do (
set "%%a" 
GOTO :_set_config.ini
) )

IF NOT DEFINED S9_config_file_path (
FOR /F "delims=;" %%a in ( 'type ._config\.config.ini ^| find "S9_config_file_path"' ) do (
set "%%a" 
GOTO :_set_config.ini
) )

IF NOT DEFINED T9_config_file_path (
FOR /F "delims=;" %%a in ( 'type ._config\.config.ini ^| find "T9_config_file_path"' ) do (
set "%%a" 
GoTO :_set_config.ini
) )

IF NOT DEFINED L3_config_file_path (
FOR /F "delims=;" %%a in ( 'type ._config\.config.ini ^| find "L3_config_file_path"' ) do (
set "%%a" 
GOTO :_set_config.ini
) )
IF NOT DEFINED COMPANY (
FOR /F "delims=;" %%a in ( 'type ._config\.config.ini ^| find "COMPANY"' ) do (
set "%%a" 
GOTO :_set_config.ini
) )

:_select_mod
set "password=!defaut_password!
	SET /A ERRORNUMB=0
	CLS
    ECHO +===============================::===============================+
    ECHO +                         Select one mode                        +
	ECHO +===============================::===============================+
	ECHO +===============================::===============================+
    ECHO +.1- MANUAL NAME                                                 + 
	ECHO +.2- AUTOMATIC NAME GENERATE                                     +
	ECHO +.3- BACK                                                        +
	ECHO +.4- EXIT                                                        +
    ECHO +===============================::===============================+
	echo.
	choice /c 1234 /N /m ":"
	if %errorlevel% EQU 4 (
		goto :_Exit_ini )
	if %errorlevel% EQU 3 (
		goto :_beginning_ini )
	if %errorlevel% EQU 2 (
		SET "MODE=2" 
		ECHO auto mode select"!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
		goto :_Stepbystep_auto )
	if %errorlevel% EQU 1 (
		SET "MODE=1" 
		ECHO manual mode select"!_DATA_GENERAL!" ENDING TIME !TIME! >> !_LOG!
		goto :_Stepbystep_man )
::
:_confirmation_man
if not defined confirm_messenger (
	set "confirm_messenger=                          CONFIRMA ?                          " )
	echo.
	echo nome !_ASIC_NAME! - ip !ASIC_IP! - workname !_Workname! - ID !_ASIC_ID!
	echo. 
	ECHO +===============================::===============================+
    ECHO + !confirm_messenger! + 
	ECHO +===============================::===============================+
	echo.
	choice /t 10 /c snr /N /d r /m "-( S or N )"
	if !errorlevel! EQU 2 (
		ECHO nome !_ASIC_NAME! - ip !ASIC_IP! - workname !_Workname! canceled !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
			GOTO :_Stepbystep_man )
goto :eof
:_Stepbystep_man
cls > nul
cls
call :_select_Hall
cls > nul
cls
call :_select_shelf_man
cls > nul
cls
call :_set_letter_man
cls > nul
cls
CALL :_ASIC_NUMBER_MAN
CLS
CLS > NUL
CALL :capture
cls > nul
cls
call :_ASIC_ID
cls > nul
cls
call :_Select_Model
cls > nul
cls
CALL :_ASIC_NAME
cls
CLS > NUL
call :_Query_register
::
cls
call :_confirmation_man
CLS
CLS > NUL
call :_ASIC_CONFIG_NOW
CLS
CLS > NUL
call :_register
cls
GOTO :_select_mod
::
ECHO !COMPANY!-!ASIC_MODEL!-!coin!-!_HALL!-!SHELF!-!LETTER!!NUMBER!
pause 
::
:_Stepbystep_auto
cls
call :_select_Hall
cls > nul
cls
call :_select_shelf_auto
cls > nul
cls
call :_set_letter_auto
cls > nul
cls
call :SELECT_LETTER_SHELF
cls > nul
cls
call :_ASIC_END_NUMBER_AUTO
cls > nul
cls
call :_ASIC_BEG_NUMBER_AUTO
cls > nul
CLS
IF !MODE! EQU 2 (
	set "COIN="
	echo.
	ECHO !COMPANY!-MODELO-COIN-!_HALL!-!SHELF!-!LETTER!!NUMBER!
	ECHO ESTANTE !BEG_SHELF! A !END_SHELF!
	ECHO !N_LETTER! PRATELEIRAS POR ESTANTE
	ECHO !END_NUMBER! MAQUINAS POR PRATELEIRA
	echo.
	ECHO !COMPANY!-MODELO-!coin!-!_HALL!-!SHELF!-!LETTER!!NUMBER! A !COMPANY!-MODELO-!coin!-!_HALL!-!END_SHELF!-!END_LETTER!!END_NUMBER!
	echo.
	PAUSE
	ECHO +===============================::===============================+
    ECHO +                            CONFIRMA?                           + 
	ECHO +===============================::===============================+
	echo.
	choice /t 5 /c snr /N /d r /m "-( S or N )"
	if !errorlevel! EQU 2 (
			GOTO :_select_mod ))
cls > nul
CLS

GOTO :_AUTOMATRON
::
ECHO !COMPANY!-!model!-!coin!-!_HALL!-!SHELF!-!LETTER!!NUMBER!
::
pause
::
:_Select_Model
set "erro="
set "config_file_path="
	ECHO +===============================::===============================+
    ECHO +                     Selecionando modelo                        + 
	ECHO +===============================::===============================+
::
	if "!ASIC_MODEL!" EQU "L3" (
		SET "config_file_path=!L3_config_file_path!" )
	if "!ASIC_MODEL!" EQU "T9" (
		SET "config_file_path=!T9_config_file_path!" )
	if "!ASIC_MODEL!" EQU "S9" (
		SET "config_file_path=!S9_config_file_path!" )
	::
	ECHO _Select_Model !config_file_path! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
if not defined config_file_path (
echo !ASIC_MODEL! !ASIC_TYPE! !_asic_id!
	set "erro=!erro!+1"
	if !erro! equ 1 (
		set "password=!new_password!"
		goto :cat )
	IF !erro! equ 2 (
		set "password=!new_old_password!"
		goto :cat )
	if !erro! equ 3 (
		call :error_config ))
::
::
ECHO _Select_Model set config !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
::
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "pool1"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "pool2"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "pool3"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "poolacout"' ) do (
		set "%%a" 
		) 
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "poolpass"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "coin"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "model"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "Freq"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "NAME_CONF"' ) do (
		set "%%a" 
		)
if !ASIC_MODEL! equ S9 (
	FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "S9-voltage"' ) do (
		set "%%a" 
		) )
IF NOT DEFINED pool1 (
	CALL :error_config ) 
IF NOT DEFINED poolacout (
	CALL :error_config ) 
::
ECHO _Select_Model set config !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
goto :eof
::_Select_Model
CLS
	ECHO _Select_Model !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
    ECHO +===============================::===============================+
    ECHO +                         Select a model                         +
    ECHO +===============================::===============================+
	echo.
	ECHO +===============================::===============================+
    ECHO +.1- Antminer S9                                                 + 
	ECHO +.2- Antminer T9                                                 +
	ECHO +.3- Antminer L3                                                 +
	ECHO +.4- BACK                                                        +
	ECHO +.5- EXIT                                                        +
    ECHO +===============================::===============================+
	echo.
	choice /c 12345 /N /m ":"
	::
	if %errorlevel% EQU 5 (
		goto :_Exit_ini )
	if %errorlevel% EQU 4 (
		goto :_select_mod )
	if %errorlevel% EQU 3 (
		SET "config_file_path=!L3_config_file_path!" )
	if %errorlevel% EQU 2 (
		SET "config_file_path=!T9_config_file_path!" )
	if %errorlevel% EQU 1 (
		SET "config_file_path=!S9_config_file_path!" )
	::
	ECHO _Select_Model !config_file_path! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
if not defined config_file_path ( 
	call :error_config )
::
::
ECHO _Select_Model set config !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
::
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "pool1"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "pool2"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "pool3"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "poolacout"' ) do (
		set "%%a" 
		) 
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "poolpass"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "coin"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "model"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "Freq"' ) do (
		set "%%a" 
		)
FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "NAME_CONF"' ) do (
		set "%%a" 
		)
if !model! equ S9 (
	FOR /F "tokens=1 delims=;" %%a in (  'type !config_file_path! ^| Find "S9-voltage"' ) do (
		set "%%a" 
		) )
IF NOT DEFINED pool1 (
	CALL :error_config ) 
IF NOT DEFINED poolacout (
	CALL :error_config ) 
::
ECHO _Select_Model set config !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
goto :eof

:_select_Hall
	ECHO _select_Hall !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
	CLS
	echo.
	ECHO !COMPANY!-MODELO-!coin!
	echo.
	if !mode! equ 2 echo Automatic mod
	if !mode! equ 1 echo manual mod
	echo.
    ECHO +===============================::===============================+
    ECHO +                      Selecione o corredor                      +
	ECHO +===============================::===============================+
	ECHO +===============================::===============================+
    ECHO +.1- Corredor 1                                                  + 
	ECHO +.2- Corredor 2                                                  +
	ECHO +.3- Corredor 3                                                  +
	ECHO +.4- Corredor 4                                                  +
	ECHO +.5- BACK                                                        +
	ECHO +.6- EXIT                                                        +
    ECHO +===============================::===============================+
	echo.
	choice /c 123456 /N /m ":"
	::
	if %errorlevel% EQU 6 (
		goto :_Exit_ini )
	if %errorlevel% EQU 5 (
		goto :_Select_Mod )
	if %errorlevel% EQU 1 (
		SET "_HALL=C1" )
	if %errorlevel% EQU 2 (
		SET "_HALL=C2" )
	if %errorlevel% EQU 3 (
		SET "_HALL=C3" )
	if %errorlevel% EQU 4 (
		SET "_HALL=C4" )
		::
ECHO _select_Hall CHOICED !_HALL! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
goto :eof

:_select_shelf_man
	ECHO _select_shelf_man !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
	CLS
	echo.
	ECHO !COMPANY!-MODELO-!coin!-!_HALL!
	echo.
	if !mode! equ 2 echo modo errado favor reiniciar o programa
	if !mode! equ 1 echo manual mod
	echo.
    ECHO +===============================::===============================+
    ECHO +                   DIGITE O NUMERO DA ESTANTE                   +
	ECHO +===============================::===============================+
	echo.
	SET /P "SHELF=:"
	SET "SHELF=00!SHELF!"
	SET "SHELF=!SHELF:~-2!"
	ECHO _select_shelf_man CHOICED !SHELF! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
	goto :eof
::
:_select_shelf_auto
::
SET "SHELF="
	ECHO _select_shelf_auto !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
	echo.
	ECHO !COMPANY!-MODELO-!coin!-!_HALL!
	echo.
	if !mode! equ 2 echo Automatic mod
	if !mode! equ 1 echo modo errado favor reiniciar o programa
	echo.
    ECHO +===============================::===============================+
    ECHO +    DIGITE O NUMERO DA ESTANTE ONDE COMECARA A CONFIGURACAO     +
	ECHO +===============================::===============================+
	echo.
	SET /P "SHELF=:"
	SET "SHELF=00!SHELF!"
	SET "SHELF=!SHELF:~-2!" 
	SET "BEG_SHELF=!SHELF!"
	ECHO _select_shelf_auto BEG_SHELF CHOICED !BEG_SHELF! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
	CLS
	echo.
	ECHO !COMPANY!-MODELO-!coin!-!_HALL!
	ECHO ESTANTE !BEG_SHELF! A 
	echo.
    ECHO +===============================::===============================+
    ECHO +   DIGITE O NUMERO DA ESTANTE ONDE TERMINARA A CONFIGURACAO     +
	ECHO +===============================::===============================+
	echo.
	SET /P "END_SHELF=:"
	set /a "END_SHELF=!END_SHELF!+1"
	SET "END_SHELF=00!END_SHELF!"
	SET "END_SHELF=!END_SHELF:~-2!" 
	SET "END_SHELF=!END_SHELF!"
	::
	ECHO _select_shelf_auto END_SHELF CHOICED !END_SHELF! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
	::
	IF !END_SHELF! LSS !BEG_SHELF! (
	ECHO _select_shelf_auto !END_SHELF! LSS !BEG_SHELF! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
	CLS
	::
	echo.
	ECHO O NUMERO DA ESTANTE FINAL NAO PODE SER MENOR QUE A DE COMECO 
	GOTO :_select_shelf_auto )
	ECHO _select_shelf_auto  CHOICED BEG !BEG_SHELF! END !END_SHELF! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
	goto :eof
::
:_set_letter_man
	ECHO _set_letter_man !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
	CLS
	echo.
	ECHO !COMPANY!-MODELO-!coin!-!_HALL!-!SHELF!
	echo.
	if !mode! equ 2 echo modo errado favor reiniciar o programa
	if !mode! equ 1 echo manual mod
	echo.
    ECHO +===============================::===============================+
    ECHO +     SELECIONE A LETRA DE ACORDO COM O ANDAR DA PRATELEIRA      + 
	ECHO +     ^(DE CIMA PARA BAIXO 1 = A, 2 = B, 3 = C, 4 = D, ETC^)       +
	ECHO +===============================::===============================+
	ECHO +===============================::===============================+
    ECHO +.-A                                                             + 
    ECHO +.-B                                                             + 
    ECHO +.-C                                                             + 
    ECHO +.-D                                                             + 
	ECHO +.-O ^(OUTRA^)                                                     + 
	ECHO +.6- BACK                                                        +
	ECHO +.7- EXIT                                                        +
    ECHO +===============================::===============================+
	echo.

	choice /c ABCDO67 /N /m ": "
	
	if %errorlevel% EQU 6 (
		goto :_Select_Mod )
	if %errorlevel% EQU 7 (
	goto :_Exit_ini )
	if %errorlevel% EQU 1 (
		SET "LETTER=A" )
	if %errorlevel% EQU 2 (
		SET "LETTER=B" )
	if %errorlevel% EQU 3 (
		SET "LETTER=C" )
	if %errorlevel% EQU 4 (
		SET "LETTER=D" )
	if %errorlevel% EQU 5 (
		ECHO.
		SET /P "LETTER=QUAL LETRA?: ")
	ECHO _set_letter_man  CHOICED BEG !LETTER! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
goto :eof
::
:_set_letter_auto
ECHO _set_letter_auto  !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
cls
::	SET "N_LETTER=4
::	goto :SELECT_LETTER_SHELF
	echo.
	ECHO !COMPANY!-MODELO-!coin!-!_HALL!
	ECHO ESTANTE !BEG_SHELF! A !END_SHELF!
	echo.
	if !mode! equ 2 echo Automatic mod
	if !mode! equ 1 echo modo errado favor reiniciar o programa
	echo.
	ECHO +===============================::===============================+
    ECHO +       POR PADRAO SAO 4 PRATELEIRAS POR ESTANTE, CONFIRMA?      + 
	ECHO +===============================::===============================+
	echo.
	choice /t 5 /c snr /N /d r /m "-( S or N )"
	::
	if %errorlevel% EQU 1 (
		SET "N_LETTER=4" 
		ECHO _set_letter_auto DEFINED !N_LETTER! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG! )
	::
	if %errorlevel% EQU 2 (
		CLS
		ECHO !COMPANY!-MODELO-!coin!-!_HALL!
		ECHO ESTANTE !BEG_SHELF! A  !END_SHELF!
		echo.
		if !mode! equ 2 echo Automatic mod
		if !mode! equ 1 echo modo errado favor reiniciar o programa
		echo.
		ECHO +===============================::===============================+
		ECHO +                DIGITE O NUMERO DE PRATELEIRAS ?  ^(1 A 10^)      + 
		ECHO +===============================::===============================+
		echo.
		SET /p "N_LETTER=:"
		ECHO _set_letter_auto DEFINED !N_LETTER! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG! )
		::
	if %errorlevel% EQU 3 (
		SET "N_LETTER=4" 
		ECHO _set_letter_auto DEFINED !N_LETTER! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG! )
	CLS 
:: 
goto :eof
:SELECT_LETTER_SHELF
	ECHO SELECT_LETTER_SHELF  !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG! 
	IF NOT DEFINED N_LETTER GOTO :_set_letter
	IF "!N_LETTER!" EQU "" GOTO :_set_letter
	IF !N_LETTER! EQU 1 ( GOTO :CAPTURE )
	CLS
	echo.
	ECHO !COMPANY!-MODELO-!coin!-!_HALL!-!SHELF!
	ECHO ESTANTE !BEG_SHELF! A !END_SHELF!
	ECHO !N_LETTER! PRATELEIRAS POR ESTANTE 
	echo.
	if !mode! equ 2 echo Automatic mod
	if !mode! equ 1 echo modo errado favor reiniciar o programa
	echo.
	ECHO +===============================::===============================+
    ECHO +              POR QUAL PRATELEIRA DESEJA COMECAR?               + 
	ECHO +===============================::===============================+
	echo.
	IF !N_LETTER! EQU 2 (
		ECHO +===============================::===============================+
		ECHO +.-A                                                             + 
		ECHO +.-B                                                             + 
		ECHO +===============================::===============================+
		echo.
		cls > nul
		choice /c AB /N /m ":"
		if !errorlevel! EQU 1 (
			SET "LETTER=A" 
			set "D_LETTER=1")
		if !errorlevel! EQU 2 (
			SET "LETTER=B" 
			set "D_LETTER=2"))
	::
	IF !N_LETTER! EQU 3 (
		ECHO +===============================::===============================+
		ECHO +.-A                                                             + 
		ECHO +.-B                                                             + 
		ECHO +.-C                                                             + 
		ECHO +===============================::===============================+
		echo.
		cls > nul
		choice /c ABC /N /m ":"
		if !errorlevel! EQU 1 (
			SET "LETTER=A" 
			set "D_LETTER=1" )
		if !errorlevel! EQU 2 (
			SET "LETTER=B" 
			set "D_LETTER=2" )
		if !errorlevel! EQU 3 (
			SET "LETTER=C"
			set	"D_LETTER=3" ))
	::
	IF !N_LETTER! EQU 4 (
		ECHO +===============================::===============================+
		ECHO +.-A                                                             + 
		ECHO +.-B                                                             + 
		ECHO +.-C                                                             + 
		ECHO +.-D                                                             + 
		ECHO +===============================::===============================+
		echo.
		cls > nul
		choice /c ABCD /N /m ":"
		if !errorlevel! EQU 1 (
			SET "LETTER=A" 
			set "D_LETTER=1" )
		if !errorlevel! EQU 2 (
			SET "LETTER=B" 
			set "D_LETTER=2" ) 
		if !errorlevel! EQU 3 (
			SET "LETTER=C"
			set	"D_LETTER=3" )
		if !errorlevel! EQU 4 (
			SET "LETTER=D"
			set	"D_LETTER=4" ))
	::
	IF !N_LETTER! EQU 5 (
		ECHO +===============================::===============================+
		ECHO +.-A                                                             + 
		ECHO +.-B                                                             + 
		ECHO +.-C                                                             + 
		ECHO +.-D                                                             + 
		ECHO +.-E                                                             + 
		ECHO +===============================::===============================+
		echo.
		cls > nul
		choice /c ABCDE /N /m ":"
		if !errorlevel! EQU 1 (
			SET "LETTER=A" 
			set "D_LETTER=1" )
		if !errorlevel! EQU 2 (
			SET "LETTER=B" 
			set "D_LETTER=2" ) 
		if !errorlevel! EQU 3 (
			SET "LETTER=C"
			set	"D_LETTER=3" )
		if !errorlevel! EQU 4 (
			SET "LETTER=D"
			set	"D_LETTER=4" )
		if !errorlevel! EQU 5 (
			SET "LETTER=E"
			set	"D_LETTER=5" ))
	::
	IF !N_LETTER! EQU 6 (
		ECHO +===============================::===============================+
		ECHO +.-A                                                             + 
		ECHO +.-B                                                             + 
		ECHO +.-C                                                             + 
		ECHO +.-D                                                             + 
		ECHO +.-E                                                             + 
		ECHO +.-F                                                             + 
		ECHO +===============================::===============================+
		echo.
		cls > nul
		choice /c ABCDEF /N /m ":"
		if !errorlevel! EQU 1 (
			SET "LETTER=A" 
			set "D_LETTER=1" )
		if !errorlevel! EQU 2 (
			SET "LETTER=B" 
			set "D_LETTER=2" ) 
		if !errorlevel! EQU 3 (
			SET "LETTER=C"
			set	"D_LETTER=3" )
		if !errorlevel! EQU 4 (
			SET "LETTER=D"
			set	"D_LETTER=4" )
		if !errorlevel! EQU 5 (
			SET "LETTER=E"
			set	"D_LETTER=5" )
		if !errorlevel! EQU 6 (
			SET "LETTER=F"
			set	"D_LETTER=6" ))
	::
	IF !N_LETTER! EQU 7 (
		ECHO +===============================::===============================+
		ECHO +.-A                                                             + 
		ECHO +.-B                                                             + 
		ECHO +.-C                                                             + 
		ECHO +.-D                                                             + 
		ECHO +.-F                                                             + 
		ECHO +.-G                                                             + 
		ECHO +===============================::===============================+
		echo.
		cls > nul
		choice /c ABCDEFG /N /m ":"
		if !errorlevel! EQU 1 (
			SET "LETTER=A" 
			set "D_LETTER=1" )
		if !errorlevel! EQU 2 (
			SET "LETTER=B" 
			set "D_LETTER=2" ) 
		if !errorlevel! EQU 3 (
			SET "LETTER=C"
			set	"D_LETTER=3" )
		if !errorlevel! EQU 4 (
			SET "LETTER=D"
			set	"D_LETTER=4" )
		if !errorlevel! EQU 5 (
			SET "LETTER=E"
			set	"D_LETTER=5" )
		if !errorlevel! EQU 6 (
			SET "LETTER=F"
			set	"D_LETTER=6")
		if !errorlevel! EQU 7 (
			SET "LETTER=G" 
			set	"D_LETTER=7" ))
	::
	IF !N_LETTER! EQU 8 (
		ECHO +===============================::===============================+
		ECHO +.-A                                                             + 
		ECHO +.-B                                                             + 
		ECHO +.-C                                                             + 
		ECHO +.-D                                                             + 
		ECHO +.-E                                                             + 
		ECHO +.-F                                                             + 
		ECHO +.-G                                                             + 
		ECHO +.-H                                                             + 
		ECHO +===============================::===============================+
		echo.
		cls > nul
		choice /c ABCDEFGH /N /m ":"
		if !errorlevel! EQU 1 (
			SET "LETTER=A" 
			set "D_LETTER=1" )
		if !errorlevel! EQU 2 (
			SET "LETTER=B" 
			set "D_LETTER=2") 
		if !errorlevel! EQU 3 (
			SET "LETTER=C"
			set	"D_LETTER=3")
		if !errorlevel! EQU 4 (
			SET "LETTER=D"
			set	"D_LETTER=4" )
		if !errorlevel! EQU 5 (
			SET "LETTER=E"
			set	"D_LETTER=5")
		if !errorlevel! EQU 6 (
			SET "LETTER=F"
			set	"D_LETTER=6")
		if !errorlevel! EQU 7 (
			SET "LETTER=G" 
			set	"D_LETTER=7")
		if !errorlevel! EQU 8 (
			SET "LETTER=H"
			set	"D_LETTER=8" ))
	::
	IF !N_LETTER! EQU 9 (
		ECHO +===============================::===============================+
		ECHO +.-A                                                             + 
		ECHO +.-B                                                             + 
		ECHO +.-C                                                             + 
		ECHO +.-D                                                             + 
		ECHO +.-E                                                             + 
		ECHO +.-F                                                             + 
		ECHO +.-G                                                             + 
		ECHO +.-H                                                             + 
		ECHO +.-I                                                             +
		ECHO +===============================::===============================+
		echo.
		cls > nul
		choice /c ABCDEFGHI /N /m ":"
		if !errorlevel! EQU 1 (
			SET "LETTER=A" 
			set "D_LETTER=1")
		if !errorlevel! EQU 2 (
			SET "LETTER=B" 
			set "D_LETTER=2") 
		if !errorlevel! EQU 3 (
			SET "LETTER=C"
			set	"D_LETTER=3")
		if !errorlevel! EQU 4 (
			SET "LETTER=D"
			set	"D_LETTER=4")
		if !errorlevel! EQU 5 (
			SET "LETTER=E"
			set	"D_LETTER=5")
		if !errorlevel! EQU 6 (
			SET "LETTER=F"
			set	"D_LETTER=6")
		if !errorlevel! EQU 7 (
			SET "LETTER=G" 
			set	"D_LETTER=7")
		if !errorlevel! EQU 8 (
			SET "LETTER=H"
			set	"D_LETTER=8")
		if !errorlevel! EQU 9 (
			SET "LETTER=I" 
			set	"D_LETTER=9" ))
	::
	IF !N_LETTER! EQU 10 (
		ECHO +===============================::===============================+
		ECHO +.-A                                                             + 
		ECHO +.-B                                                             + 
		ECHO +.-C                                                             + 
		ECHO +.-D                                                             + 
		ECHO +.-E                                                             + 
		ECHO +.-F                                                             + 
		ECHO +.-G                                                             + 
		ECHO +.-H                                                             + 
		ECHO +.-I                                                             +
		ECHO +.-J                                                             +
		ECHO +===============================::===============================+
		echo.
		cls > nul
		choice /c ABCDEFGHIJ /N /m ":"
		if !errorlevel! EQU 1 (
			SET "LETTER=A" 
			set "D_LETTER=1")
		if !errorlevel! EQU 2 (
			SET "LETTER=B" 
			set "D_LETTER=2") 
		if !errorlevel! EQU 3 (
			SET "LETTER=C"
			set	"D_LETTER=3")
		if !errorlevel! EQU 4 (
			SET "LETTER=D"
			set	"D_LETTER=4")
		if !errorlevel! EQU 5 (
			SET "LETTER=E"
			set	"D_LETTER=5")
		if !errorlevel! EQU 6 (
			SET "LETTER=F"
			set	"D_LETTER=6")
		if !errorlevel! EQU 7 (
			SET "LETTER=G" 
			set	"D_LETTER=7")
		if !errorlevel! EQU 8 (
			SET "LETTER=H"
			set	"D_LETTER=8")
		if !errorlevel! EQU 9 (
			SET "LETTER=I" 
			set	"D_LETTER=9" )
		if !errorlevel! EQU 10 (
			SET "LETTER=J"
			set	"D_LETTER=10"))
			
if !N_LETTER! EQU 1 (
	SET "END_LETTER=A" )
if !N_LETTER! EQU 2 (
	SET "END_LETTER=B" )
if !N_LETTER! EQU 3 (
	SET "END_LETTER=C" )
if !N_LETTER! EQU 4 (
	SET "END_LETTER=D" )
if !N_LETTER! EQU 5 (
	SET "END_LETTER=E" )
if !N_LETTER! EQU 6 (
	SET "END_LETTER=F" )
if !N_LETTER! EQU 7 (
	SET "END_LETTER=G" )
if !N_LETTER! EQU 8 (
	SET "END_LETTER=H" )
if !N_LETTER! EQU 9 (
	SET "END_LETTER=I" )
if !N_LETTER! EQU 10 (
	SET "END_LETTER=J" ) 
::
ECHO SELECT_LETTER_SHELF !N_LETTER! !D_LETTER! !LETTER! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG! 
goto :eof
:_ASIC_NUMBER_MAN
::	
	ECHO _ASIC_NUMBER_MAN !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
	echo.
	ECHO !COMPANY!-MODELO-!coin!-!_HALL!-!SHELF!-!LETTER!
	echo.
	if !mode! equ 2 echo modo errado favor reiniciar o programa
	if !mode! equ 1 echo manual mod
	echo.
	ECHO +===============================::===============================+
    ECHO +          DIGITE O NUMERO DA MAQUINA QUE DESEJA RENOMEAR        + 
	ECHO +===============================::===============================+
	echo.
	SET /p "NUMBER=: "
	ECHO _ASIC_NUMBER_MAN CHOICED !NUMBER! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
	GOTO :EOF
::
:_ASIC_END_NUMBER_AUTO
::
	echo.
	ECHO _ASIC_END_NUMBER_AUTO !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
	ECHO !COMPANY!-MODELO-!coin!-!_HALL!-!SHELF!-!LETTER!
	ECHO ESTANTE !BEG_SHELF! A !END_SHELF!
	ECHO !N_LETTER! PRATELEIRAS POR ESTANTE 
	echo.
	if !mode! equ 2 echo Automatic mod
	if !mode! equ 1 echo modo errado favor reiniciar o programa
	echo.
	ECHO +===============================::===============================+
    ECHO +           QUANTAS MAQUINAS EXISTEM POR PRATELEIRA?             + 
	ECHO +===============================::===============================+
	echo.
	SET /p "END_NUMBER=: "
	::
	ECHO _ASIC_END_NUMBER_AUTO CHOICED !NUMBER! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
	cls
	::
GOTO EOF
::
:_ASIC_BEG_NUMBER_AUTO
::
IF !END_NUMBER! EQU 1 (
	GOTO :EOF )
	::
if !END_NUMBER! EQU 9 (
		SET "_NUMBER_CHOISE=123456789" )	
if !END_NUMBER! EQU 8 (
		SET "_NUMBER_CHOISE=12345678" )	
if !END_NUMBER! EQU 7 (
		SET "_NUMBER_CHOISE=1234567" )
if !END_NUMBER! EQU 6 (
		SET "_NUMBER_CHOISE=123456" )
if !END_NUMBER! EQU 5 (
		SET "_NUMBER_CHOISE=12345" )
if !END_NUMBER! EQU 4 (
		SET "_NUMBER_CHOISE=1234" )
if !END_NUMBER! EQU 3 (
		SET "_NUMBER_CHOISE=123" )
if !END_NUMBER! EQU 2 (
		SET "_NUMBER_CHOISE=12" )
	::
	echo.
	ECHO !COMPANY!-MODELO-!coin!-!_HALL!-!SHELF!-!LETTER!
	ECHO ESTANTE !BEG_SHELF! A !END_SHELF!
	ECHO !N_LETTER! PRATELEIRAS POR ESTANTE
	ECHO !END_NUMBER! MAQUINAS POR PRATELEIRA
	echo.
	if !mode! equ 2 echo modo errado favor reiniciar o programa
	if !mode! equ 1 echo manual mod
	echo.
	ECHO +===============================::===============================+
    ECHO +               POR QUAL MAQUINAS DESEJA COMECAR ?               + 
	ECHO +===============================::===============================+
	::
	if !END_NUMBER! LSS 10 (
	ECHO +===============================::===============================+
	ECHO +.-1                                                             +
	if !END_NUMBER! GEQ 2 (
		ECHO +.-2                                                             + )
	if !END_NUMBER! GEQ 3 (
		ECHO +.-3                                                             + )
	if !END_NUMBER! GEQ 4 (
		ECHO +.-4                                                             + )
	if !END_NUMBER! GEQ 5 (
		ECHO +.-5                                                             + )
	if !END_NUMBER! GEQ 6 (
		ECHO +.-6                                                             + )
	if !END_NUMBER! GEQ 7 (
		ECHO +.-7                                                             + )
	if !END_NUMBER! GEQ 8 (
		ECHO +.-8                                                             + )	
	if !END_NUMBER! GEQ 9 (
		ECHO +.-9                                                             + ) 
	ECHO +===============================::===============================+ 
	cls > nul
	choice /c !_NUMBER_CHOISE! /N /m ":" 
	::
	if "!errorlevel!" EQU "9" (
			SET "NUMBER=9" )
	if !errorlevel! EQU 8 (
			SET "NUMBER=8" )
	if !errorlevel! EQU 7 (
			SET "NUMBER=7" )
	if !errorlevel! EQU 6 (
			SET "NUMBER=6" )
	if !errorlevel! EQU 5 (
			SET "NUMBER=5" )
	if !errorlevel! EQU 4 (
			SET "NUMBER=4" )
	if !errorlevel! EQU 3 (
			SET "NUMBER=3" )
	if !errorlevel! EQU 2 (
			SET "NUMBER=2" )
	if !errorlevel! EQU 1 (
			SET "NUMBER=1" ) )
	::
	if !END_NUMBER! GEQ 10 (
	set "NUMBER=: " )
GOTO :EOF
::
:_ASIC_ID
ECHO _ASIC_ID !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
::'bash -c "echo -n \"stats\" ^| nc !ASIC_IP! !ASIC_PORT!"'
for /f "delims=" %%x in ( 'bash -c "echo -n \"stats\" ^| nc !ASIC_IP! 4028"' ) do (
	set "Build=%%x"
	call :typewriter >> "._LOG\temp.txt" )
if not defined Build (
	set "erro=!erro!+1"
	if !erro! equ 1 (
		set "password=!new_password!"
		goto :_ASIC_ID )
	IF !erro! equ 2 (
		set "password=!new_old_password!")
	if !erro! equ 3 (
		set "password=!defaut_password!"
		goto :cat )

::

for /f "delims=^=,^|^. tokens=2" %%a in ('type "._LOG\temp.txt" ^| findstr /I "miner_id="') do (
	set "_ASIC_ID=%%a"
)
for /f "delims=^=,^| tokens=2" %%a in ('type "._LOG\temp.txt" ^| findstr /I "Type="') do (
	set "ASIC_TYPE=%%a" 
	for /f "tokens=2"  %%a in ( "!ASIC_TYPE!" ) do ( 
		set "ASIC_TYPE=%%a"
		set "ASIC_MODEL=!ASIC_TYPE:~0,2!"
)
)
:cat
if not defined _ASIC_ID (

BASH -c "sshpass -p  !password!  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@!ASIC_IP! 'cat /tmp/search' | grep "ID"" > ._LOG\temp2.txt
::
for /f "tokens=5" %%a in ( 'type "._LOG\temp2.txt" ^| findstr /I "miner id"') do (
set "_ASIC_ID=%%a"
) > NUL 2>&1
::
BASH -c "sshpass -p  !password!  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@!ASIC_IP! 'cat /tmp/search' | grep "Miner Type"" > ._LOG\temp2.txt
::
for /f "tokens=5" %%a in ( 'type "._LOG\temp.txt" ^| findstr /I "Miner Type"') do (
set "ASIC_TYPE=%%a"
set "ASIC_MODEL=!ASIC_TYPE:~0,2!"
) > NUL 2>&1
::
del ._LOG\temp.txt
del ._LOG\temp2.txt
ECHO _ASIC_ID !_ASIC_ID! !ASIC_TYPE! !_DATA_GENERAL! ending TIME !TIME! >> !_LOG!
goto eof
::
:_ASIC_NAME
ECHO _ASIC_NAME !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
::
SET "_ASIC_NAME=!COMPANY!-!ASIC_TYPE!-!coin!-!_HALL!-!SHELF!-!LETTER!!NUMBER!"
SET "_Workname=!ASIC_MODEL!!_HALL!!SHELF!!LETTER!!NUMBER!"
::
ECHO _ASIC_NAME !_ASIC_NAME! AND !_Workname! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
GOTO EOF
::
:_ASIC_NAME_auto
if not defined _SHELF (
	set "_SHELF=!BEG_SHELF!"
	set /a "END_SHELF=!END_SHELF!+1"
	set "_NUMBER=!NUMBER!" )
IF !D_LETTER! EQU 1 (
	set "_LETTER=A")
IF !D_LETTER! EQU 2 (
	set "_LETTER=B")
IF !D_LETTER! EQU 3 (
	set "_LETTER=C")
IF !D_LETTER! EQU 4 (
	set "_LETTER=D")
IF !D_LETTER! EQU 5 (
	set "_LETTER=E")
IF !D_LETTER! EQU 6 (
	set "_LETTER=F")
IF !D_LETTER! EQU 7 (
	set "_LETTER=G")
IF !D_LETTER! EQU 8 (
	set "_LETTER=H")
IF !D_LETTER! EQU 9 (
	set "_LETTER=I")
IF !D_LETTER! EQU 10 (
	set "_LETTER=J")
::
::
ECHO _ASIC_NAME_auto !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
::
::
SET "_ASIC_NAME=!COMPANY!-!ASIC_TYPE!-!coin!-!_HALL!-!_SHELF!-!_LETTER!!_NUMBER!"
SET "_Workname=!ASIC_MODEL!!_HALL!!_SHELF!!_LETTER!!_NUMBER!"
::
::
ECHO _ASIC_NAME_auto !_ASIC_NAME! AND !_Workname! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
::
IF !_NUMBER! equ !END_NUMBER! (
set /A "D_letter=!D_letter!+1"
set "c_letter=" 
set "_NUMBER=")
::
IF !_SHELF! equ !END_SHELF! (
goto :_select_mod )
::
set /A "c_letter=!c_letter!+1"
set /A "_NUMBER=!_NUMBER!+1"
::
IF !D_letter! equ !N_LETTER! (
set /A "SHELF=!SHELF!+1" 
set "D_letter=1" )
::
SET "_SHELF=00!SHELF!"
SET "_SHELF=!_SHELF:~-2!" 
echo !_Workname!
echo !_ASIC_NAME!
goto eof
::
:_AUTOMATRON
CLS > NUL
CALL :capture
cls > nul
cls
call :_ASIC_ID
cls > nul
cls
call :_Select_Model
cls > nul
cls
CALL :_ASIC_NAME_auto
::
cls
CLS > NUL
call :_Query_register
CLS
CLS > NUL
call :_ASIC_CONFIG_NOW
CLS
CLS > NUL
call :_register
cls
goto :_AUTOMATRON
set 
For /D %%a in ( A, B, C, D ) do (
set "_L=%%a"
	For /D %%b in ( %_COUNT_SHELF% ) do (
	set "_N=%%b"
	set "ASIC_STATUS=!ASIC_PREFIX!-P!SHELF!-!_L!!_N!"
	call :_SET_IP_AUT
	)
	)
set /A "_COUNTER=!_COUNTER!+1"
set "_NUM_VAR=000!_COUNTER!"
set "SHELF=!_NUM_VAR:~-2!"
if /I !_COUNTER! GTR !E_SHELF! ( 
SET "Load="
goto :_VERIFICATION_AUTO )
goto :_GENERATE_LIST_AUTO
set /A "_COUNTER=!_COUNTER!+1"
set "_NUM_VAR=000!_COUNTER!"
set "SHELF=!_NUM_VAR:~-2!"
if /I !_COUNTER! GTR !E_SHELF! ( )
for /f "" %%a in ( )

:capture
::goto :debug_ip
ECHO capture !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
:_network_adapter
ECHO _selected_network !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
if defined _interface_numb goto :_IP_CAPTURE
for /f %%a in ('getmac /NH /v ^| Find /c "{" ') do set "_number=%%a"
if %_number% equ 1 ( for /f "tokens=2 delims={}" %%a in ( 'getmac /NH /v ^| find "{" ' ) do set "_selected_network=%%a" 
			goto :_interface_numb )
set "count_tokens=1"
:_set_adapter_op
for /f "tokens=%count_tokens% delims=}" %%a in ('getmac /NH /v ^| find "{" ') do (
set "op_%count_tokens%=%%a"
)
if !count_tokens! equ %_number% goto :_Choose_adapter
set /a "count_tokens=%count_tokens%+1"
goto :_set_adapter_op
:_Choose_adapter
    ECHO +===============================::===============================+
    ECHO + Choose the network adapter that is connected to the same       +
	echo + network as the machines you want to connect                    +
    ECHO +===============================::===============================+
	echo.
	echo 1- !op_1!
if %_number% GEQ 2 (
	echo 2- !op_2! )
if %_number% GEQ 3 (
	echo 3- !op_3!)
if %_number% GEQ 4 (
	echo 4- !op_4! )
if %_number% GEQ 5 (
	echo 5- !op_5! )
if %_number% GEQ 6 (
	echo 6- !op_6! )
if %_number% GEQ 7 (
	echo 7- !op_7! )
if %_number% GEQ 8 (
	echo 8- !op_8! )	
if %_number% GEQ 9 (
	echo 9- !op_9! )	
if %_number% GEQ 10 (
	echo 10- !op_10! )	
	::
echo.
set /p _Choose=:
	::
if !_Choose! equ 1 (
set "op_=!op_1!" )
if !_Choose! equ 2 (
set "op_=!op_2!" )
if !_Choose! equ 3 (
set "op_=!op_3!" )
if !_Choose! equ 4 (
set "op_=!op_4!" )
if !_Choose! equ 5 (
set "op_=!op_5!" )
if !_Choose! equ 6 (
set "op_=!op_6!" )
if !_Choose! equ 7 (
set "op_=!op_7!" )
if !_Choose! equ 8 (
set "op_=!op_8!" )
if !_Choose! equ 9 (
set "op_=!op_9!" )
if !_Choose! equ 10 (
set "op_=!op_10!" )
	::
goto :_define_id
	::
:_define_id
	::
for /f "tokens=2 delims={}" %%a in ( "!op_!" ) do ( set "_selected_network=%%a" 
	goto :_interface_numb 
	)
	::
:_interface_numb
for /f "delims=." %%g in ( '._plugin\WinDump.exe -D ^| find "!_selected_network!"' ) do (
set "_interface_numb=%%g"
)
if not defined _interface_numb goto :_network_adapter

ECHO _selected_network !_selected_network! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
:_IP_CAPTURE
ECHO _IP_CAPTURE ON !_selected_network! !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
CLS
	echo.
	echo nome !COMPANY!-MODELO-!coin!-!_HALL!-!SHELF!-!LETTER!!NUMBER!
	echo.
    ECHO +===============================::===============================+
    ECHO +                 Press the ip button on ASIC                    +
    ECHO +===============================::===============================+
._plugin\WinDump.exe -i!_interface_numb! -c1 -n udp port 14235 > ._LOG\ipcapture.txt 2>&1
::
:_set_IP
for /f "delims='P''>' tokens=2" %%a in ('type ._log\ipcapture.txt ^| find "UDP"' ) do ( set "_Brute_ip=%%a" 
)
for /f "delims=. tokens=1-4" %%a in ( "!_Brute_ip!" ) do (
set "ASIC_IP=%%a.%%b.%%c.%%d"
set "ASIC_IP=!ASIC_IP: =!"
)
if exist ._log\ipcapture.txt del ._log\\ipcapture.txt
ECHO _IP_CAPTURE CAPTURE IP !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
goto :eof
 
::
:_ASIC_CONFIG_NOW
::
cls
ECHO _ASIC_CONFIG_NOW  !ASIC_IP! !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
	echo.
	echo nome !_ASIC_NAME! - ip !ASIC_IP! - workname !_Workname! ID !_ASIC_ID!
	echo.
    ECHO +===============================::===============================+
    ECHO +                Gerando arquivo de coniguracao                  +
    ECHO +===============================::===============================+
	echo.
ECHO _ASIC_CONFIG_NOW CREATE CONFIG FILE !ASIC_IP! !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
bash -c "mkdir -p /config" > NUL 2>&1
BASH -c "touch /config/network.conf && touch /config/!NAME_CONF!" > NUL 2>&1
BASH -c "rm /config/* && touch /config/network.conf && touch /config/!NAME_CONF! && echo -e '{\n\"pools\" : [\n{\n\"url\" : \"!pool1!\",\n\"user\" : \"!poolacout!.!_Workname!\",\n\"pass\" : \"!poolpass!\"\n},\n{\n\"url\" : \"!pool2!\",\n\"user\" : \"!poolacout!.!_Workname!\",\n\"pass\" : \"!poolpass!\"\n},\n{\n\"url\" : \"!pool3!\",\n\"user\" : \"!poolacout!.!_Workname!\",\n\"pass\" : \"!poolpass!\"\n}\n]\n,\n\"api-listen\" : true,\n\"api-network\" : true,\n\"api-groups\" : \"A:stats:pools:devs:summary:version:noncenum\",\n\"api-allow\" : \"A:0/0,W:*\",\n\"bitmain-use-vil\" : true,\n\"bitmain-freq\" : \"!Freq!\",\n!S9-voltage!\"multi-version\" : \"1\"\n}' > /config/!NAME_CONF! && echo -e 'hostname=!_ASIC_NAME!\ndhcp=true' >  /config/network.conf"
ECHO _ASIC_CONFIG_NOW CREATE CONFIG FILE !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
::
:_GET_ASIC_CONFIG
ECHO _GET_ASIC_CONFIG !ASIC_IP! !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
set "sucess="
set "errosshcont="
::
set "password=!defaut_password!"
	echo.
    ECHO +===============================::===============================+
    ECHO +               Enjetando arquivos de configuracao               +
    ECHO +===============================::===============================+
	echo.
:_back_to_black
BASH -c "sshpass -p  !password! scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /config/*  root@!ASIC_IP!:/config/" > NUL 2>&1
::echo =============================================================================================== >> !_LOG! 
::ECHO _back_to_black DESCOMENTAR A LINHA 1352 !ASIC_IP! !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
::echo =============================================================================================== >> !_LOG! 
::
IF %ERRORLEVEL% NEQ 0 (
	ECHO _GET_ASIC_CONFIG erro !ASIC_IP! !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
	set "errosshcont=!errosshcont!+1"
	ECHO _GET_ASIC_CONFIG erro !errosshcont! !ASIC_IP! !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
	if !errosshcont! equ 1 (
		SET "password=!new_password!" )
	if !errosshcont! equ 2 (1
		set  "password=!new_old_password!" )
	if !errosshcont! equ 3 (
		color 04
		goto :errorssh )
	goto :_back_to_black )
ECHO _ASIC_CONFIG_NOW !errosshcont! !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
::
BASH -c "sshpass -p !password! ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@!ASIC_IP! 'chmod 400 /config/bmminer.conf && chmod 400 /config/network.conf'" > NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
	goto :errorssh )
ECHO _GET_ASIC_CONFIG CHMOD !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!

IF !password! NEQ !new_password! (
call :CHANGE_PASS )	
::
ECHO REBOOT !ASIC_IP! !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
	echo.
    ECHO +===============================::===============================+
    ECHO +                       Reiniciando maquina                      +
    ECHO +===============================::===============================+
	echo.
BASH -c "sshpass -p !new_password! ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@!ASIC_IP! '/sbin/reboot'"  > NUL 2>&1
ECHO REBOOT !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
::
set "sucess=1"
ECHO nome !_ASIC_NAME! - ip !ASIC_IP! - workname !_Workname! !_DATA_GENERAL! configured TIME SUCESSO = !sucess! !TIME! >> !_LOG!
goto :eof
::
:_register
::
set "pool1="
set "pool2="
set "pool3="
set "poolacout="
set "poolpass="
set "coin="
set "model="
set "Freq="
set "NAME_CONF="
set "S9-voltage="
if !sucess! neq 1 (
	echo.
    ECHO +===============================::===============================+
    ECHO +           A MAQUINA NAO FOI CONFIGURADA COM SUCESSO            +
	ECHO +                   POR FAVOR REPITA O PROCESSO                  +
    ECHO +===============================::===============================+
	echo. 
	GOTO :_select_mod )
	echo.
    ECHO +===============================::===============================+
    ECHO +                         Registrando log                        +
    ECHO +===============================::===============================+
	echo.
if not defined _ASIC_ID (
call :_ASIC_ID )
if not exist ._log/.ASIC_REGISTER.txt (
	ECHO !_ASIC_NAME! !_Workname! !ASIC_IP! !_ASIC_ID! !_DATA_GENERAL! !_LOG! ;>>._log/.ASIC_REGISTER.txt 
	ECHO REGISTERED; !_ASIC_NAME! !_Workname! !ASIC_IP! !_ASIC_ID! !_DATA_GENERAL! !_LOG! ;;>>._log/.ASIC_LOG.txt 
	echo. 
	GOTO :EOF
	)
::
if exist ._log/.ASIC_REGISTER.txt (
	IF defined ASIC_QUERY (
		if !ASIC_QUERY! EQU DO_ID	(
			echo.
			ECHO ASIC_ID_CHANGED !query_name! !_ASIC_NAME! BEGINNING TIME !TIME! >> !_LOG!
			ECHO ASIC_ID_CHANGED; !old_line! !_ASIC_NAME! !_Workname! !ASIC_IP! !_ASIC_ID! !_DATA_GENERAL! !_LOG! ;>>._log/.ASIC_LOG.txt
			SET "new_line=!_ASIC_NAME! !_Workname! !ASIC_IP! !_ASIC_ID! !_DATA_GENERAL! !_LOG!"
			call :_change_word
			set "ASIC_REGISTER=CHANGED"
			echo.)
		if !ASIC_QUERY! EQU DO_NAME (
			echo.
			ECHO ASIC_NAME_CHANGED !query_name! BEGINNING TIME !TIME! >> !_LOG!
			ECHO ASIC_NAME_CHANGED; !old_line! !_ASIC_NAME! !_Workname! !ASIC_IP! !_ASIC_ID! !_DATA_GENERAL! !_LOG! ;>>._log/.ASIC_LOG.txt
			SET "new_line=!_ASIC_NAME! !_Workname! !ASIC_IP! !_ASIC_ID! !_DATA_GENERAL! !_LOG!"
			call :_change_word
			set "ASIC_REGISTER=CHANGED"
			echo. ))
	IF NOT DEFINED ASIC_QUERY (
		IF NOT DEFINED ASIC_REGISTER (
			ECHO !_ASIC_NAME! !_Workname! !ASIC_IP! !_ASIC_ID! !_DATA_GENERAL! !_LOG! ;>>._log/.ASIC_REGISTER.txt 
			SET "new_line=!_ASIC_NAME! !_Workname! !ASIC_IP! !_ASIC_ID! !_DATA_GENERAL! !_LOG!"
			ECHO REGISTERED; !_ASIC_NAME! !_Workname! !ASIC_IP! !_ASIC_ID! !_DATA_GENERAL! !_LOG! ;;>>._log/.ASIC_LOG.txt 
			echo. ))
)
::
goto :eof
:_change_word
::
IF DEFINED new_line (
	type ._LOG\.ASIC_REGISTER.txt | find /V "!_ASIC_NAME!"> ._LOG\._REGISTER.txt
	del "._LOG\.ASIC_REGISTER.txt"
	ren ._LOG\._REGISTER.txt .ASIC_REGISTER.txt
	type ._LOG\.ASIC_REGISTER.txt | find /V  "!_ASIC_ID!"> ._LOG\._REGISTER.txt
	del "._LOG\.ASIC_REGISTER.txt"
	ren ._LOG\._REGISTER.txt .ASIC_REGISTER.txt
	echo %new_line% ;>> ._LOG\.ASIC_REGISTER.txt
	if exist ._LOG\._REGISTER.txt del "._LOG\._REGISTER.txt
	echo. )
goto :eof
::
:_Query_register
::
ECHO "_Query_register !_ASIC_NAME! !_Workname! !ASIC_IP! !_ASIC_ID! !_DATA_GENERAL! BEGINNING TIME !TIME!" >> !_LOG!
	echo.
    ECHO +===============================::===============================+
    ECHO +                      Verificando Registro                      +
    ECHO +===============================::===============================+
	echo.
if NOT exist ._log/.ASIC_REGISTER.txt (
	ECHO _Query_register  NOT EXIST ._log/.ASIC_REGISTER.txt !TIME! >> !_LOG! 
)
if exist ._log/.ASIC_REGISTER.txt (
	echo.
	FOR /F "tokens=1-6" %%a in ( 'type ._log\.ASIC_REGISTER.txt ^| find "!_ASIC_NAME!"' ) do (
		echo.
		set "query_name=%%a" 
		set "query_work=%%b"
		set "query_ip=%%c"
		set "query_iD=%%d"
		set "query_data=%%e"
		set "query_log=%%f"
		echo.
		set "old_line=!query_name! !query_work! !query_ip! !query_iD! !query_data! !query_log! ;"
		)
	if defined query_name (
		if !query_iD! NEQ !_ASIC_ID! (
			echo.
			echo.
			ECHO "_Query_register !query_iD! BEGINNING TIME !TIME!" >> !_LOG!
			set "confirm_messenger=Ja existe uma maquina com esse nome registrada, deseja prosseguir?"
			set "ASIC_QUERY=DO_ID"
			echo. ))
	set "query_name="
	set "query_iD="
	FOR /F "tokens=1-6" %%a in ( 'type ._log\.ASIC_REGISTER.txt ^| find "!_ASIC_ID!"' ) do (
		echo.
		set "query_name=%%a" 
		set "query_work=%%b"
		set "query_ip=%%c"
		set "query_iD=%%d"
		set "query_data=%%e"
		set "query_log=%%f"
		echo.
		set "old_line=!query_name! !query_work! !query_ip! !query_iD! !query_data! !query_log! ;"
		)
	if defined query_iD (
		if !query_name! NEQ !_ASIC_NAME! (
			echo.
			ECHO "_Query_register !query_name! BEGINNING TIME !TIME!" >> !_LOG!
			set "confirm_messenger=   Renomear !query_name! para !_ASIC_NAME!?   "     
			echo. 
			set "ASIC_QUERY=DO_NAME"
			echo. ))
)

ECHO _Query_register !confirm_messenger! ENDING TIME !TIME! >> !_LOG!
goto :eof
:_Exit_ini
echo See you later
timeout 3 > NUL 2>&1 
exit 

:errorssh
	ECHO +===============================::===============================+
	ECHO +                ERRO AO TENTAR ACESSAR A MAQUINA                +
	ECHO +===============================::===============================+
	echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::
	echo :'########:'########::'########:::'#######::'########::
	echo : ##.....:: ##.... ##: ##.... ##:'##.... ##: ##.... ##:
	echo : ##::::::: ##:::: ##: ##:::: ##: ##:::: ##: ##:::: ##:
	echo : ######::: ########:: ########:: ##:::: ##: ########::
	echo : ##...:::: ##.. ##::: ##.. ##::: ##:::: ##: ##.. ##:::
	echo : ##::::::: ##::. ##:: ##::. ##:: ##:::: ##: ##::. ##::
	echo : ########: ##:::. ##: ##:::. ##:. #######:: ##:::. ##:
	echo ........::..:::::..::..:::::..:::.......:::..:::::..::
	echo.
	pause > nul 2>&1
	color 07
	goto :_select_mod 
	
:debug_ip
echo debugip
set /p "ASIC_IP="
echo =============================================================================================== >> !_LOG! 
ECHO ------------- NAO ESQUE?A DE COMENTAR A LINHA ABAIXO DE :CAPTURE ENDING TIME !TIME! ---------- >> !_LOG! 
echo =============================================================================================== >> !_LOG! 
goto :eof

:CHANGE_PASS 

ECHO CHANGE_PASS 0-6 !ASIC_IP! !_DATA_GENERAL! BEGINNING TIME !TIME! >> !_LOG!
echo.
eCHO +===============================::===============================+
ECHO +                     Trocando senha padrao                      +
ECHO +===============================::===============================+
echo.
BASH -c "._Plugin/passwdl.bash root !defaut_password! !ASIC_IP! !new_password!"
ECHO CHANGE_PASS 1-6 !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
for /f %%a in ( 'bash -c "echo -n \"root:antMiner Configuration:!new_password!\" | md5sum | cut -b -32"' ) do (
	set "hash=%%a")
ECHO CHANGE_PASS 2-6 !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
bash -c "touch /config/lighttpd-htdigest.user"
ECHO CHANGE_PASS 3-6 !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
bash -c "echo -n \"root:antMiner Configuration:!hash!\" > /config/lighttpd-htdigest.user"
ECHO CHANGE_PASS 4-6 !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
BASH -c "sshpass -p  !new_password! scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /config/lighttpd-htdigest.user  root@!ASIC_IP!:/config/lighttpd-htdigest.user"
ECHO CHANGE_PASS 5-6 !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
BASH -c "sshpass -p root ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@!ASIC_IP! 'rm -f /config/shadow && mv /etc/shadow /config/shadow && ln -s /config/shadow /etc/shadow'"
ECHO CHANGE_PASS 6-6 !ASIC_IP! !_DATA_GENERAL! ENDING TIME !TIME! >> !_LOG!
goto :eof
::
::
::Peguei o codigo do Stackoverflow
::
::#############################################################################
::_typeWriter <stringVariable> <skipLinefeed>
::#############################################################################
::
:: Copyleft Denny Lenselink 2018
::
:typewriter
CLS
%= Set local environment =%
( call ) & 2>nul setlocal EnableDelayedExpansion || exit /b 99

:: Set vars
set "_CNT=0" && set "_LEN=0" && set "_STR= %Build%" && set "_TOT=0"

:_typeWriter_Loop
set /a "_CNT+=1"

:: 31 tokens limit fix. Cut the used part of the string and set counter to 1
if !_CNT! equ 32 ( set "_CNT=1" && set "_STR=!_STR:~%_TOT%!" && set "_TOT=0" )

:: Go through string (seeking words)
for /f "tokens=%_CNT% delims=," %%* in ( "%_STR%" ) do (

    :: Set word var
    set "_WRD=#%%*"

    :: Calculate word length
    for /l %%I in ( 12, -1, 0 ) do (

        set /a "_LEN|=1<<%%I"

        for %%J in ( !_LEN! ) do ( if "!_WRD:~%%J,1!"=="" set /a "_LEN&=~1<<%%I" )
    )

    :: Strip first char (used before to calculate correct word length)
    set "_WRD=!_WRD:~1!"

    :: Count chars including spaces
    set /a "_TOT=!_TOT!+!_LEN!+1"

    :: Type word or use echo
    echo !_WRD!

    :: Do a loop
    goto _typeWriter_Loop
)

:: No linefeed when specified
if "%~2"=="" echo.

endlocal
goto :eof