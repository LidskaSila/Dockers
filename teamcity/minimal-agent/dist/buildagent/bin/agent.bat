@echo off
:: ---------------------------------------------------------------------
:: TeamCity build agent start/stop script
:: ---------------------------------------------------------------------
:: Environment variables:
::
:: TEAMCITY_AGENT_MEM_OPTS   Set agent memory options (JVM options)
::
:: TEAMCITY_AGENT_OPTS       Set additional agent JVM options
::
:: TEAMCITY_LAUNCHER_OPTS    Set agent launcher JVM options
::
:: TEAMCITY_AGENT_PREPARE_SCRIPT    name of a script to execute before start/stop
::
:: ---------------------------------------------------------------------

SET TEAMCITY_AGENT_CURRENT_DIR=%CD%
cd /d %~dp0

IF not "%TEAMCITY_AGENT_CONFIG_FILE%" == "" goto config_file_set
SET TEAMCITY_AGENT_CONFIG_FILE=..\conf\buildAgent.properties

:config_file_set
IF not "%TEAMCITY_AGENT_LOG_DIR%" == "" goto log_dir_set
SET TEAMCITY_AGENT_LOG_DIR=../logs/

:log_dir_set
IF not "%TEAMCITY_AGENT_MEM_OPTS%" == "" goto agent_mem_opts_set
SET TEAMCITY_AGENT_MEM_OPTS_ACTUAL=-Xmx384m
:: uncomment for debugging OOM errors:
:: SET TEAMCITY_AGENT_MEM_OPTS_ACTUAL=-Xmx384m -XX:+HeapDumpOnOutOfMemoryError
goto agent_mem_opts_set_done

:agent_mem_opts_set
SET TEAMCITY_AGENT_MEM_OPTS_ACTUAL=%TEAMCITY_AGENT_MEM_OPTS%

:agent_mem_opts_set_done
SET TEAMCITY_AGENT_OPTS_ACTUAL=%TEAMCITY_AGENT_OPTS% -ea %TEAMCITY_AGENT_MEM_OPTS_ACTUAL% -Dlog4j.configuration=file:../conf/teamcity-agent-log4j.xml -Dteamcity_logs=%TEAMCITY_AGENT_LOG_DIR%
SET TEAMCITY_LAUNCHER_OPTS_ACTUAL=%TEAMCITY_LAUNCHER_OPTS% -ea

ECHO Looking for installed Java...
if exist ..\jre SET JRE_HOME=%cd%\..\jre
if exist ..\..\jre SET JRE_HOME=%cd%\..\..\jre
CALL "%cd%\findJava.bat" "%cd%\..\jre" "%cd%\..\..\jre"
IF NOT ERRORLEVEL 1 GOTO java_search_done
ECHO Java not found. Cannot start TeamCity agent. Please ensure JDK or JRE is installed and JAVA_HOME environment variable points to it.
GOTO done
:java_search_done

:run
set TEAMCITY_LAUNCHER_CLASSPATH=..\launcher\lib\launcher.jar

if EXIST ..\lib\latest\launcher.jar set TEAMCITY_LAUNCHER_CLASSPATH = ..\lib\latest\launcher.jar

if "%TEAMCITY_AGENT_PREPARE_SCRIPT%" == "" goto skip_prepare
call "%TEAMCITY_AGENT_PREPARE_SCRIPT%" %*
:skip_prepare

IF ""%1"" == ""start"" goto start
IF ""%1"" == ""stop"" goto stop
IF ""%1"" == ""status"" goto status
IF ""%1"" == ""configure"" goto configure


echo Error parsing command line.
echo ----------------------------------------
echo Usage: agent.bat start or agent.bat stop[ force]
echo start      - starts the agent in new console window
echo stop       - stops the agent after the currently running build (if any) is finished
echo stop force - stops the agent cancelling the build
echo ----------------------------------------
goto done

:start

IF EXIST ..\lib\latest\launcher.jar goto start_upgrade
goto start_run
:start_upgrade

del /Q ..\lib\launcher.jar
move ..\lib\latest\launcher.jar ..\lib\launcher.jar

:start_run
"%JAVA_EXE%" %TEAMCITY_LAUNCHER_OPTS_ACTUAL% -cp %TEAMCITY_LAUNCHER_CLASSPATH% jetbrains.buildServer.agent.Check %TEAMCITY_AGENT_OPTS_ACTUAL% jetbrains.buildServer.agent.AgentMain -file %TEAMCITY_AGENT_CONFIG_FILE%
IF ERRORLEVEL 1 goto done
start "TeamCity Build Agent" "%JAVA_EXE%" %TEAMCITY_LAUNCHER_OPTS_ACTUAL% -cp %TEAMCITY_LAUNCHER_CLASSPATH% jetbrains.buildServer.agent.Launcher %TEAMCITY_AGENT_OPTS_ACTUAL% jetbrains.buildServer.agent.AgentMain -file %TEAMCITY_AGENT_CONFIG_FILE%
goto done

:stop
"%JAVA_EXE%" %TEAMCITY_LAUNCHER_OPTS_ACTUAL% -cp %TEAMCITY_LAUNCHER_CLASSPATH% jetbrains.buildServer.agent.Stop %TEAMCITY_AGENT_OPTS_ACTUAL% -file %TEAMCITY_AGENT_CONFIG_FILE% %2
goto done

:status
"%JAVA_EXE%" %TEAMCITY_LAUNCHER_OPTS_ACTUAL% -cp %TEAMCITY_LAUNCHER_CLASSPATH% jetbrains.buildServer.agent.Status %TEAMCITY_AGENT_OPTS_ACTUAL% -file %TEAMCITY_AGENT_CONFIG_FILE% %2
goto done

:configure
set TEAMCITY_CONFIGURATOR_JAR=..\lib\agent-configurator.jar
"%JAVA_EXE%" %TEAMCITY_LAUNCHER_OPTS_ACTUAL% -jar %TEAMCITY_CONFIGURATOR_JAR% %* --agent-config-file %TEAMCITY_AGENT_CONFIG_FILE%
goto done

:done

cd /d %TEAMCITY_AGENT_CURRENT_DIR%
