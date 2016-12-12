::@echo off
:: ---------------------------------------------------------------------
:: Searches for Java executable
:: %* optional: any additional directories for JVM discovery 
:: !!! it's assumed script is called from directory where it is located.
:: ---------------------------------------------------------------------
SET TEAMCITY_FIND_JAVA=%~dpnx0

:: it is not possible to use ( or ) without a risk to have 
:: unexpected script behavior if arguments/variables contains ( or )
:: here we implement recustive calls to the script itself 
:: in order to resolve the issue
::
:: to make recursive call we expect first parameter to be
:: equal to _CLOSURE_, the second parameters is checked
:: in the sequece of IF NOT statements to find the right
:: branch to execute
::
:: We specify TEAMCITY_JAVA_FOUND=Yes to mark Java found 
IF NOT [%1] == [_CLOSURE_] GOTO java_search_normal

IF NOT "%2" == "RESET" GOTO java_closure_reset_end
  SET JAVA_HOME=
  SET JAVA_EXE=
  SET JRE_HOME=
  goto end
:java_closure_reset_end

::check if result already found
IF NOT "%TEAMCITY_JAVA_FOUND%" == "" GOTO end

IF NOT "%2" == "REG_JDK" GOTO java_closure_reg_jdk_end
  IF NOT EXIST "%~df3\bin\java.exe" GOTO end
  IF NOT EXIST "%~df3\bin\javac.exe" GOTO end

  SET TEAMCITY_JAVA_FOUND=Yes
  SET JAVA_HOME=%~df3
  SET JAVA_EXE=%~df3\bin\java.exe
  GOTO end
:java_closure_reg_jdk_end

IF NOT "%2" == "REG_JRE" GOTO java_closure_reg_jre_end
  IF NOT EXIST "%~df3\bin\java.exe" GOTO end 

  SET TEAMCITY_JAVA_FOUND=Yes
  SET JAVA_HOME=%~df3
  SET JAVA_EXE=%~df3\bin\java.exe
  GOTO end
:java_closure_reg_jre_end

IF NOT "%2" == "REG_JDK_2" GOTO java_closure_reg_jdk_2_end
  ECHO Checking Registry 'HKLM\Software%3JavaSoft\Java Development Kit\%4' for JDK
  FOR /F "tokens=2*" %%A IN ('REG QUERY "HKLM\Software%3JavaSoft\Java Development Kit\%4" /v JavaHome 2^> NUL ^| find "JavaHome"') DO CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ REG_JDK "%%B"
  GOTO end
:java_closure_reg_jdk_2_end

IF NOT "%2" == "REG_JRE_2" GOTO java_closure_reg_jre_2_end
  ECHO Checking Registry 'HKLM\Software%3JavaSoft\Java Development Kit\%4' for JRE
  FOR /F "tokens=2*" %%A IN ('REG QUERY "HKLM\Software%3JavaSoft\Java Development Kit\%4" /v JavaHome 2^> NUL ^| find "JavaHome"') DO CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ REG_JRE "%%B"
  GOTO end
:java_closure_reg_jre_2_end

IF NOT "%2" == "REG_SCAN" GOTO java_closure_reg_scan_end
  :: TODO consider bitness of environment to find x86 java first.
  :: on x64 machine, x64 java would be considered first
  FOR %%W IN (\ \WOW6432Node\) DO FOR %%V IN (1.8 1.7 1.6) DO CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ REG_JDK_2 %%W %%V
  FOR %%W IN (\ \WOW6432Node\) DO FOR %%V IN (1.8 1.7 1.6) DO CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ REG_JRE_2 %%W %%V
  GOTO end
:java_closure_reg_scan_end

IF NOT "%2" == "CHECK_DIR" GOTO java_closure_check_dir_end
  CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ REG_JDK "%~df3"
  CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ REG_JRE "%~df3"
  GOTO end
:java_closure_check_dir_end

IF NOT "%2" == "SCAN_DIRS" GOTO java_closure_scan_dirs_end
  ECHO Check directory '%~df3'
  CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ CHECK_DIR "%~df3"
  IF NOT "%TEAMCITY_JAVA_FOUND%" == "" GOTO end
  
  ECHO Scanning nested directories of '%~df3'
  FOR /F "tokens=*" %%i in ('dir "%~df3" /X /B /O:-D /A:D 2^> NUL') DO CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ CHECK_DIR "%~df3\%%i"
  IF NOT "%TEAMCITY_JAVA_FOUND%" == "" GOTO end

  GOTO end
:java_closure_scan_dirs_end

::closure loop finished, nothing matched/completed, thus make script finish
GOTO end

