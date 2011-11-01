:: Copyright (C) 2011 LuaDist
:: Redistribution and use of this file is allowed according to the terms of the MIT license.
:: For details see the COPYRIGHT file distributed with LuaDist.
:: Please note that the package source code is licensed under its own license.
:: 
:: Install all dists from repository into current directory
:: In case it is called in the repository it will install into _install folder
@echo off
setlocal
set CMAKE=C:\PROGRA~2\CMAKE2~1.8\bin\cmake
set REPO=%~dp0
set REPO=%REPO:~0,-1%
set DEPL=%CD%
set DISTS=%*

if "%1"=="" goto :help
if "%REPO%"=="%DEPL%" set DEPL=%DEPL%\_install

echo Installing: %*
echo Destination: %DEPL%
echo Repository: %REPO%

mkdir "%DEPL%\tmp\install"
cd "%DEPL%\tmp\install" && %CMAKE% "%REPO%" -G"MinGW Makefiles" -DCMAKE_INSTALL_PREFIX="%DEPL%" -DDISTS="%DISTS%"
%CMAKE% --build "%DEPL%\tmp\install" --target install
goto :exit

:help
echo LuaDist direct install utility.
echo This utility will install LuaDist modules into current directory. If called in the repository it will install into '_install' folder to avoid collisions. Modules to install are identified by name or name-version arguments. The installation will use sources from the Repository if they are available, if not it will look for the git repository directly.
echo WARNING: This utility does not automatically install dependencies. Consider bootstrapping the automated deployment utility.
echo USE: install.bat [module_name-module_ver] [module_name]
echo BOOTSTRAP: install.bat bootstrap

:exit
endlocal
