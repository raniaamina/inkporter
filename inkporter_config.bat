@echo off
setlocal
:main
cls
rem inkporter version = 1.5
echo INKPORTER-WIN PANEL (Beta)
echo =========================
echo 1) Add dependency directory to Environment Variable
echo 2) Open Inkporter-CLI
echo 3) Exit
echo.
set /p target=Pilihan Anda : 
if %target%== 1 setx /m inkporter %directory%
if %target%== 3 goto langsung_end
if %target%== 2 echo %inkporter%
echo Silakan pilih target yang tersedia
echo Tekan Enter Untuk Kembali
pause >nul
goto main


:langsung_end
echo Sampai jumpa
endlocal