@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Hapy - Build IPA tren may Mac dam may
cd /d "%~dp0.."

echo ============================================
echo   HAPY - Tu dong build file hapy.ipa
echo ============================================
echo.

rem --- 0. Kiem tra dang o thu muc project Flutter ---
if not exist "pubspec.yaml" (
  echo [LOI] Hay de file .bat nay trong thu muc scripts cua project, noi thu muc cha co pubspec.yaml
  pause & exit /b 1
)
if not exist "ios" (
  if exist "scripts\setup_project.bat" (
    echo Chua co thu muc ios, dang chay setup_project.bat ...
    call scripts\setup_project.bat
  )
)
if not exist "ios" (
  echo [LOI] Van chua co thu muc "ios". Hay chay scripts\setup_project.bat truoc.
  pause & exit /b 1
)
if not exist ".github\workflows\build-ios.yml" (
  echo Thieu file build-ios.yml, dang tu tao...
  call :makeyml
)

rem --- 1. Kiem tra Git va GitHub CLI ---
where git >nul 2>nul
if errorlevel 1 (
  echo Chua co Git. Dang cai bang winget...
  winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
  echo.
  echo Da cai xong. Hay DONG cua so nay va chay lai file build_ipa.bat.
  pause & exit /b 0
)
where gh >nul 2>nul
if errorlevel 1 (
  echo Chua co GitHub CLI. Dang cai bang winget...
  winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements
  echo.
  echo Da cai xong. Hay DONG cua so nay va chay lai file build_ipa.bat.
  pause & exit /b 0
)

rem --- 2. Dang nhap GitHub (chi lan dau) ---
gh auth status >nul 2>nul
if errorlevel 1 (
  echo Can dang nhap GitHub. Lam theo huong dan tren man hinh:
  gh auth login --web --git-protocol https
  if errorlevel 1 ( echo [LOI] Dang nhap that bai. & pause & exit /b 1 )
)

rem --- 3. Chuan bi repo Git ---
if not exist ".git" (
  git init
  git branch -M main
)
git config user.name >nul 2>nul || git config --local user.name "Hapy Dev"
git config user.email >nul 2>nul || git config --local user.email "hapy@users.noreply.github.com"

if not exist ".gitignore" type nul > .gitignore
findstr /x /c:"output/" .gitignore >nul 2>nul || echo output/>>.gitignore

git add -A
git commit -m "Hapy build %date% %time%" >nul 2>nul

for /f "delims=" %%b in ('git branch --show-current') do set BRANCH=%%b

git remote get-url origin >nul 2>nul
if errorlevel 1 (
  call :connect_repo
  if errorlevel 1 ( pause & exit /b 1 )
)

echo Dang day code len GitHub...
git push -u origin !BRANCH!
if errorlevel 1 (
  echo.
  echo Repo tren GitHub da co noi dung khac voi may ban ^(thuong do lan chay truoc de lai^).
  choice /m "Ghi de noi dung tren GitHub bang code o may ban"
  if errorlevel 2 ( echo Da huy. & pause & exit /b 1 )
  git push -u origin !BRANCH! --force
  if errorlevel 1 ( echo [LOI] Push that bai. & pause & exit /b 1 )
)

rem --- 4. Ghi nho lan build gan nhat roi kich hoat build moi ---
set PREV=0
for /f "delims=" %%i in ('gh run list --workflow=build-ios.yml --limit 1 --json databaseId --jq ".[0].databaseId" 2^>nul') do set PREV=%%i

echo.
echo Dang yeu cau GitHub build ban moi...
gh workflow run build-ios.yml --ref !BRANCH!
if errorlevel 1 ( echo [LOI] Khong kich hoat duoc workflow. & pause & exit /b 1 )

rem --- 5. Cho lan chay moi xuat hien ---
set RUNID=
set TRIES=0
:waitrun
set /a TRIES+=1
if !TRIES! gtr 20 ( echo [LOI] Khong thay lan build moi. Kiem tra tab Actions tren GitHub. & pause & exit /b 1 )
timeout /t 5 /nobreak >nul
set RUNID=
for /f "delims=" %%i in ('gh run list --workflow=build-ios.yml --limit 1 --json databaseId --jq ".[0].databaseId" 2^>nul') do set RUNID=%%i
if "!RUNID!"=="" goto waitrun
if "!RUNID!"=="!PREV!" goto waitrun

