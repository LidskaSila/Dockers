:: ---------------------------------------------------------------------
:: TeamCity build agent automatic installation script
:: ---------------------------------------------------------------------
:: Usage: install.bat <TC_Server_URL> <path_to_install_into> (authorization_token|-1) [<Service_running_account> [<Account_password>]]
::
:: %1 required: TeamCity Server root URL
:: %2 required: Agent Install location 
:: %3 required: Authorization token. Must be "-1" if no auto registration required
:: %4 optional: Windows Service account
:: %5 optional: Account password
:: ---------------------------------------------------------------------
@ECHO OFF

:: Check second parameter and set target to folder if exists
SET SERVER_URL=%1%
SET AGENT_INSTALLATION_HOME=%2%
SET AGENT_AUTHORIZATION_TOKEN=%3%
SET AGENT_SERVICE_ACCOUNT=%4%
SET AGENT_SERVICE_ACCOUNT_PASSWORD=%5%

:: Remove superfluous quotations if exists
FOR /F "tokens=*" %%i in ("%AGENT_INSTALLATION_HOME%") do set AGENT_INSTALLATION_HOME=%%~i

ECHO Agent installation is executing on '%COMPUTERNAME%'...
ECHO Current directory: '%cd%'
systeminfo | find /I "System type"

SET TEAMCITY_JAVA_INSTALL_PATH=%AGENT_INSTALLATION_HOME%\jre
:: Check there is an installed JRE and break installation if not so
:checking_java
  ECHO Looking for installed JRE...
  CALL bin\findJava.bat "%TEAMCITY_JAVA_INSTALL_PATH%" 
  IF ERRORLEVEL 1 (
    ECHO Warning: No installed JRE found.
    goto download_jre
  )
  ECHO Installed JRE found.
  GOTO checking_agent_installation

:download_jre
  SET ERRORLEVEL=
  CALL bin\installJava.bat %SERVER_URL%/update "%TEAMCITY_JAVA_INSTALL_PATH%"
  IF "%ERRORLEVEL%"=="0" GOTO checking_java 
  ECHO Could not install neither JDK nor JRE. Terminating[%ERRORLEVEL%] 
  SET ERRORLEVEL=1
  GOTO end
       
:checking_agent_installation
  SET ERRORLEVEL=
  :: Check if the agent is already installed in the path
  ECHO Looking for existing agent installation in "%AGENT_INSTALLATION_HOME%"...
  IF EXIST "%AGENT_INSTALLATION_HOME%" (
    IF EXIST "%AGENT_INSTALLATION_HOME%\bin" GOTO uninstall
    GOTO copy_agent_to_target
  )
  GOTO create_target_folder
    
:uninstall
  SET ERRORLEVEL=
  ECHO Found agent installation in "%AGENT_INSTALLATION_HOME%"
  ECHO Uninstalling the Agent...
  CALL bin\uninstall.bat "%AGENT_INSTALLATION_HOME%" LEFT_JRE
  IF "%ERRORLEVEL%"=="0" GOTO create_target_folder
  ECHO Could uninstall the Agent from '%AGENT_INSTALLATION_HOME%'. Terminating[%ERRORLEVEL%] 
  SET ERRORLEVEL=2
  GOTO end

:create_target_folder
    IF NOT EXIST "%AGENT_INSTALLATION_HOME%" (
      MKDIR "%AGENT_INSTALLATION_HOME%"
      IF NOT EXIST "%AGENT_INSTALLATION_HOME%" (
        ECHO Could not create target folder "%AGENT_INSTALLATION_HOME%". Terminating[%ERRORLEVEL%] 
        set ERRORLEVEL=3
        goto end
      ) 
    )
    GOTO copy_agent_to_target

:copy_agent_to_target
    SET ERRORLEVEL=
    ECHO Extracting agent into "%AGENT_INSTALLATION_HOME%"...
    :: copy agent to installation
    xcopy . "%AGENT_INSTALLATION_HOME%" /E /Q /C /Y
    IF "%ERRORLEVEL%"=="0" GOTO patch_startup_scripts
    ECHO Could not extract the Agent. Terminating[%ERRORLEVEL%] 
    set ERRORLEVEL=4
    goto end
    
