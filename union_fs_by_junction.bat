@echo off

rem Вход:
rem 	1 - VOLUMES_FOLDER: папка, в которой сделаны mount point's на все разделы всех дисков
rem 	2 - MAIN_FOLDER: Главная папка для unionfs, в которой будут создаваться junctions. Должна быть поддиректорией папки Volumes. Указывается относительно VOLUMES_FOLDER
rem 	3 - EXCEPT_VOLUME: 
rem Выход:
rem 	В MAIN_FOLDER созданы junctions на все директории вида:
rem			VOLUMES_FOLDER\VOLUME\MAIN_FOLDER_TAIL\[DIR]
rem 		В случае, если есть несколько дирректорий с одинаковым именем. То junctions для повторных будет называться: [DIR]-[VOLUME]
rem 	Другие Junction в MAIN_FOLDER удалены
rem Todo:
rem 	- Добавить автоматическое вычисление EXCEPT_VOLUME
rem 	- Написать документацию
rem		- Перевести на английский

call :main %*
echo End 
exit /b %errorlevel%


rem удалить все junctions из дирректории, которая указывается в качестве парраметра. Пример использования:
rem    call :remove_junctions %MAIN_FOLDER%
:remove_junctions
	set FOLDER_WITH_JUNCTIONS=%*
	echo FOLDER_WITH_JUNCTIONS=%FOLDER_WITH_JUNCTIONS%
	for /f "tokens=*" %%I in ('dir "%FOLDER_WITH_JUNCTIONS%" /A:L /B') do (
		set TARGET=%FOLDER_WITH_JUNCTIONS%\%%I
		if not exist "!TARGET!" goto TargetNotExistsError
		rmdir /Q "!TARGET!"
	)
	exit /b %errorlevel%
	
:main

	setlocal ENABLEEXTENSIONS

	rem set VOLUMES_FOLDER=%~1
	set VOLUMES_FOLDER=c:\Volumes\medved
	rem set MAIN_FOLDER=%~2
	set MAIN_FOLDER=0 - XPWork\Medvedevy\DmitryMedvedev
	set MAIN_FOLDER=%VOLUMES_FOLDER%\%MAIN_FOLDER%
	rem set EXCEPT_VOLUME=%~3
	set EXCEPT_VOLUME=3 - System2016
	
	if "%VOLUMES_FOLDER%"=="" goto IncorrectArgsError
	if "%MAIN_FOLDER%"=="" goto IncorrectArgsError

	rem get subfolder for main folder
	setlocal ENABLEDELAYEDEXPANSION
	set MAIN_FOLDER_SUBFOLDER_WITH_VOLUME=!MAIN_FOLDER:%VOLUMES_FOLDER%\=!
	rem setlocal DISABLEDELAYEDEXPANSION
	
	for /f "delims=\ tokens=1,*" %%I in ("%MAIN_FOLDER_SUBFOLDER_WITH_VOLUME%") do (
		set MAIN_FOLDER_VOLUME=%%I
		set MAIN_FOLDER_SUBFOLDER=%%J
	)

	call :remove_junctions %MAIN_FOLDER%
	if not "%errorlevel%"=="0" goto RemoveJunctionsError

	rem create junctions
	echo MAIN_FOLDER_VOLUME=%MAIN_FOLDER_VOLUME%
	rem echo MAIN_FOLDER_SUBFOLDER=%MAIN_FOLDER_SUBFOLDER%
	for /f "tokens=*" %%I in ('dir "%VOLUMES_FOLDER%" /A:L /B') do (
		set CURRENT_VOLUME=%%I
		echo CURRENT_VOLUME=!CURRENT_VOLUME!
		if not "!CURRENT_VOLUME!"=="%MAIN_FOLDER_VOLUME%" (
			if not "!CURRENT_VOLUME!"=="%EXCEPT_VOLUME%" (
				for /f "tokens=*" %%X in ('dir /B /A:D "%VOLUMES_FOLDER%\!CURRENT_VOLUME!\%MAIN_FOLDER_SUBFOLDER%"') do (
					set CURRENT_FOLDER=%%X
					set TARGET=%VOLUMES_FOLDER%\!CURRENT_VOLUME!\%MAIN_FOLDER_SUBFOLDER%\!CURRENT_FOLDER!
					set LINK_PATH=%MAIN_FOLDER%\!CURRENT_FOLDER!
					if exist !LINK_PATH! (
						set LINK_PATH=!LINK_PATH! - !CURRENT_VOLUME!
					)
					if not exist "!TARGET!" goto TargetNotExistsError
					mklink /j "!LINK_PATH!" "!TARGET!"
				)
			)
		)
	)

	echo End main
	exit /b %errorlevel%

:TargetNotExistsError
	echo TargetNotExistsError
	echo TARGET=!TARGET!
	echo TARGET=%TARGET%
	echo May be you are using the exclamation sign in name of a folder. It is not supported by this script
	exit /b 1

:RemoveJunctionsError
	echo RemoveJunctionsError
	exit /b 1
	
:IncorrectArgsError
	echo IncorrectArgsError
	exit /b 1