echo Lan build: !RUNID!  ^(thuong mat 10-15 phut, vui long doi...^)
set RETRIES=0
:watchrun
gh run watch !RUNID! --exit-status
if not errorlevel 1 goto downloadipa

echo.
echo [LOI] Build that bai. Chi tiet buoc bi loi:
gh run view !RUNID! --log-failed
echo.
echo ----------------------------------------------------------------
echo  Neu o tren KHONG co dong loi nao, hoac chay khoang 15 phut roi dung,
echo  thuong la GitHub het may Mac ^(loi ha tang, khong phai loi code^).
echo  Xem ly do:  gh run view !RUNID!
echo ----------------------------------------------------------------
if !RETRIES! GEQ 2 ( pause & exit /b 1 )
choice /m "Chay lai build nay"
if errorlevel 2 ( pause & exit /b 1 )
set /a RETRIES+=1
gh run rerun !RUNID! --failed
timeout /t 10 /nobreak >nul
goto watchrun

:downloadipa

rem --- 6. Tai file ipa ---
if exist output rmdir /s /q output
gh run download !RUNID! -n hapy-ipa -D output
if errorlevel 1 ( echo [LOI] Tai file that bai. & pause & exit /b 1 )

echo.
echo ============================================
echo   XONG!  File: %~dp0..\output\hapy.ipa
echo   Mo AltStore tren iPhone de cai file nay.
echo ============================================
explorer output
pause
exit /b 0

:makeyml
if not exist ".github\workflows" mkdir ".github\workflows"
set "Y=.github\workflows\build-ios.yml"
> "%Y%" echo name: Build iOS IPA unsigned
>> "%Y%" echo.
>> "%Y%" echo on:
>> "%Y%" echo   workflow_dispatch:
>> "%Y%" echo.
>> "%Y%" echo jobs:
>> "%Y%" echo   build:
>> "%Y%" echo     runs-on: macos-15
>> "%Y%" echo     steps:
>> "%Y%" echo       - uses: actions/checkout@v4
>> "%Y%" echo.
>> "%Y%" echo       - uses: subosito/flutter-action@v2
>> "%Y%" echo         with:
>> "%Y%" echo           channel: stable
>> "%Y%" echo           cache: true
>> "%Y%" echo.
>> "%Y%" echo       - name: Tat Swift Package Manager (dung CocoaPods)
>> "%Y%" echo         run: flutter config --no-enable-swift-package-manager
>> "%Y%" echo.
>> "%Y%" echo       - run: flutter pub get
>> "%Y%" echo.
>> "%Y%" echo       - name: Build iOS no codesign
>> "%Y%" echo         run: flutter build ios --release --no-codesign
>> "%Y%" echo.
>> "%Y%" echo       - name: Package ipa
>> "%Y%" echo         run: ^|
>> "%Y%" echo           mkdir Payload
>> "%Y%" echo           cp -r build/ios/iphoneos/Runner.app Payload/
>> "%Y%" echo           zip -r hapy.ipa Payload
>> "%Y%" echo.
>> "%Y%" echo       - uses: actions/upload-artifact@v4
>> "%Y%" echo         with:
>> "%Y%" echo           name: hapy-ipa
>> "%Y%" echo           path: hapy.ipa
exit /b 0

rem ---------------------------------------------------------------
rem Noi may nay voi repo hapy-flutter tren GitHub:
rem   - neu repo chua co: tao moi (rieng tu)
rem   - neu repo da co (vi du tu lan chay truoc): dung lai repo do
rem ---------------------------------------------------------------
:connect_repo
set "GHUSER="
for /f "delims=" %%u in ('gh api user --jq .login') do set "GHUSER=%%u"
if "!GHUSER!"=="" (
  echo [LOI] Khong lay duoc ten tai khoan GitHub. Hay chay:  gh auth login
  exit /b 1
)
gh repo view "!GHUSER!/hapy-flutter" >nul 2>nul
if errorlevel 1 (
  echo Dang tao repo rieng tu "hapy-flutter"...
  gh repo create hapy-flutter --private
  if errorlevel 1 (
    echo [LOI] Khong tao duoc repo hapy-flutter.
    exit /b 1
  )
) else (
  echo Repo !GHUSER!/hapy-flutter da ton tai, se dung lai repo nay.
)
git remote add origin "https://github.com/!GHUSER!/hapy-flutter.git"
exit /b 0