:java_search_normal

::script is called recursively, thus it's necessary to recall initial arguments once it started first time
SET ALL_ARGS=%*

SET TEAMCITY_JAVA_FOUND=

SET JAVA_EXE=%TEAMCITY_JRE%\bin\java.exe
IF NOT EXIST "%JAVA_EXE%" GOTO java_check_1 
ECHO Java found using TEAMCITY_JRE environment variable.
SET "JRE_HOME=%TEAMCITY_JRE%"
goto java_found
:java_check_1

SET JAVA_EXE=%JRE_HOME%\bin\java.exe
IF NOT EXIST "%JAVA_EXE%" GOTO java_check_2
ECHO Java found using JRE_HOME environment variable.
goto java_found
:java_check_2

SET JAVA_EXE=%JAVA_HOME%\jre\bin\java.exe
IF NOT EXIST "%JAVA_EXE%" GOTO java_check_3
ECHO Java found using JAVA_HOME environment variable.
SET "JRE_HOME=%JAVA_HOME%\jre"
goto java_found
:java_check_3

SET JAVA_EXE=%JAVA_HOME%\bin\java.exe
IF NOT EXIST "%JAVA_EXE%" GOTO java_check_4
ECHO Java found using JRE_HOME environment variable.
SET "JRE_HOME=%JAVA_HOME%"
goto java_found
:java_check_4

SET JAVA_EXE=%TEAMCITY_HOME_DIR%\jre\bin\java.exe
IF NOT EXIST "%JAVA_EXE%" GOTO java_check_5
echo Java found using TEAMCITY_HOME_DIR environment variable.
SET "JRE_HOME=%TEAMCITY_HOME_DIR%\jre"
goto java_found
:java_check_5

:scan_registry
:: ---------------------------------------------------------------------
:: Scan Registry for Java's records
:: ---------------------------------------------------------------------
:: first look for JDK/JRE as it may provide -server support

CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ REG_SCAN
IF NOT "%TEAMCITY_JAVA_FOUND%" == "" GOTO java_found


:: ---------------------------------------------------------------------
:: Search for JDK/JRE in Windows default places
:: ---------------------------------------------------------------------

IF NOT EXIST "%ProgramFiles%" GOTO java_programfiles_86_end
  CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ SCAN_DIRS "%ProgramFiles%\Java"
  IF NOT "%TEAMCITY_JAVA_FOUND%" == "" GOTO java_found
:java_programfiles_86_end

IF NOT EXIST "%ProgramW6432%" GOTO java_programfiles_64_end
  CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ SCAN_DIRS "%ProgramW6432%\Java"
  IF NOT "%TEAMCITY_JAVA_FOUND%" == "" GOTO java_found
:java_programfiles_64_end

:: ---------------------------------------------------------------------
:: Search for JDK/JRE in directories passed as parameter of the script
:: ---------------------------------------------------------------------

:java_scan_arguments
 IF [%1] == [] GOTO java_scan_arguments_end
 CALL "%TEAMCITY_FIND_JAVA%" _CLOSURE_ SCAN_DIRS "%~df1"
 IF NOT "%TEAMCITY_JAVA_FOUND%" == "" GOTO java_found
 SHIFT
 GOTO java_scan_arguments
:java_scan_arguments_end
         
:: ---------------------------------------------------------------------
:: Trying to run java from the PATH
:: ---------------------------------------------------------------------
java>NUL 2>&1

IF ERRORLEVEL 2 GOTO java_ping_failed
SET JAVA_EXE=java
GOTO java_found
:java_ping_failed

:java_not_found
:: Report 'no Java found'

ECHO Java executable is not found:
ECHO - Neither the JAVA_HOME nor the JRE_HOME environment variable is defined
ECHO - Java executable is not found in the directories listed in the PATH environment variable
ECHO - Path to JVM is not found in Windows Registry.
ECHO - Java executable is not found in the default locations
IF [%ALL_ARGS%] == [] GOTO skip_dump_all_args
ECHO - Java executable is not found under predefined '%ALL_ARGS%' directories
:skip_dump_all_args
ECHO.
ECHO Please make sure one of the environment variables is defined and is pointing to valid Java (JRE) installation, then run again
ECHO.

SET ALL_ARGS=
SET TEAMCITY_JAVA_FOUND=
SET TEAMCITY_FIND_JAVA=
EXIT /B 2

:java_found
SET ALL_ARGS=
SET TEAMCITY_JAVA_FOUND=
SET TEAMCITY_FIND_JAVA=
ECHO Java executable is found: '%JAVA_EXE%'.

EXIT /B 0

:end
