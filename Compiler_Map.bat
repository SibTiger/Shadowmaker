:: If incase the user double clicks this script without using proper compiling procedure, and using MS-DOS, stop
::  the script immediately!
IF "%OS%" NEQ "Windows_NT" GOTO :UnsupportedOS
REM ----



CALL :Main %1 "%~2" "%~3" %4
EXIT /B %ERRORLEVEL%
REM -----------------------------------------------------------------
REM =================================================================
REM -----------------------------------------------------------------
REM                         Compiler Map


REM # =============================================================================================
REM # Parameters: [{string} Type] [{string} DirectoryBuildTarget] [{string} DirectoryProjectTarget] [{string} BuildType]
REM # Documentation: This is the main route access.  All operations will be drifted from this function.
REM #  Parameters:
REM #   ACCEPTED LIST:
REM #     Make [Format the project to append to the ZIP standard as specified in the ZDoom Wiki Article]
REM #     Version [Project version]
REM # =============================================================================================
:Main
REM Make sure that a function was actually passed as the first parameter; if not - opt out immediately!
REM    Failure todo so could result into Unforeseen Consequences!
IF "%~1" EQU "" (
    CALL :InsuccifientParameters
) ELSE ( 
    CALL :%1 "%~2" "%~3" %4
)
EXIT /B %ERRORLEVEL%



REM # =============================================================================================
REM # Documentation: This function warns the user that this script started without any parameters and will
REM #   notify the end-user that this script terminate to avoid any Unforeseen Consequences.
REM #
REM # ACHTUNG: If the Host System IS NOT Windows 2000 [NT5.0 - Windows NT] or greater, this function will
REM #   be meaningless as Windows ME and early [DOS - MS-DOS] does NOT support parameter passing!
REM # ===========================================================================================
:InsuccifientParameters
ECHO OFF
REM Flush the terminal
    CLS
REM Output the message
ECHO ^<!^> ERROR ^<!^>
ECHO =====================
ECHO.
ECHO.
ECHO This shell script requires Bootless Star and the Shadowmaker module!
ECHO.

REM Let the user see the message before the window is destroyed
PAUSE

REM End with error
EXIT /B 1



REM # =============================================================================================
REM # Documentation: This method will prompt the user that their OS is incompatible with this script
REM #   This method will only take effect if and only if the user clicks the shell script without
REM #   doing the proper compiling methods.
REM #
REM # ACHTUNG: To avoid spaghetti code, control everything from this function - including the termination
REM # ===========================================================================================
:UnsupportedOS
ECHO OFF
:: Flush the terminal
    CLS
:: Output the message
ECHO ^<!^> ERROR ^<!^>
ECHO =====================
ECHO.
ECHO.
ECHO The host system is incompatible with this script!  You must have a 'Windows_NT' variant in order to run this script!
ECHO Reported host version: %OS%
ECHO.

:: Let the user see the message before the window is destroyed
PAUSE

:: End with error
EXIT /B 255



REM # =============================================================================================
REM # Parameters: - Accepted; but not used -
REM # Documentation: This function specifies the projects initial version ID.  This sets the Version identifier as well as ERRORLEVEL return code.
REM # =============================================================================================
:Version
SET Version=1
EXIT /B %Version%



