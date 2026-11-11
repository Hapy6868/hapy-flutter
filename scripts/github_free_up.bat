@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Hapy - Giai phong dung luong GitHub
cd /d "%~dp0.."

echo ============================================
echo   HAPY - Giai phong dung luong / han muc GitHub
echo ============================================
echo.

where gh >nul 2>nul
if errorlevel 1 (
  echo [LOI] Chua co GitHub CLI. Cai: winget install --id GitHub.cli -e
  pause & exit /b 1
)
gh auth status >nul 2>nul
if errorlevel 1 (
  echo [LOI] Chua dang nhap GitHub. Hay chay:  gh auth login
  pause & exit /b 1
)

set "REPO="
set "VIS="
for /f "delims=" %%r in ('gh repo view --json nameWithOwner --jq .nameWithOwner') do set "REPO=%%r"
for /f "delims=" %%v in ('gh repo view --json visibility --jq .visibility') do set "VIS=%%v"
if "!REPO!"=="" (
  echo [LOI] Khong xac dinh duoc repo. Hay chay file nay trong thu muc project da noi voi GitHub.
  pause & exit /b 1
)
echo Repo: !REPO!    Che do: !VIS!
echo.

echo ===== 1. Xoa cac lan build cu ^(giai phong dung luong artifact^) =====
set COUNT=0
for /f "skip=1 delims=" %%i in ('gh run list --limit 200 --json databaseId --jq ".[].databaseId"') do (
  gh run delete %%i >nul 2>nul
  set /a COUNT+=1
)
echo Da xu ly !COUNT! lan chay cu ^(giu lai lan moi nhat^).
echo.

echo ===== 2. Repo cong khai = build Mac MIEN PHI, KHONG GIOI HAN =====
if /i "!VIS!"=="PUBLIC" (
  echo Repo da o che do cong khai. Khong can lam gi them.
  goto done
)
echo Repo dang RIENG TU: may Mac bi tinh 10 phut cho moi 1 phut chay
echo nen het han muc rat nhanh ^(khoang 13 lan build moi thang^).
echo.
echo Neu chuyen sang CONG KHAI thi AI CUNG DOC DUOC ma nguon.
echo Cac dong tim thay duoi day ^(neu co^) la noi co the chua mat khau/khoa bi mat:
echo ----------------------------------------------------------------
git grep -n -i -E "password|secret|apikey|api_key|PRIVATE KEY" -- .
echo ----------------------------------------------------------------
echo Neu khong co dong nao o tren thi thuong la an toan.
echo.
choice /m "Chuyen repo sang CONG KHAI"
if errorlevel 2 goto done
gh repo edit !REPO! --visibility public --accept-visibility-change-consequences
if errorlevel 1 (
  echo [LOI] Khong doi duoc che do. Co the can lam tren web: Settings - Danger Zone - Change visibility.
) else (
  echo Da chuyen sang cong khai. Hay chay lai scripts\build_ipa.bat.
)

:done
echo.
pause
