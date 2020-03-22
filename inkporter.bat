@echo off
setlocal
:main
cls
rem inkporter version = 1.0
echo "|| Selamat Datang di                                                    ||"
echo "||  ___       _                     _                         _         ||"
echo "|| |_ _|_ __ | | ___ __   ___  _ __| |_ ___ _ __    __      _(_)_ __    ||"
echo "||  | || '_ \| |/ / '_ \ / _ \| '__| __/ _ \ '__|___\ \ /\ / / | '_ \   ||"
echo "||  | || | | |   <| |_) | (_) | |  | ||  __/ | |_____\ V  V /| | | | |  ||"
echo "|| |___|_| |_|_|\_\ .__/ \___/|_|   \__\___|_|        \_/\_/ |_|_| |_|  ||"
echo "||                |_|                                                   ||"
echo.
echo Direktori saat ini %cd%
echo.
echo Silahkan Pilih Target Export Anda
echo.
echo Export menurut ukuran Page
echo 1="png"
echo 2="pdf"
echo 3="pdf_cmyk"
echo 4="eps_default"
echo 5="svg_plain"
echo.
echo Export menurut pola pada nama Object ID
echo 6="png_batch"
echo 7="pdf_batch"
echo 8="pdf_cmyk_batch"
echo 9="eps_default_batch"
echo 10="svg_plain_batch"
echo.
echo Untuk informasi pengembang, silahkan ketik "about"
echo untuk mengunjungi laman bantuan online, silahkan ketik "help"
echo.
set /p target=Pilihan Anda : 
if %target%== png goto PNGFULL
if %target%== pdf goto PDFFULL
if %target%== pdf_cmyk goto PDFCMYKFULL
if %target%== eps_default goto EPSFULL
if %target%== png_batch goto PNGBATCH
if %target%== pdf_batch goto PDFBATCH
if %target%== pdf_cmyk_batch goto PDFCMYKBATCH
if %target%== eps_default_batch goto EPSBATCH
if %target%== svg_plain goto SVGFULL
if %target%== svg_plain_batch goto SVGPLAINBATCH
if %target%== 1 goto PNGFULL
if %target%== 2 goto PDFFULL
if %target%== 3 goto PDFCMYKFULL
if %target%== 4 goto EPSFULL
if %target%== 5 goto SVGFULL
if %target%== 6 goto PNGBATCH
if %target%== 7 goto PDFBATCH
if %target%== 8 goto PDFCMYKBATCH
if %target%== 9 goto EPSBATCH
if %target%== 10 goto SVGPLAINBATCH
if %target%== help goto help
if %target%== about goto credits
if %target%== exit goto langsung_end
echo Silahkan pilih target yang tersedia
echo Tekan Enter Untuk Kembali
pause >nul
goto main

:credits
cls
echo.
echo Inkporter For Windows
echo Version 1.0b
echo.
echo .bat ini merupakan hasil re-write dari inkporter yang ditulis dalam bash oleh Rania Amina
echo ==========================================================================================
echo Tool ini dibuat untuk melakukan batch exporting pada file .svg melalui Inkscape command line
echo =============================================================================================
echo Inkporter menggunakan teknologi dari : 
echo Inkscape (https://inkscape.org/)
echo Ghostscript (https://www.ghostscript.com/)
echo ===========================================
echo inkporter.bat ditulis oleh Mas RJ95
echo Kota Tahu, 2020
echo.
echo Tekan ENTER untuk kembali
pause >nul
goto main

:help
start https://github.com/maslanangdev/inkporter/blob/windows/README.md
goto main

:PNGFULL
echo Bersiap mengekspor file SVG (Page) ke PNG
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p output="Nama File Output : "
inkscape --export-area-page --export-png=%output%.png "%svg%"
echo.
goto end

:SVGFULL
echo Bersiap mengekspor file SVG (Page) ke SVG Plain
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p output="Nama File Output : "
inkscape --export-area-page --export-plain-svg=%output%.svg "%svg%"
echo.
goto end

:PDFFULL
echo Bersiap mengekspor file SVG (Page) ke PDF
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p output="Nama File Output : "
inkscape --export-pdf=%output%.pdf --export-area-page "%svg%"
echo.
echo %output%.pdf telah dibuat
echo.
goto end

:PDFCMYKFULL
echo Bersiap mengekspor file SVG (Page) ke PDF dengan color space CMYK
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p output="Nama File Output : "
inkscape --export-pdf=%output%-rgb.pdf --export-area-page "%svg%"
gswin32 -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%output%.pdf %output%-rgb.pdf
del %output-rgb.pdf
echo.
echo %output%.pdf telah dibuat
goto end


:PNGBATCH
echo Bersiap mengekspor file SVG (object ID) ke PNG
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil export : "
echo File akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:PNGBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all ""%svg%"" ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png %%d.png ""%svg%""
	echo.
	move %%d.png "%der%\%fold%\" >nul
	)
goto end

:PDFBATCH
echo Bersiap mengekspor file SVG (object ID) ke PDF
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil export : "
echo File akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:PDFBATCHPPROCESS

for /f "delims=," %%d in ('inkscape --query-all "%svg%" ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg "%svg%"
	inkscape --export-area-page --without-gui --export-pdf=%%d.pdf %%d.svg
	del %%d.svg
	echo.
	move %%d.pdf "%der%\%fold%\" >nul
	echo file %%d.pdf telah dibuat
	)
goto end

:EPSFULL
echo Bersiap mengekspor file SVG (Page) ke EPS Default
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p output="Nama File Output : "
inkscape "%svg%" --export-eps=%output%.eps --without-gui --export-ps-level=3 --export-text-to-path --export-ignore-filters >nul
echo %output%.eps telah dibuat
echo.
goto end

:EPSBATCH
echo Bersiap mengekspor file SVG (object ID) ke EPS
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
echo File akan disimpan di %cd%\%fold%
set /p fold="Buat folder hasil export : "
md "%fold%" 2>nul
set der=%cd%

:EPSBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all "%svg%" ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg "%svg%"
	inkscape %%d.svg --export-eps=%%d.eps --export-area-page --export-ps-level={3} --export-text-to-path --export-ignore-filters >nul
	del %%d.svg
	echo.
	move %%d.eps "%der%\%fold%\" >nul
	echo file %%d.eps telah dibuat
	)
goto end

:PDFCMYKBATCH
echo Bersiap mengekspor file SVG (object ID) ke PDF dengan color space CMYK
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil export : "
echo File akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:PDFCMYKBATCHPPROCESS

for /f "delims=," %%d in ('inkscape --query-all "%svg%" ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg "%svg%"
	inkscape --export-area-page --without-gui --export-pdf=%%d-rgb.pdf %%d.svg
	gswin32 -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%%d.pdf %%d-rgb.pdf
	del %%d.svg
	del %%d-rgb.pdf
	move %%d.pdf "%der%\%fold%\" >nul
	echo.
	echo file %%d.pdf dengan warna CMYK telah dibuat
	)
goto end

:SVGPLAINBATCH
echo Bersiap mengekspor file SVG (object ID) ke SVG Plain
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil export : "
echo File akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:SVGPLAINBATCHPROCESS

for /f "delims=," %%d in ('inkscape --query-all "%svg%" ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg "%svg%"
	move %%d.svg "%der%\%fold%\" >nul
	echo.
	echo file %%d.svg telah dibuat
	)
goto end


:end
cls
echo.
echo Permintaan anda telah diselesaikan
echo file anda telah disimpan di %cd%\%fold%


:langsung_end
echo Sampai jumpa
endlocal
