@echo off
setlocal
:main
cls
rem inkporter version = 1.5
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
echo 6) JPEG
echo 7) WebP
echo 8) Booklet (PDF)
echo 9) ZIP (PNG + EPS-Default)
echo.
echo Untuk informasi pengembang, Silakan ketik "about"
echo untuk mengunjungi laman bantuan online, Silakan ketik "help"
echo.
set /p target=Pilihan Anda : 
if %target%== 1 goto PNG
if %target%== 2 goto PDF
if %target%== 3 goto PDFCMYK
if %target%== 4 goto EPS
if %target%== 5 goto SVGPLAIN
if %target%== 6 goto JPEG
if %target%== 7 goto WEBP
if %target%== 8 goto BOOKLET
if %target%== 9 goto BUNDLE
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
echo Inkporter CLI For Windows
echo Version 1.4b
echo.
echo Tool ini dibuat untuk melakukan batch ekspor pada berkas .svg melalui Inkscape command line
echo bedasarkan pola pada nama Object ID
echo ===========================================================================================
echo Batch file ini merupakan hasil re-write dari inkporter yang ditulis dalam bash oleh Rania Amina
echo ================================================================================================
echo Inkporter menggunakan teknologi dari :
echo.
echo Inkscape
echo Ghostscript
echo WebP
echo ImageMagick
echo 7zip
echo ====================================
echo inkporter.bat ditulis oleh Mas RJ95
echo Kota Tahu, 2020
echo.
echo Tekan ENTER untuk kembali
pause >nul
goto main

:help
start https://catatan.raniaamina.id/tools/inkporter-win
goto main

:PNG
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
set /p dpi="Tentukan nilai DPI hasil expor (default=96) : "
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

:PDF
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
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%%d.svg %svgin%
	inkscape --export-area-page --without-gui --export-pdf=%%d.pdf %%d.svg
	del %%d.svg
	echo.
	move %%d.pdf "%der%\%fold%\" >nul
	echo Berkas %%d.pdf telah dibuat
	)
goto end

:EPS
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
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%%d.svg %svgin%
	inkscape %%d.svg --export-eps=%%d.eps --export-area-page --export-ps-level={3} --export-text-to-path --export-ignore-filters >nul
	del %%d.svg
	echo.
	move %%d.eps "%der%\%fold%\" >nul
	echo Berkas %%d.eps telah dibuat
	)
goto end

:PDFCMYK
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
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%%d.svg %svgin%
	inkscape --export-area-page --without-gui --export-pdf=%%d-rgb.pdf %%d.svg
	gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%%d.pdf %%d-rgb.pdf
	del %%d.svg
	del %%d-rgb.pdf
	move %%d.pdf "%der%\%fold%\" >nul
	echo.
	echo Berkas %%d.pdf dengan color space CMYK telah dibuat
	)
goto end

:SVGPLAIN
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
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%%d-uc.svg %svgin%
	move %%d.svg "%der%\%fold%\" >nul
	echo.
	echo Berkas %%d.svg telah dibuat
	)
goto end


:JPEG
set dpi = 96
echo Bersiap mengekspor berkas SVG ke JPEG
echo Berkas SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran berkas Nama berkas
echo ================================================
dir | findstr .svg
echo.
set /p svg="Berkas yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p dpi="Tentukan nilai DPI hasil expor (default=96) : "
set /p fold="Buat folder hasil ekspor : "

set svgin="%svg%"
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:JPEGBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%%d.png --export-dpi=%dpi% %svgin% >nul
	magick convert %%d.png -background #ffffff -flatten -quality 100 %%d.jpeg
	echo Berkas %%d.jpeg telah dibuat
	echo.
	del %%d.png
	move %%d.jpeg "%der%\%fold%\" >nul
	)
goto end

:WEBP
set dpi = 96
echo Bersiap mengekspor berkas SVG ke WEBP
echo Berkas SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran berkas Nama berkas
echo ================================================
dir | findstr .svg
echo.
set /p svg="Berkas yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p dpi="Tentukan nilai DPI hasil expor (default=96) : "
set /p fold="Buat folder hasil ekspor : "

set svgin="%svg%"
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:WEBPBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%%d.png --export-dpi=%dpi%  %svgin% >nul
	echo Berkas %%d.png telah dibuat
	echo.
	cwebp %%d.png -o %%d.webp
	move %%d.webp "%der%\%fold%\" >nul
	del %%d.png
	)
goto end

:BOOKLET
echo Bersiap mengekspor berkas SVG ke Booklet (PDF)
echo Berkas SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran berkas Nama berkas
echo ================================================
dir | findstr .svg
echo.
set /p svg="Berkas yang ingin anda proses : "
set /p objID="Pola nama Object ID : "
set /p namaberkas="Nama berkas output : "
set svgin="%svg%"
echo Berkas akan disimpan di %cd%

:BOOKLETPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	echo sedang memproses Object ID = %%d
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%%d.svg %svgin%
	inkscape --export-area-page --without-gui --export-pdf=pdftemp-%%d.pdfx %%d.svg
	del %%d.svg
	)
dir /b | findstr pdftemp >> list.txt
echo.
gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=%namaberkas% @list.txt
del *.pdfx
del list.txt
goto end

:BUNDLE
echo Bersiap mengekspor berkas SVG ke ZIP Bundle (PNG + EPS Default)
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

:BUNDLEBATCHPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%%d.svg %svgin%
	inkscape %%d.svg --export-eps=%%d.eps --export-area-page --export-ps-level={3} --export-text-to-path --export-ignore-filters >nul
	inkscape --export-id=%%d --export-png=%%d.png %svgin% >nul
	7z a -tzip %%d.zip %%d.png %%d.eps
	del %%d.svg
	del %%d.png
	del %%d.eps
	move %%d.zip "%der%\%fold%\" >nul
	echo.
	echo Berkas %%d.zip telah dibuat
	)
goto end

:end
echo.
echo Permintaan anda telah diselesaikan
echo Berkas anda telah disimpan di %cd%\%fold%


:langsung_end
echo Sampai jumpa
endlocal
