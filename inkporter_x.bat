@echo off
setlocal

:main
rem inkporter version = 1.5
REM echo Untuk informasi pengembang, Silakan ketik "about"
REM echo untuk mengunjungi laman bantuan online, Silakan ketik "help"
:pilihan
echo "|| Selamat Datang di                                                    ||"
echo "||  ___       _                     _                         _         ||"
echo "|| |_ _|_ __ | | ___ __   ___  _ __| |_ ___ _ __    __      _(_)_ __    ||"
echo "||  | || '_ \| |/ / '_ \ / _ \| '__| __/ _ \ '__|___\ \ /\ / / | '_ \   ||"
echo "||  | || | | |   <| |_) | (_) | |  | ||  __/ | |_____\ V  V /| | | | |  ||"
echo "|| |___|_| |_|_|\_\ .__/ \___/|_|   \__\___|_|        \_/\_/ |_|_| |_|  ||"
echo "||                |_|                                                   ||"
echo File yang dipilih : %1
echo.
echo Silakan Pilih Target Ekspor Anda
echo 1) PNG         4) EPS-Default    7) WebP         
echo 2) PDF         5) SVG-Plain      8) Booklet (PDF)            
echo 3) PDF-CMYK    6) JPEG           9) ZIP (PNG + EPS-Default)    
echo.
set /p target=Pilihan Anda : 
set svgin=%1
if %target%== 1 goto PNG
if %target%== 2 goto PDF
if %target%== 3 goto PDFCMYK
if %target%== 4 goto EPS
if %target%== 5 goto SVGPLAIN
if %target%== 6 goto JPEG
if %target%== 7 goto WEBP
if %target%== 8 goto BOOKLET
if %target%== 9 goto BUNDLE
echo Silakan pilih target yang tersedia
echo Tekan Enter Untuk Kembali
pause >nul
goto pilihan

:PNG
set dpi = 96
set /p objID="Pola nama Object ID : "
set /p dpi="Tentukan nilai DPI hasil expor (default=96) : "
set /p fold="Buat folder hasil ekspor : "
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%
echo.
:PNGBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke PNG
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-filename=%%d.png --export-dpi=%dpi%  %svgin% >nul
	echo Berkas %%d.png telah dibuat
	move %%d.png "%der%\%fold%\" >nul
	)
goto end

:PDF
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%
echo.
:PDFBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke PDF
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg --export-filename=%%d.svg %svgin%
	inkscape --export-area-page  --export-filename=%%d.pdf %%d.svg
	del %%d.svg
	move %%d.pdf "%der%\%fold%\" >nul
	echo Berkas %%d.pdf telah dibuat
	)
goto end

:EPS
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%
echo.
:EPSBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke EPS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg --export-filename=%%d.svg %svgin%
	inkscape %%d.svg --export-filename=%%d.eps --export-type=eps --export-area-page --export-ps-level=3 --export-text-to-path --export-ignore-filters >nul
	del %%d.svg
	move %%d.eps "%der%\%fold%\" >nul
	echo Berkas %%d.eps telah dibuat
	)
goto end

:PDFCMYK
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%
echo.
:PDFCMYKBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke PDF dengan color space CMYK
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg --export-filename=%%d.svg %svgin%
	inkscape --export-area-page  --export-filename=%%d-rgb.pdf %%d.svg
	gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%%d.pdf %%d-rgb.pdf
	del %%d.svg
	del %%d-rgb.pdf
	move %%d.pdf "%der%\%fold%\" >nul
	echo Berkas %%d.pdf dengan color space CMYK telah dibuat
	)
goto end

:SVGPLAIN
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%
echo.
:SVGPLAINBATCHPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke SVG Plain
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg --export-filename=%%d.svg %svgin%
	move %%d.svg "%der%\%fold%\" >nul
	echo Berkas %%d.svg telah dibuat
	)
goto end


:JPEG
set dpi = 96
set /p objID="Pola nama Object ID : "
set /p dpi="Tentukan nilai DPI hasil expor (default=96) : "
set /p fold="Buat folder hasil ekspor : "
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%
echo.
:JPEGBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke JPEG
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-filename=%%d.png --export-dpi=%dpi% %svgin% >nul
	magick convert %%d.png -background #ffffff -flatten -quality 100 %%d.jpeg
	echo Berkas %%d.jpeg telah dibuat
	del %%d.png
	move %%d.jpeg "%der%\%fold%\" >nul
	)
goto end

:WEBP
set dpi = 96
set /p objID="Pola nama Object ID : "
set /p dpi="Tentukan nilai DPI hasil expor (default=96) : "
set /p fold="Buat folder hasil ekspor : "
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%
echo.
:WEBPBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke WEBP
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-filename=%%d.png --export-dpi=%dpi%  %svgin% >nul
	echo Berkas %%d.png telah dibuat
	cwebp %%d.png -o %%d.webp
	move %%d.webp "%der%\%fold%\" >nul
	del %%d.png
	)
goto end

:BOOKLET
set /p objID="Pola nama Object ID : "
set /p namaberkas="Nama berkas output : "
echo Berkas akan disimpan di %cd%
echo.
:BOOKLETPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke Booklet (PDF)
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	echo sedang memproses Object ID = %%d
	inkscape --export-id=%%d --export-id-only --export-plain-svg --export-filename=%%d.svg %svgin%
	inkscape --export-area-page --export-type=pdf --export-filename=pdftemp-%%d.pdf %%d.svg
	ren pdftemp-%%d.pdf pdftemp-%%d.pdfx
	del %%d.svg
	)
dir /b | findstr pdftemp >> list.txt
echo.
gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=%namaberkas% @list.txt
del *.pdfx
del list.txt
goto end

:BUNDLE
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%
echo.
:BUNDLEBATCHPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke ZIP Bundle (PNG + EPS Default)
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg --export-filename=%%d.svg %svgin%
	inkscape %%d.svg --export-filename=%%d.eps --export-type=eps --export-area-page --export-ps-level=3 --export-text-to-path --export-ignore-filters >nul
	inkscape --export-id=%%d --export-filename=%%d.png %svgin% >nul
	7z a -tzip %%d.zip %%d.png %%d.eps
	del %%d.svg
	del %%d.png
	del %%d.eps
	move %%d.zip "%der%\%fold%\" >nul
	echo Berkas %%d.zip telah dibuat
	)
goto end

:end
echo.
echo Permintaan anda telah diselesaikan
echo Berkas anda telah disimpan di %cd%\%fold%
echo tekan enter untuk keluar 
pause >nul

:langsung_end
endlocal

:void
