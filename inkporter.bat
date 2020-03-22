@echo off
:main
cls
echo.
echo.
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
echo Pilihan : 
echo 1="png"
echo 2="pdf"
echo 3="pdf_cmyk"
echo 4="eps_default"
echo 5="svg_plain"
echo 6="png_batch"
echo 7="pdf_batch"
echo 8="pdf_cmyk_batch"
echo 9="eps_default_batch"
echo 10="svg_plain_batch"
echo.
echo Untuk informasi pengembang, silahkan ketik "about"
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
echo .bat ini merupakan hasil re-write dari inkporter yang ditulis dalam bash
echo =========================================================================
echo Tool ini dibuat untuk melakukan batch exporting pada file .svg melalui Inkscape command line
echo ============================================================================================
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
echo Bersiap mengekspor berkas SVG (Page) ke PNG
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
echo Bersiap mengekspor berkas SVG (Page) ke SVG Plain
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
echo Bersiap mengekspor berkas SVG (Page) ke PDF
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
echo Bersiap mengekspor berkas SVG (Page) ke PDF dengan color space CMYK
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
echo Bersiap mengekspor berkas SVG (object ID) ke PNG
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p objID="Pola Object ID : "
set /p fold="Nama folder hasil export : "
md "%fold%" >nul
set der=%cd%

:PNGBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all ""%svg%"" ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png %%d.png ""%svg%""
	echo.
	move %%d.png "%der%\%fold%\" >nul
	)
goto end

:PDFBATCH
echo Bersiap mengekspor berkas SVG (object ID) ke PDF
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p objID="Pola Object ID : "
set /p fold="Nama folder hasil export : "
md "%fold%" >nul
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
echo Bersiap mengekspor berkas SVG (Page) ke EPS Default
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p output="Nama File Output : "
inkscape "%svg%" --export-eps=%output%.eps --without-gui --export-ps-level=3 --export-text-to-path --export-ignore-filters
echo %output%.eps telah dibuat
echo.
goto end

:EPSBATCH
echo Bersiap mengekspor berkas SVG (object ID) ke EPS
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p objID="Pola Object ID : "
set /p fold="Nama folder hasil export : "
md "%fold%" >nul
set der=%cd%

:EPSBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all "%svg%" ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg "%svg%"
	inkscape %%d.svg --export-eps=%%d.eps --export-area-page --export-ps-level={3} --export-text-to-path --export-ignore-filters
	del %%d.svg
	echo.
	move %%d.eps "%der%\%fold%\" >nul
	echo file %%d.eps telah dibuat
	)
goto end

:PDFCMYKBATCH
echo Bersiap mengekspor berkas SVG (object ID) ke PDF dengan color space CMYK
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p objID="Pola Object ID : "
set /p fold="Nama folder hasil export : "
md "%fold%" >nul
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
echo Bersiap mengekspor berkas SVG (object ID) ke SVG Plain
echo file SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran File Nama File
echo ================================================
dir | findstr .svg
echo.
set /p svg="File yang ingin anda proses : "
set /p objID="Pola Object ID : "
set /p fold="Nama folder hasil export : "
md "%fold%" >nul
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
echo.
echo Permintaan anda telah diselesaikan
echo Have a Nice Day...

:langsung_end
echo See You
