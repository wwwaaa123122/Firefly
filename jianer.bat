@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title Jianer - Windows Launcher
cd /d "%~dp0"

REM ============ 基础配置（全程使用镜像源） ============
set "REQ_PYVER=3.12.7"
set "PY_MIRROR=https://mirrors.huaweicloud.com/python/3.12.7/python-3.12.7-amd64.exe"
set "PY_MIRROR_BAK=https://registry.npmmirror.com/-/binary/python/3.12.7/python-3.12.7-amd64.exe"
set "PIP_MIRROR=https://mirrors.aliyun.com/pypi/simple"
set "PIP_HOST=mirrors.aliyun.com"
set "REPO=SRInternet-Studio/Jianer_QQ_bot"
set "ZIP_NAME=Jianer_Next_QQ_Bot.zip"

echo =========================================
echo    Jianer - Windows 一键部署脚本
echo    简单·迅速·便捷
echo =========================================
echo.
echo [1/5] 检查/安装 Python %REQ_PYVER% ...
set "PY_EXE="

REM ---- 依次尝试 py / python3.12 / python 定位 3.12.7 ----
for %%c in ("py -3.12" "python3.12" "python") do (
    set "PY_VER="
    for /f "tokens=2 delims= " %%v in ('%%~c -V 2^>nul') do set "PY_VER=%%v"
    if "!PY_VER!"=="%REQ_PYVER%" (
        for /f "delims=" %%p in ('%%~c -c "import sys;print(sys.executable)"') do set "PY_EXE=%%p"
    )
    if defined PY_EXE goto :py_found
)

:install_python
echo [提示] 未找到 Python %REQ_PYVER%，正在从镜像下载安装程序...
set "PY_INSTALLER=%TEMP%\python-%REQ_PYVER%-amd64.exe"
curl -L --fail -o "%PY_INSTALLER%" "%PY_MIRROR%"
if errorlevel 1 (
    echo [提示] 华为云镜像下载失败，切换备用镜像...
    curl -L --fail -o "%PY_INSTALLER%" "%PY_MIRROR_BAK%"
)
if not exist "%PY_INSTALLER%" (
    echo [错误] Python 安装包下载失败，请检查网络连接后重试
    pause
    exit /b 1
)
echo 正在静默安装 Python %REQ_PYVER%，请稍候...
"%PY_INSTALLER%" /quiet InstallAllUsers=0 PrependPath=1 Include_launcher=1 Include_pip=1 Include_test=0
set "PY_EXE=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
if not exist "%PY_EXE%" (
    echo [错误] Python 安装失败，未找到: %PY_EXE%
    pause
    exit /b 1
)
del "%PY_INSTALLER%" 2>nul
echo [成功] Python %REQ_PYVER% 安装完成
goto :py_done

:py_found
echo [成功] 已检测到 Python %REQ_PYVER%: %PY_EXE%

:py_done
echo.

REM ============ 2. 获取项目 ============
echo [2/5] 检查项目文件 ...
if exist "%CD%\app.py" goto :project_ready
if exist "%CD%\requirements.txt" goto :project_ready

echo [提示] 未检测到项目，正在从 GitHub 下载最新版本...
set "ZIP_URL=https://github.com/%REPO%/releases/latest/download/%ZIP_NAME%"
curl -L --fail -o "%CD%\%ZIP_NAME%" "%ZIP_URL%"
if errorlevel 1 (
    echo [提示] GitHub 直连失败，使用 ghproxy 镜像重试...
    curl -L --fail -o "%CD%\%ZIP_NAME%" "https://mirror.ghproxy.com/%ZIP_URL%"
)
if not exist "%CD%\%ZIP_NAME%" (
    echo [错误] 项目下载失败，请检查网络连接后重试
    pause
    exit /b 1
)

echo 正在解压项目...
set "EXTRACT_DIR=%TEMP%\je_extract_%RANDOM%"
if exist "%EXTRACT_DIR%" rmdir /s /q "%EXTRACT_DIR%"
powershell -NoProfile -Command "Expand-Archive -LiteralPath '%CD%\%ZIP_NAME%' -DestinationPath '%EXTRACT_DIR%' -Force"
del "%CD%\%ZIP_NAME%" 2>nul