REM # =============================================================================================
REM # Parameters: [{string} DirectoryBuildTarget] [{string} DirectoryProjectTarget]
REM # Documentation: Make the build; append only the ZIP standard as specified in the ZDoom Wiki article database.
REM #        The project developers must manipulate this section to work with their project!
REM #  Parameters:
REM #   %1 = Directory that will hold all of the resources for the project; this _will_ be compiled with 7z!
REM #        This does contain a trailing slash!  [example: .\Project\Build\]
REM #   %2 = Place contents outside of the resources; readme and other read-able documentation can be placed here.
REM #        This does contain a trailing slash!  [example: .\Project\]
REM #   %3 = Build Type:
REM #        0 = Developmental Build
REM #        1 = Release Build
REM #        2 = Resource Build
REM # =============================================================================================
:Make
SET "DriversNiceTask=Creating Project Build %ProjectNameShort% [Version: %Version%]"
CALL :CompileProject_Display_IncomingTask "%DriversNiceTask%"
REM ----
IF "%3" EQU "0" CALL :Make_ProjectBuilder %~1 || (CALL :Make_Failure& EXIT /B 1)
IF "%3" EQU "1" CALL :Make_ProjectBuilder %~1 || (CALL :Make_Failure& EXIT /B 1)
IF "%3" EQU "2" CALL :Make_ResourceBuilder %~1 || (CALL :Make_Failure& EXIT /B 1)
CALL :CompileProject_DriverLogFooter "%DriversNiceTask%"
EXIT /B 0



REM # =============================================================================================
REM # Parameters: [{string} DirectoryBuildTarget] [{string} DirectoryProjectTarget]
REM # Documentation: Generate the resource archive; this is to be used with GZDoom Builder and play testing within that environment.
REM #  Parameters:
REM #   %1 = Directory that will hold all of the resources for the project; this _will_ be compiled with 7z!
REM #        This does contain a trailing slash!  [example: .\Project\Build\]
REM #   %2 = Place contents outside of the resources; readme and other read-able documentation can be placed here.
REM #        This does contain a trailing slash!  [example: .\Project\]
REM # =============================================================================================
:Make_ResourceBuilder
REM Create the standard archive filesystem
    CALL :Make_ArchiveResourceFilesystem "%~1" || EXIT /B 1
REM Copy data from the SVN Project to the local directory
    CALL :Make_DuplicateResourceAssets "%~1" || EXIT /B 1
EXIT /B 0



REM # =============================================================================================
REM # Parameters: [{string} DirectoryBuildTarget] [{string} DirectoryProjectTarget]
REM # Documentation: Generate the project archive; this is to be used with play testing or to generate a release build.
REM #  Parameters:
REM #   %1 = Directory that will hold all of the resources for the project; this _will_ be compiled with 7z!
REM #        This does contain a trailing slash!  [example: .\Project\Build\]
REM #   %2 = Place contents outside of the resources; readme and other read-able documentation can be placed here.
REM #        This does contain a trailing slash!  [example: .\Project\]
REM # =============================================================================================
:Make_ProjectBuilder
REM Create the standard archive filesystem
    CALL :Make_ArchiveFilesystem "%~1" || EXIT /B 1
REM Copy data from the SVN Project to the local directory
    CALL :Make_DuplicateAssets "%~1" || EXIT /B 1
REM Remove rubbish from Map directory
    CALL :Make_ThrashSuperfluousMapData "%~1" || EXIT /B 1
REM IF: WYSIWYG patch alteration
EXIT /B 0



REM # =============================================================================================
REM # Documentation: This function creates the entire archive filesystem as meet with the ZDoom specifications and standards.
REM # Parameters: [{String} Project Build Path]
REM # =============================================================================================
:Make_ArchiveFilesystem
REM This variable is used to describe the drivers main purpose and present the value in the log files.
CALL :CompileProject_Display_IncomingTaskSubLevel "Creating archive filesystem"
REM ----
REM Decorate
    SET "TaskCaller_CallLong=MKDIR %~1Decorate"
    CALL :CompileProject_TaskOperation || EXIT /B 1
REM Documentations
    SET "TaskCaller_CallLong=MKDIR %~1Documentation"
    CALL :CompileProject_TaskOperation || EXIT /B 1
REM Sounds
    SET "TaskCaller_CallLong=MKDIR %~1Sounds"
    CALL :CompileProject_TaskOperation || EXIT /B 1
REM Maps
    SET "TaskCaller_CallLong=MKDIR %~1Maps"
    CALL :CompileProject_TaskOperation || EXIT /B 1
REM Sprites
    SET "TaskCaller_CallLong=MKDIR %~1Sprites"
    CALL :CompileProject_TaskOperation || EXIT /B 1
