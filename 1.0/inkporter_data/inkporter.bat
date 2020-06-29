@echo off
setlocal

if [%1] == [] goto main
if %1 == --about goto credits
if %1 == --help goto help


:main
rem inkporter-win version = 1.5
echo "|| Selamat Datang di                                                    ||"
echo "||  ___       _                     _                         _         ||"
echo "|| |_ _|_ __ | | ___ __   ___  _ __| |_ ___ _ __    __      _(_)_ __    ||"
echo "||  | || '_ \| |/ / '_ \ / _ \| '__| __/ _ \ '__|___\ \ /\ / / | '_ \   ||"
echo "||  | || | | |   <| |_) | (_) | |  | ||  __/ | |_____\ V  V /| | | | |  ||"
echo "|| |___|_| |_|_|\_\ .__/ \___/|_|   \__\___|_|        \_/\_/ |_|_| |_|  ||"
echo "||                |_|                                                   ||"
echo "||                                                Ver. 1.5 CLI Edition  ||"
echo.
echo Direktori saat ini %cd%
echo Berkas SVG yang tersedia :
echo.
echo Waktu dibuat            Ukuran berkas Nama berkas
echo ================================================
dir | findstr .svg
echo.
echo.
set /p svg="Berkas yang ingin anda proses : "
set svgin="%svg%"
:pilih
echo.
echo Silakan Pilih Target Ekspor Anda
echo 1) PNG         4) EPS-Default    7) WebP         
echo 2) PDF         5) SVG-Plain      8) Booklet (PDF)            
echo 3) PDF-CMYK    6) JPEG           9) ZIP (PNG + EPS-Default)    
echo.
REM echo Untuk informasi pengembang, Silakan ketik "about"
REM echo untuk mengunjungi laman bantuan online, Silakan ketik "help"
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
echo Silakan pilih target yang tersedia
echo Tekan Enter Untuk Kembali
if [%target%] = [] goto pilih
pause >nul
goto pilih

:credits
echo "||  ___       _                     _                         _         ||"
echo "|| |_ _|_ __ | | ___ __   ___  _ __| |_ ___ _ __    __      _(_)_ __    ||"
echo "||  | || '_ \| |/ / '_ \ / _ \| '__| __/ _ \ '__|___\ \ /\ / / | '_ \   ||"
echo "||  | || | | |   <| |_) | (_) | |  | ||  __/ | |_____\ V  V /| | | | |  ||"
echo "|| |___|_| |_|_|\_\ .__/ \___/|_|   \__\___|_|        \_/\_/ |_|_| |_|  ||"
echo "||                |_|                                                   ||"
echo "||                                                Ver. 1.5 CLI Edition  ||"
echo.
echo Inkporter CLI For Windows
echo Version 1.5
echo.
echo Tool ini dibuat untuk melakukan batch ekspor bedasarkan pola nama Object ID pada berkas .svg
echo melalui Inkscape command line bedasarkan pola pada nama Object ID
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
echo.
echo ====================================
echo inkporter.bat ditulis oleh Mas RJ95
echo Kota Tahu, 2020
echo.
goto void

:help
echo Petunjuk pemakaian :

echo saya akan menggunakan contoh bahwa saya memiliki berkas svg bernama drawing.svg
echo di direktori D:\project dengan objek yang ingin saya expor adalah obj-1 obj-2 obj-3 obj-4 obj-5 obj-6
echo.
echo untuk menggunakan inkporter
echo.
echo 1) Klik kanan pada file project svg, lalu pilih "Ekspor dengan Inkporter" lalu jendela inkporter-win akan muncul
echo 2) pilih format yang dinginkan (disini saya ambil contoh pdf maka saya akan memasukkan angka 2)
echo 3) lalu masukkan pola nama object id (obj)
echo 4) masukkan nama untuk folder baru untuk hasil ekspor
echo 5) berkas akan diproses dan selamat berkas berhasil terekspor

goto void

:PNG
set dpi = 96
set /p objID="Pola nama Object ID : "
set /p dpi="Tentukan nilai DPI hasil expor (default=96) : "
set /p fold="Buat folder hasil ekspor : "
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:PNGBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke PNG
for /f "delims=," %%d in ('%PROGRAMFILES%\Inkscape\bin\inkscape.com --query-all %svgin% ^| findstr %objID%') do (
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-id=%%d --export-filename=%%d.png --export-dpi=%dpi%  %svgin% >nul
	echo Berkas %%d.png telah dibuat
	move %%d.png "%der%\%fold%\" >nul
	)
