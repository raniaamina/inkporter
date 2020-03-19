@echo off
set /a objnum=1
:main
cls
echo.
echo.
echo.
echo =====================
echo INKPORTER FOR WINDOWS
echo =====================
echo.
echo PASTIKAN ANDA SUDAH MENGARAHKAN COMMAND PROMPT PADA DIREKTORI
echo FILE YANG INGIN ANDA PROSES!
echo.
echo Silahkan Pilih Target Export Anda
echo.
echo Pilihan : 1="png" 2="pdf" 3="eps" 4="png_batch" 5="pdf_batch" 6="eps_batch"
echo Untuk informasi pengembang, silahkan ketik "about"
echo.
set /p target=Pilihan Anda : 
if %target%== png goto PNGFULL
if %target%== pdf goto PDFFULL
if %target%== eps goto EPSFULL
if %target%== png_batch goto PNGBATCH
if %target%== pdf_batch goto PDFBATCH
if %target%== eps_batch goto EPSBATCH
if %target%== 1 goto PNGFULL
if %target%== 2 goto PDFFULL
if %target%== 3 goto EPSFULL
if %target%== 4 goto PNGBATCH
if %target%== 5 goto PDFBATCH
if %target%== 6 goto EPSBATCH
if %target%== help goto HELP
if %target%== about goto credits
if %target%== exit goto langsung_end
echo Silahkan Pilih Pilihan Yang Tersedia
echo Tekan Enter Untuk Kembali
pause >nul
goto main

:credits
cls
echo.
echo.
echo.
echo.
echo.
echo .bat ini terinspirasi dari Inkporter yang ditulis oleh Rania Amina untuk Sistem Operasi Linux
echo =============================================================================================
echo Tool ini dibuat untuk pengguna Windows yang belum memiliki fitur WSL (Windows
echo Subsystem for Linux) atau yang tidak ingin menginstall WSL
echo ==========================================================
echo versi ini memiliki beberapa keterbatan dibandingkan Inkporter dan pengembangnya
echo masih berusaha agar dapat menyamai Inkporter
echo ============================================
echo Anda harus tambahkan folder direktori installasi Inkscape ke Environment Variables PATH
echo =======================================================================================
echo Versi ini masih dalam tahap percobaan
echo ======================================
echo Ditulis oleh Mas RJ95
echo Kota Tahu, 2020
echo.
echo Tekan ENTER untuk kembali
pause >nul
goto main

:HELP
echo ==================================================================================================
echo Anda harus tambahkan folder direktori installasi Inkscape ke Environment Variables PATH
echo Bagian ini belum selesai :v
goto main 

:PNGFULL
set /p svg="Nama File Anda :"
set /p output="Nama File Output "
inkscape --export-png %output%.png %svg%
echo.
goto end


:PDFFULL
set /p svg="Nama File Anda :"
set /p output="Nama File Output "
inkscape --export-pdf %output%.pdf %svg%
echo %output%.pdf telah dibuat
echo.
goto end


:PNGBATCH
set /p svg="Nama File Anda :"
set /p objID="Pola Object ID: "

:PNGBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svg% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png %%d.png %svg%
	echo.
	)
goto end

:PDFBATCH
set /p svg="Nama File Anda :"
set /p objID="Pola Object ID: "

:PDFBATCHPPROCESS

for /f "delims=," %%d in ('inkscape --query-all %svg% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg drawing.svg
	inkscape --export-area-page --export-pdf=%%d.pdf %%d.svg
	del %%d.svg
	echo.
	echo file %%d.pdf telah dibuat
	)
goto end

:EPSFULL
set /p svg="Nama File Anda :"
set /p output="Nama File Output "
inkscape %svg% --export-eps=%output%.eps --export-ps-level=3 --export-text-to-path --export-ignore-filters
echo %output%.eps telah dibuat
echo.
goto end

:EPSBATCH
set /p svg="Nama File Anda :"
set /p objID="Pola Object ID: "

:EPSBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svg% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg drawing.svg
	inkscape %svg% --export-id=%%d --export-eps=%%d.eps --export-ps-level=3 --export-text-to-path --export-ignore-filters
	del %%d.svg
	echo.
	echo file %%d.eps telah dibuat
	)
goto end

:end
echo.
echo Permintaan anda telah selesai
echo.
echo Have a Nice Day...

:langsung_end
echo See You
