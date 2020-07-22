@echo off
setlocal
:main
cls
rem inkporter version = 1.5
echo SIMPLE ENVIRONMENT VARIABLE DIRECTORY ADDER
echo Silakan Pilih Target Ekspor Anda
echo 1) Tambahkan Direktori ke Environment Variable Inkporter
echo 2) Cek Environment Variable Inkporter
echo 3) Keluar
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