REM ---- 定位含 app.py/requirements.txt 的项目根目录（兼容嵌套打包） ----
set "PROJ_SRC="
for /f "delims=" %%s in ('powershell -NoProfile -Command "$s='%EXTRACT_DIR%'; for($i=0;$i -lt 5;$i++){ $a=Test-Path (Join-Path $s 'app.py'); $r=Test-Path (Join-Path $s 'requirements.txt'); if($a -or $r){ break }; $d=@(Get-ChildItem $s -Directory); if($d.Count -eq 1){ $s=$d[0].FullName } else { break } }; Write-Output $s"') do set "PROJ_SRC=%%s"
if not defined PROJ_SRC set "PROJ_SRC=%EXTRACT_DIR%"

if exist "%CD%\Jianer_QQ_bot" (
    echo [提示] 已存在 Jianer_QQ_bot 目录，使用现有目录
    rmdir /s /q "%EXTRACT_DIR%" 2>nul
) else (
    move /y "%PROJ_SRC%" "%CD%\Jianer_QQ_bot" >nul 2>&1
    if errorlevel 1 (
        echo [错误] 项目文件整理失败
        pause
        exit /b 1
    )
)
cd /d "%CD%\Jianer_QQ_bot"

:project_ready
if not exist "%CD%\app.py" (
    echo [错误] 未找到 app.py，请确认项目文件完整
    pause
    exit /b 1
)
echo [成功] 项目就绪: %CD%
echo.

REM ============ 3. 创建虚拟环境 ============
echo [3/5] 创建虚拟环境 (.venv) ...
if not exist ".venv" (
    "%PY_EXE%" -m venv .venv
    if errorlevel 1 (
        echo [错误] 虚拟环境创建失败
        pause
        exit /b 1
    )
)
set "VENV_PY=%CD%\.venv\Scripts\python.exe"
if not exist "%VENV_PY%" (
    echo [错误] 未找到 venv 中的 Python: %VENV_PY%
    pause
    exit /b 1
)
echo [成功] 虚拟环境就绪
echo.

REM ============ 4. 配置 pip 镜像并安装依赖 ============
echo [4/5] 配置 pip 阿里云镜像源 ...
if not exist "%APPDATA%\pip" mkdir "%APPDATA%\pip"
> "%APPDATA%\pip\pip.ini" echo [global]
>> "%APPDATA%\pip\pip.ini" echo index-url = %PIP_MIRROR%
>> "%APPDATA%\pip\pip.ini" echo trusted-host = %PIP_HOST%
echo [成功] pip 镜像已配置

echo 正在升级 pip ...
"%VENV_PY%" -m pip install --upgrade pip -i %PIP_MIRROR% --trusted-host %PIP_HOST%
if errorlevel 1 (
    echo [警告] pip 升级失败，继续尝试安装依赖...
)

if not exist "requirements.txt" (
    echo [警告] 未找到 requirements.txt，跳过依赖安装
    goto :deps_done
)
echo 正在使用镜像安装依赖 ...
"%VENV_PY%" -m pip install -r requirements.txt -i %PIP_MIRROR% --trusted-host %PIP_HOST%
if errorlevel 1 (
    echo [错误] 依赖安装失败
    pause
    exit /b 1
)
"%VENV_PY%" -m pip install setuptools -i %PIP_MIRROR% --trusted-host %PIP_HOST%
:deps_done
echo [成功] 依赖安装完成
echo.

REM ============ 5. 启动 app.py ============
echo [5/5] 启动 app.py ...
echo =========================================
echo    即将启动 Jianer (app.py)
echo    按 Ctrl+C 可停止程序
echo =========================================
echo.
"%VENV_PY%" app.py
set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo app.py 已退出 (退出代码: %EXIT_CODE%)
pause
endlocal & exit /b %EXIT_CODE%
