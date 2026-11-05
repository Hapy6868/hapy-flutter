@echo off
setlocal
chcp 65001 >nul
title Hapy - Thiet lap project Flutter
cd /d "%~dp0.."

echo ============================================
echo   HAPY - Tao thu muc ios/android va cau hinh
echo ============================================
echo.

if not exist "pubspec.yaml" (
  echo [LOI] Khong thay pubspec.yaml. Hay de file nay trong thu muc scripts cua project Hapy.
  pause & exit /b 1
)
if not exist "lib\main.dart" (
  echo [LOI] Khong thay lib\main.dart. Hay chep file main.dart cua Hapy vao thu muc lib.
  pause & exit /b 1
)

where flutter >nul 2>nul
if not errorlevel 1 goto flutter_ok

rem --- PATH chua nhan: thu cac thu muc pho bien ---
if exist "C:\FlutterSrc\flutter\bin\flutter.bat" set "PATH=%PATH%;C:\FlutterSrc\flutter\bin"
if exist "C:\src\flutter\bin\flutter.bat" set "PATH=%PATH%;C:\src\flutter\bin"
if exist "C:\flutter\bin\flutter.bat" set "PATH=%PATH%;C:\flutter\bin"
if exist "%USERPROFILE%\flutter\bin\flutter.bat" set "PATH=%PATH%;%USERPROFILE%\flutter\bin"
where flutter >nul 2>nul
if not errorlevel 1 goto flutter_ok

echo Khong tu tim thay Flutter trong PATH.
set "FDIR="
set /p "FDIR=Nhap duong dan thu muc flutter, vi du C:\FlutterSrc\flutter : "
if defined FDIR set "FDIR=%FDIR:"=%"
if defined FDIR if exist "%FDIR%\bin\flutter.bat" set "PATH=%PATH%;%FDIR%\bin"
where flutter >nul 2>nul
if not errorlevel 1 goto flutter_ok

echo.
echo [LOI] Van khong tim thay flutter.bat. Kiem tra:
echo   - File phai ton tai: [thu muc flutter]\bin\flutter.bat
echo   - Tranh bi long 2 lop, vi du C:\FlutterSrc\flutter\flutter\bin
pause & exit /b 1

:flutter_ok
echo Da tim thay Flutter:
where flutter
echo.

rem --- Flutter can Git ---
where git >nul 2>nul
if errorlevel 1 (
  echo [LOI] Flutter can Git. Cai Git: winget install --id Git.Git -e
  echo Sau khi cai xong, dong cua so va chay lai file nay.
  pause & exit /b 1
)

rem --- Sao luu file cua Hapy, vi flutter create co the tao file mac dinh ---
set "BK=%TEMP%\hapy_backup"
if exist "%BK%" rmdir /s /q "%BK%"
mkdir "%BK%\lib"
copy /y "pubspec.yaml" "%BK%\" >nul
copy /y "lib\main.dart" "%BK%\lib\" >nul

echo Dang tao thu muc ios va android...
call flutter create --org com.hapy --project-name hapy --platforms=ios,android .
if errorlevel 1 (
  echo [LOI] flutter create that bai. Chay "flutter doctor" de kiem tra.
  pause & exit /b 1
)

rem --- Khoi phuc file cua Hapy ---
copy /y "%BK%\pubspec.yaml" "pubspec.yaml" >nul
copy /y "%BK%\lib\main.dart" "lib\main.dart" >nul
if exist "test\widget_test.dart" del /q "test\widget_test.dart"

echo.
echo Dang tai thu vien...
call flutter pub get
if errorlevel 1 (
  echo [LOI] flutter pub get that bai.
  pause & exit /b 1
)

echo.
echo Dang cau hinh iOS...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ios.ps1"
if errorlevel 1 (
  echo [LOI] Khong cau hinh duoc iOS.
  pause & exit /b 1
)

echo.
echo ============================================
echo   XONG! Gio chay build_ipa.bat de build file ipa.
echo ============================================
pause
exit /b 0
