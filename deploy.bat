@echo off
cd /d %~dp0

echo =========================
echo Step 1: Switch to main
echo =========================
git checkout main

echo =========================
echo Step 2: Build Flutter Web
echo =========================
flutter build web --release --base-href=/mock-bank/

if errorlevel 1 (
  echo Build failed!
  pause
  exit /b
)

echo =========================
echo Step 3: Switch to gh-pages
echo =========================
git checkout -f gh-pages

echo =========================
echo Step 4: Clear old files
echo =========================
git rm -r . >nul 2>nul
git commit -m "clear old build" >nul 2>nul

echo =========================
echo Step 5: Copy new build
echo =========================
xcopy build\web\* . /E /Y >nul

echo =========================
echo Step 6: Commit and push
echo =========================
git add .
git commit -m "deploy web"
git push origin gh-pages

echo =========================
echo Deploy finished!
echo =========================
pause
