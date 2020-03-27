@echo off
setlocal
:main
cls
rem inkporter version = 1.1
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
echo Silakan Pilih Target Ekspor Anda
echo 1) PNG                      
echo 2) PDF                       
echo 3) PDF-CMYK                   
echo 4) EPS-Default                 
echo 5) SVG-Plain                    
echo.
echo Untuk informasi pengembang, Silakan ketik "about"
echo untuk mengunjungi laman bantuan online, Silakan ketik "help"
echo.
set /p target=Pilihan Anda : 
if %target%== 1 goto PNGBATCH
if %target%== 2 goto PDFBATCH
if %target%== 3 goto PDFCMYKBATCH
if %target%== 4 goto EPSBATCH
if %target%== 5 goto SVGPLAINBATCH
if %target%== help goto help
if %target%== about goto credits
if %target%== exit goto langsung_end
echo Silakan pilih target yang tersedia
echo Tekan Enter Untuk Kembali
pause >nul
goto main

:credits
cls
echo.
echo Inkporter For Windows
echo Version 1.1a
echo.
echo Tool ini dibuat untuk melakukan batch ekspor pada berkas .svg melalui Inkscape command line
echo ===========================================================================================
echo Batch file ini merupakan hasil re-write dari inkporter yang ditulis dalam bash oleh Rania Amina
echo ================================================================================================
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

:PNGBATCH
set dpi = 96
echo Bersiap mengekspor berkas SVG ke PNG
echo Berkas SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran berkas Nama berkas
echo ================================================
dir | findstr .svg
echo.
set /p svg="Berkas yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p dpi="Tentukan nilai DPI hasil expor : "
set /p fold="Buat folder hasil ekspor : "
set svgin="%svg%"
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:PNGBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%%d.png --export-dpi=%dpi%  %svgin% >nul
	echo Berkas %%d.png telah dibuat
	echo.
	move %%d.png "%der%\%fold%\" >nul
	)
goto end

:PDFBATCH
echo Bersiap mengekspor berkas SVG ke PDF
echo Berkas SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran berkas Nama berkas
echo ================================================
dir | findstr .svg
echo.
set /p svg="Berkas yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
set svgin="%svg%"
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:PDFBATCHPPROCESS

for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg %svgin%
	inkscape --export-area-page --without-gui --export-pdf=%%d.pdf %%d.svg
	del %%d.svg
	echo.
	move %%d.pdf "%der%\%fold%\" >nul
	echo Berkas %%d.pdf telah dibuat
	)
goto end

:EPSBATCH
echo Bersiap mengekspor berkas SVG ke EPS
echo Berkas SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran berkas Nama berkas
echo ================================================
dir | findstr .svg
echo.
set /p svg="Berkas yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
set svgin="%svg%"
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:EPSBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg %svgin%
	inkscape %%d.svg --export-eps=%%d.eps --export-area-page --export-ps-level={3} --export-text-to-path --export-ignore-filters >nul
	del %%d.svg
	echo.
	move %%d.eps "%der%\%fold%\" >nul
	echo Berkas %%d.eps telah dibuat
	)
goto end

:PDFCMYKBATCH
echo Bersiap mengekspor berkas SVG ke PDF dengan color space CMYK
echo Berkas SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran berkas Nama berkas
echo ================================================
dir | findstr .svg
echo.
set /p svg="Berkas yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
set svgin="%svg%"
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:PDFCMYKBATCHPPROCESS

for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg %svgin%
	inkscape --export-area-page --without-gui --export-pdf=%%d-rgb.pdf %%d.svg
	gswin32 -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%%d.pdf %%d-rgb.pdf
	del %%d.svg
	del %%d-rgb.pdf
	move %%d.pdf "%der%\%fold%\" >nul
	echo.
	echo Berkas %%d.pdf dengan color space CMYK telah dibuat
	)
goto end

:SVGPLAINBATCH
echo Bersiap mengekspor berkas SVG ke SVG Plain
echo Berkas SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran berkas Nama berkas
echo ================================================
dir | findstr .svg
echo.
set /p svg="Berkas yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
set svgin="%svg%"
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:SVGPLAINBATCHPROCESS

for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg %svgin%
	move %%d.svg "%der%\%fold%\" >nul
	echo.
	echo Berkas %%d.svg telah dibuat
	)
goto end


:end
echo.
echo Permintaan anda telah diselesaikan
echo Berkas anda telah disimpan di %cd%\%fold%


:langsung_end
echo Sampai jumpa
endlocal