:patch_startup_scripts
    IF NOT EXIST "%AGENT_INSTALLATION_HOME%\bin\changeAgentProps.bat" (
      ECHO Could not configure the Agent. Terminating[2]
      GOTO end
    )
    ECHO Configuring agent...
    cd /d "%AGENT_INSTALLATION_HOME%\bin"
    copy>NUL /Y ..\conf\buildAgent.dist.properties ..\conf\buildAgent.properties
    SET ERRORLEVEL= 
    CALL changeAgentProps.bat serverUrl %SERVER_URL% "%CD%\..\conf\buildAgent.properties"
    if NOT "%ERRORLEVEL%"=="0" (
      set ERRORLEVEL=5
      goto end
    )
    :: set authorization token if auto registration requested
    IF NOT "%AGENT_AUTHORIZATION_TOKEN%"=="-1" (
      ECHO Use '%AGENT_AUTHORIZATION_TOKEN%' for authorization
      SET ERRORLEVEL=
      ECHO agent.push.auth.key=%AGENT_AUTHORIZATION_TOKEN%>>"%CD%\..\conf\buildAgent.properties" 
      if NOT "%ERRORLEVEL%"=="0" (
        WARNING: Could not set authorization token for the Agent. You have to authorize it via Web UI. 
      )
    ) 
    GOTO install_service

:install_service
    ECHO Installing TeamCity Build Agent Windows Service...
    SET ERRORLEVEL=
    ::Generate unique Service name 
    CALL generateNewServiceName.bat TCBuildAgent
    IF NOT "%ERRORLEVEL%"=="0" (
      ECHO WARNING: No free Service name for the Agent found. Attempt to start as standalone application.
      goto start_agent_standalone 
    )
    ::Patch wrapper's properties if required
    ECHO Use '%NEW_SERVICE_NAME%' as new Windows Service name
    IF NOT "TCBuildAgent"=="%NEW_SERVICE_NAME%" (
      SET ERRORLEVEL=
      CALL changeAgentProps.bat wrapper.ntservice.name "%NEW_SERVICE_NAME%" "%CD%\..\launcher\conf\wrapper.conf"
      CALL changeAgentProps.bat wrapper.ntservice.displayname "TeamCity Build Agent Service [%AGENT_INSTALLATION_HOME%]" "%CD%\..\launcher\conf\wrapper.conf"
      CALL changeAgentProps.bat wrapper.ntservice.description "TeamCity Build Agent Service [Installed into %AGENT_INSTALLATION_HOME%]" "%CD%\..\launcher\conf\wrapper.conf"
      IF NOT "%ERRORLEVEL%"=="0" (
        SET ERRORLEVEL=7
        ECHO WARNING: Could not configure the TeamCity Build Agent Service. Attempt to start as standalone application.
        goto start_agent_standalone 
      )
    )
    ::Install Service
    SET ERRORLEVEL=
    CALL service.install.bat
    IF NOT "%ERRORLEVEL%"=="0" (
      ECHO WARNING: Could not install the TeamCity Build Agent Service. Attempt to start as standalone application.
      GOTO start_agent_standalone
    )
    ::Set running account if required
    IF NOT "%AGENT_SERVICE_ACCOUNT%"=="" (
      ECHO Use '%AGENT_SERVICE_ACCOUNT%' as Service account
      SET ERRORLEVEL=
      IF NOT "%AGENT_SERVICE_ACCOUNT_PASSWORD%"=="" (
        SC config %NEW_SERVICE_NAME% obj= %AGENT_SERVICE_ACCOUNT% password= %AGENT_SERVICE_ACCOUNT_PASSWORD% TYPE= own
      ) ELSE (
        SC config %NEW_SERVICE_NAME% obj= %AGENT_SERVICE_ACCOUNT% TYPE= own
      ) 
      IF NOT "%ERRORLEVEL%"=="0" (
        WARNING: Could not set account for TeamCity Build Agent Service [%NEW_SERVICE_NAME%]. 
      )
    )
    ::Print the Service info
    ECHO New Service configuration info: 
    SC qc %NEW_SERVICE_NAME%    
    GOTO start_agent_service
    
:start_agent_service
    ::set Java for wrapper if required
    IF NOT "%JAVA_EXE%"=="java" (
      ECHO Setup Java for TeamCity Build Agent Service...
      SET ERRORLEVEL=
      CALL changeAgentProps.bat wrapper.java.command "%JAVA_EXE%" "%CD%\..\launcher\conf\wrapper.conf"
      IF NOT "%ERRORLEVEL%"=="0" (
        ECHO Could not configure the TeamCity Build Agent Service. Attempt to start as standalone application.
        goto start_agent_standalone 
      )
    )
    SET ERRORLEVEL=
    CALL service.start.bat
    if "%ERRORLEVEL%"=="0" (
      ECHO TeamCity Build Agent Service installed and started
      GOTO installation_complete
    )
    ECHO Could not start the TeamCity Build Agent Service. Attempt to start as standalone application.
    goto start_agent_standalone 

:start_agent_standalone
    start /i agent.bat start
    ECHO WARNING: The TeamCity Agent installed as standalone application and will not start automatically on machine reboot.
    
:installation_complete
    ECHO Cleaning temporary installation's resources...
    ECHO Successfully installed build agent on '%COMPUTERNAME%' to "%AGENT_INSTALLATION_HOME%"
    GOTO end
    
:end
  EXIT /B %ERRORLEVEL%
 