REM Textures
    SET "TaskCaller_CallLong=MKDIR %~1Textures"
    CALL :CompileProject_TaskOperation || EXIT /B 1
REM ----
EXIT /B 0



REM # =============================================================================================
REM # Documentation: This function creates the entire resource archive filesystem as meet with the ZDoom specifications and standards.
REM # Parameters: [{String} Project Build Path]
REM # =============================================================================================
:Make_ArchiveResourceFilesystem
REM This variable is used to describe the drivers main purpose and present the value in the log files.
CALL :CompileProject_Display_IncomingTaskSubLevel "Creating resource archive filesystem"
REM ----
REM Decorate
    SET "TaskCaller_CallLong=MKDIR %~1Decorate"
    CALL :CompileProject_TaskOperation || EXIT /B 1
REM Sounds
    SET "TaskCaller_CallLong=MKDIR %~1Sounds"
    CALL :CompileProject_TaskOperation || EXIT /B 1
REM Sprites
    SET "TaskCaller_CallLong=MKDIR %~1Sprites"
    CALL :CompileProject_TaskOperation || EXIT /B 1
REM ----
EXIT /B 0



REM # =============================================================================================
REM # Documentation: This function will duplicate the data from the SVN project into the ZDoom Archive filesystem standards.
REM # Parameters: [{String} Project Build Path]
REM # =============================================================================================
:Make_DuplicateAssets
REM This variable is used to describe the drivers main purpose and present the value in the log files.
CALL :CompileProject_Display_IncomingTaskSubLevel "Duplicate the data from local host repo into the local directory"
REM ----
REM Duplicate the following:
REM Documentations
        REM Because we need recursive; use XCopy to duplicate subdirectories.
    SET TaskCaller_CallLong=XCOPY %XCopyArg% /E "%UserConfig.DirProjectWorkingCopy%\Documents\*" "%~1Documentation\"
    CALL :CompileProject_TaskOperation
REM Textures
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Textures\*.*" "%~1Textures\"
    CALL :CompileProject_TaskOperation
REM Lumps
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Lumps\*.*" "%~1"
    CALL :CompileProject_TaskOperation
REM Maps
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Maps\*.*" "%~1Maps\"
    CALL :CompileProject_TaskOperation
REM Decorate
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Decorate\DECORATE.txt*" "%~1"
    CALL :CompileProject_TaskOperation
    REM ----
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Decorate\Effects\*.*" "%~1Decorate\"
    CALL :CompileProject_TaskOperation
REM Sprites
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Sprites\BreakableGlass\*.*" "%~1Sprites\"
    CALL :CompileProject_TaskOperation
    REM ----
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Sprites\Fog\*.*" "%~1Sprites\"
    CALL :CompileProject_TaskOperation
REM Sounds 
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Sounds\World\*.*" "%~1Sounds\"
    CALL :CompileProject_TaskOperation
    REM ----
EXIT /B 0



REM # =============================================================================================
REM # Documentation: This function will duplicate the data from the SVN project into the ZDoom Archive filesystem standards.
REM #                 This function is explicitly for the resource archive.
REM # Parameters: [{String} Project Build Path]
REM # =============================================================================================
:Make_DuplicateResourceAssets
REM This variable is used to describe the drivers main purpose and present the value in the log files.
CALL :CompileProject_Display_IncomingTaskSubLevel "Duplicate the data from local host repo into the local directory"
REM ----
REM Duplicate the following:
REM Lumps
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Lumps\*.*" "%~1"
    CALL :CompileProject_TaskOperation
REM Decorate
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Decorate\DECORATE.txt*" "%~1"
    CALL :CompileProject_TaskOperation
    REM ----
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Decorate\Effects\*.*" "%~1Decorate\"
    CALL :CompileProject_TaskOperation
REM Sprites
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Sprites\BreakableGlass\*.*" "%~1Sprites\"
    CALL :CompileProject_TaskOperation
    REM ----
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Sprites\Fog\*.*" "%~1Sprites\"
    CALL :CompileProject_TaskOperation