goto end

:PDF
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
set svgin="%svg%"
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:PDFBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke PDF
for /f "delims=," %%d in ('%PROGRAMFILES%\Inkscape\bin\inkscape.com --query-all %svgin% ^| findstr %objID%') do (
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-id=%%d --export-id-only --export-plain-svg --export-filename=%%d.svg %svgin%
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-area-page  --export-filename=%%d.pdf %%d.svg
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

:EPSBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke EPS
for /f "delims=," %%d in ('%PROGRAMFILES%\Inkscape\bin\inkscape.com --query-all %svgin% ^| findstr %objID%') do (
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-id=%%d --export-id-only --export-plain-svg --export-filename=%%d.svg %svgin%
	%PROGRAMFILES%\Inkscape\bin\inkscape.com %%d.svg --export-filename=%%d.eps --export-type=eps --export-area-page --export-ps-level=3 --export-text-to-path --export-ignore-filters >nul
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

:PDFCMYKBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke PDF dengan color space CMYK
for /f "delims=," %%d in ('%PROGRAMFILES%\Inkscape\bin\inkscape.com --query-all %svgin% ^| findstr %objID%') do (
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-id=%%d --export-id-only --export-plain-svg --export-filename=%%d.svg %svgin%
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-area-page  --export-filename=%%d-rgb.pdf %%d.svg
	gs9.52\bin\gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%%d.pdf %%d-rgb.pdf
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

:SVGPLAINBATCHPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke SVG Plain
for /f "delims=," %%d in ('%PROGRAMFILES%\Inkscape\bin\inkscape.com --query-all %svgin% ^| findstr %objID%') do (
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-id=%%d --export-id-only --export-plain-svg --export-filename=%%d.svg %svgin%
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

:JPEGBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke JPEG
for /f "delims=," %%d in ('%PROGRAMFILES%\Inkscape\bin\inkscape.com --query-all %svgin% ^| findstr %objID%') do (
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-id=%%d --export-filename=%%d.png --export-dpi=%dpi% %svgin% >nul
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

:WEBPBATCHPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke WEBP
for /f "delims=," %%d in ('%PROGRAMFILES%\Inkscape\bin\inkscape.com --query-all %svgin% ^| findstr %objID%') do (
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-id=%%d --export-filename=%%d.png --export-dpi=%dpi%  %svgin% >nul
	echo Berkas %%d.png telah dibuat
	libwebp\bin\cwebp %%d.png -o %%d.webp
	move %%d.webp "%der%\%fold%\" >nul
	del %%d.png
	)
goto end

:BOOKLET
set /p objID="Pola nama Object ID : "
set /p namaberkas="Nama berkas output : "
echo Berkas akan disimpan di %cd%

:BOOKLETPPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke Booklet (PDF)
for /f "delims=," %%d in ('%PROGRAMFILES%\Inkscape\bin\inkscape.com --query-all %svgin% ^| findstr %objID%') do (
	echo sedang memproses Object ID = %%d
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-id=%%d --export-id-only --export-plain-svg --export-filename=%%d.svg %svgin%
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-area-page --export-type=pdf --export-filename=pdftemp-%%d.pdf %%d.svg
	ren pdftemp-%%d.pdf pdftemp-%%d.pdfx
	del %%d.svg
	)
dir /b | findstr pdftemp >> list.txt
echo.
gs9.52\bin\gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=%namaberkas% @list.txt
del *.pdfx
del list.txt
goto end

:BUNDLE
set /p objID="Pola nama Object ID : "
set /p fold="Buat folder hasil ekspor : "
echo Berkas akan disimpan di %cd%\%fold%
md "%fold%" 2>nul
set der=%cd%

:BUNDLEBATCHPROCESS
echo Bersiap mengekspor berkas %svgin% dari SVG ke ZIP Bundle (PNG + EPS Default)
for /f "delims=," %%d in ('%PROGRAMFILES%\Inkscape\bin\inkscape.com --query-all %svgin% ^| findstr %objID%') do (
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-id=%%d --export-plain-svg --export-filename=%%d.svg %svgin%
	%PROGRAMFILES%\Inkscape\bin\inkscape.com %%d.svg --export-filename=%%d.eps --export-type=eps --export-area-page --export-ps-level=3 --export-text-to-path --export-ignore-filters >nul
	%PROGRAMFILES%\Inkscape\bin\inkscape.com --export-id=%%d --export-filename=%%d.png %svgin% >nul
	7-Zip\7z a -tzip %%d.zip %%d.png %%d.eps
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