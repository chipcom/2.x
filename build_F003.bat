c:\Harbour\bin\hbmk2 chip_mo_f003.hbp
copy chip_mo.exe d:\_mo\chip\exe

@REM @echo off
@REM if %1. == . goto MissingParameter
@REM if %1. == develop. goto GoodParameter
@REM if %1. == debug.   goto GoodParameter
@REM rem if %1. == release. goto GoodParameter

@REM echo Необходимо указать параметр "debug" или "develop"
@REM rem echo Необходимо указать параметр "debug" или "release" или "develop"
@REM goto End

@REM :GoodParameter

@REM rem echo Хороший параметр

@REM if %1 == debug (
@REM rem    hbmk2 ..\HelloHarbour.hbp -b   
@REM     echo Debug parameter
@REM ) else (
@REM   rem echo Develop parameter
@REM   c:\Harbour\bin\hbmk2 chip_mo_f003.hbp
@REM   echo %errorlevel%
@REM 	if %ErrorLevel% equ 0 (goto SuccessCompiled) else (goto ErrorCompiled)
@REM )
@REM :ErrorCompiled
@REM echo Ошибка компиляции
@REM goto End
@REM :SuccessCompiled
@REM echo
@REM echo ************************************
@REM echo Успешная компиляции
@REM copy chip_mo.exe d:\_mo\chip\exe
@REM echo ************************************
@REM echo
@REM goto End
@REM :MissingParameter
@REM echo Неверный параметр
@REM :End