REM Sounds 
    SET TaskCaller_CallLong=COPY %CopyIntCMDArg% "%UserConfig.DirProjectWorkingCopy%\Sounds\World\*.*" "%~1Sounds\"
    CALL :CompileProject_TaskOperation
REM ----
EXIT /B 0



REM # =============================================================================================
REM # Documentation: This function will only output a general error message on the screen - and log.
REM # =============================================================================================
:Make_Failure
REM Display that an error 'happened'; the user can resort to the log file for help.
CALL :CompileProject_Display_IncomingTaskSubLevelMSG "!CRIT_ERR!: Failed to build project!  Check log for details"
GOTO :EOF



REM # =============================================================================================
REM # Documentation: This function will expunge superfluous data that is in the Maps directory.  Such data
REM #       can be: (GZ)Doom Builder Wad Backups and (GZ)Doom Builder DBS files
REM # Parameters: [{String} Project Build Path]
REM # =============================================================================================
:Make_ThrashSuperfluousMapData
REM This variable is used to describe the drivers main purpose and present the value in the log files.
CALL :CompileProject_Display_IncomingTaskSubLevel "Thrashing the superfluous data from the Maps Directory"
REM ----
REM Thrash: DBS files [DB2 configuration for the individual map\wad]
    SET TaskCaller_CallLong=DEL /Q "%~1Maps\*.dbs" || EXIT /B 1
    CALL :CompileProject_TaskOperation
REM Thrash: Wad Backups
    SET TaskCaller_CallLong=DEL /Q "%~1Maps\*.wad.backup*" || EXIT /B 1
    CALL :CompileProject_TaskOperation
REM Thrash: SLADE WAD Backups
    SET TaskCaller_CallLong=DEL /Q "%~1Maps\*.wad.bak*" || EXIT /B 1
    CALL :CompileProject_TaskOperation
REM =========================================================
EXIT /B 0











REM Do not touch
REM -----------------------------------------------------------------
REM =================================================================
REM -----------------------------------------------------------------
REM                       General Program Use


REM # =============================================================================================
REM # Documentation: This function will help keep the activity messages in a cleaner standard.
REM # Parameters:
REM #   [string] TaskName
REM # =============================================================================================
:CompileProject_Display_IncomingTask
IF %ToggleLog% EQU True CALL :CompileProject_Display_IncomingTaskLog "%~1"
ECHO %~1. . .
GOTO :EOF



REM # =============================================================================================
REM # Documentation: This function will help keep the activity messages in a cleaner standard.
REM # Parameters:
REM #   [string] TaskName
REM # =============================================================================================
:CompileProject_Display_IncomingTaskSubLevel
IF %ToggleLog% EQU True CALL :CompileProject_Display_IncomingTaskLog "%~1"
ECHO    %~1. . .
GOTO :EOF



REM # =============================================================================================
REM # Documentation: This function will help keep the activity messages in a cleaner standard.  Messages passed through this function are only treated as standard messages and not fully procedures.
REM # Parameters:
REM #   [string] TaskName
REM # =============================================================================================
:CompileProject_Display_IncomingTaskSubLevelMSG
(ECHO %~1) >> %STDOUT%
ECHO    %~1
GOTO :EOF



REM # =============================================================================================
REM # Documentation: This function will help keep the log activity messages in a cleaner standard.
REM # Parameters:
REM #   [string] TaskName
REM # =============================================================================================
:CompileProject_Display_IncomingTaskLog
(ECHO Performing Task:) >> %STDOUT%
(ECHO   %~1) >> %STDOUT%
(ECHO.) >> %STDOUT%
(ECHO.) >> %STDOUT%
GOTO :EOF



REM # =============================================================================================
REM # Documentation: Perform the operation that is requested properly.
REM #               NOTE: This depends on the global variable 'TaskCaller_CallLong'!
REM # =============================================================================================
:CompileProject_TaskOperation
REM Run the operation that is packaged.
%TaskCaller_CallLong%>> "%STDOUT%" 2>&1
SET ExitCode=%ERRORLEVEL%
REM If we're logging, call the log-footer
IF %ToggleLog% EQU True CALL :CompileProject_LogFooter
GOTO :EOF



REM # =============================================================================================
REM # Documentation: Always print this to log files after executing a task or a program.
REM # =============================================================================================
:CompileProject_LogFooter
(ECHO.)>> "%STDOUT%"
(ECHO.)>> "%STDOUT%"
(ECHO.)>> "%STDOUT%"
(ECHO.)>> "%STDOUT%"
(ECHO Program Called:)>> "%STDOUT%"
(ECHO   %TaskCaller_NiceProgramName%)>> "%STDOUT%"
(ECHO Task Performed:)>> "%STDOUT%"
(ECHO   %TaskCaller_CallLong%)>> "%STDOUT%"
(ECHO Exit Code: %ExitCode%)>> "%STDOUT%"
(ECHO %Separator%)>> "%STDOUT%"
(ECHO Time: %Time%   -   Date: %Date%)>> "%STDOUT%"
(ECHO Project Name: %ProjectName%   -   Module Version: %ProjectVersion%)>> "%STDOUT%"
(ECHO %SeparatorLong%)>> "%STDOUT%"
(ECHO %SeparatorLong%)>> "%STDOUT%"
(ECHO.)>> "%STDOUT%"
(ECHO.)>> "%STDOUT%"
GOTO :EOF



REM # =============================================================================================
REM # Documentation: Always print this to logfiles after a driver finished executing.
REM # Parameters: [{String} DriverMainProcess]
REM # =============================================================================================
:CompileProject_DriverLogFooter
REM ----
REM If incase the drivers call this function, opt out when the program is not logging.
IF %ToggleLog% EQU False (GOTO :EOF)
REM ----
(ECHO.)>> "%STDOUT%"
(ECHO.)>> "%STDOUT%"
(ECHO.)>> "%STDOUT%"
(ECHO.)>> "%STDOUT%"
(ECHO %SeparatorSmall%)>> "%STDOUT%"
(ECHO %Separator%)>> "%STDOUT%"
(ECHO Finished Executing Task:)>> "%STDOUT%"
(ECHO   %~1)>> %STDOUT%
(ECHO Time: %Time%   -   Date: %Date%)>> "%STDOUT%"
(ECHO Project Name: %ProjectName%   -   Module Version: %ProjectVersion%)>> "%STDOUT%"
(ECHO %SeparatorLong%)>> "%STDOUT%"
(ECHO %SeparatorLong%)>> "%STDOUT%"
(ECHO %Separator%)>> "%STDOUT%"
(ECHO %Separator%)>> "%STDOUT%"
(ECHO %SeparatorLong%)>> "%STDOUT%"
(ECHO %SeparatorLong%)>> "%STDOUT%"
(ECHO.)>> "%STDOUT%"
(ECHO.)>> "%STDOUT%"
GOTO :EOF



REM # =============================================================================================
REM # Documentation: For programs that uses reverse of the standard return code, this function will reverse them back to normal so the program will understand how to to properly treat the return value.
REM # =============================================================================================
:CompileProject_FlipBit_Common
IF %1 EQU 1 (
    REM 1 = Successful Operation
    EXIT /B 0
) ELSE (
    REM Failure or something else
    EXIT /B 1
)




REM =====================================================================
REM Global Functions
REM ----------------------------
REM These functions listed below is used to reduce redundancy within the code.
REM =====================================================================



REM # =============================================================================================
REM # Documentation: This function captures the user's input from the keyboard.  Added this into this functionality if incase some projects need this -- though it shouldn't only be used when absolutely necessary!  User interaction should be an absolute minimum during the compiling phase!
REM # =============================================================================================
:UserInput
ECHO.
ECHO %SeparatorSmall%
SET /P STDIN=^>^>^>^> 
GOTO :EOF