@echo off
setlocal

move %2 %2_inkporter-temp.svg >nul


:main
echo "|| Welcome to                                                           ||"
echo "||  ___       _                     _                         _         ||"
echo "|| |_ _|_ __ | | ___ __   ___  _ __| |_ ___ _ __    __      _(_)_ __    ||"
echo "||  | || '_ \| |/ / '_ \ / _ \| '__| __/ _ \ '__|___\ \ /\ / / | '_ \   ||"
echo "||  | || | | |   <| |_) | (_) | |  | ||  __/ | |_____\ V  V /| | | | |  ||"
echo "|| |___|_| |_|_|\_\ .__/ \___/|_|   \__\___|_|        \_/\_/ |_|_| |_|  ||"
echo "||                |_|                                                   ||"
echo Inkporter-GUI Processor for Windows
set exdir=%4
set target=%1
set svgin=%2_inkporter-temp.svg
set objID=%3
echo.
:pilihan 
if %target%== png goto PNG
if %target%== pdf goto PDF
if %target%== pdf_cmyk goto PDFCMYK
if %target%== eps goto EPS
if %target%== svg goto SVGPLAIN
if %target%== jpeg goto JPEG
if %target%== webp goto WEBP
if %target%== booklet goto BOOKLET
if %target%== booklet_cmyk goto BOOKLETCMYK
if %target%== bundle goto BUNDLE


:PNG
set dpi=%5
:PNGBATCHPPROCESS
echo Getting ready to process objects with "%objID%" pattern name to PNG

for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%4\%%d.png --export-dpi=%dpi%  %svgin%
	echo File %%d.png created
	)
goto end

:JPEG
set dpi=%5
set bgcol=%6
set quality=%7
:JPEGBATCHPPROCESS
echo Getting ready to process objects with "%objID%" pattern name to JPEG
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%4\temp-%%d.png --export-dpi=%dpi% %svgin% >nul
	magick convert %4\temp-%%d.png -background %6 -flatten -quality %7 -colorspace %8 %4\%%d.jpeg
	echo File %%d.jpeg created
	del %4\temp-%%d.png
	)
goto end

:PDF
:PDFBATCHPPROCESS
echo Getting ready to process objects with "%objID%" pattern name to PDF
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%4\%%d.svg %svgin%
	inkscape --export-area-page --export-pdf=%4\%%d.pdf %4\%%d.svg
	del %4\%%d.svg
	echo File %%d.pdf created
	)
goto end

:PDFCMYK
:PDFCMYKBATCHPPROCESS
echo Getting ready to process objects with "%objID%" pattern name to PDF dengan color space CMYK
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%4\%%d.svg %svgin%
	inkscape --export-area-page  --export-pdf=%4\%%d-rgb.pdf %4\%%d.svg
	gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%4\%%d-cmyk.pdf %4\%%d-rgb.pdf
	del %4\%%d.svg
	del %4\%%d-rgb.pdf
	echo File %%d.pdf with CMYK color space created
	)
goto end

:SVGPLAIN
:SVGPLAINBATCHPROCESS
echo Getting ready to process objects with "%objID%" pattern name to SVG Plain
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%4\%%d.svg %svgin%
	echo File %%d.svg created
	)
goto end

:EPS
:EPSBATCHPPROCESS
echo Getting ready to process objects with "%objID%" pattern name to EPS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%4\temp-%%d.svg %svgin%
	inkscape %4\temp-%%d.svg --export-eps=%4\%%d.eps --export-area-page --export-ps-level=3 --export-text-to-path --export-ignore-filters >nul
	del %4\temp-%%d.svg
	echo File %%d.eps created
	)
goto end

:WEBP
echo.
:WEBPBATCHPPROCESS
echo Getting ready to process objects with "%objID%" pattern name to WEBP
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%4\%%d.png --export-dpi=%dpi% %svgin% >nul
	cwebp %4\%%d.png -o %4\%%d.webp
	echo File %%d.webp created
	del %4\%%d.png
	)
goto end

:BOOKLET
set namaFile=%objID%-booklet.pdf
:BOOKLETPPROCESS
echo Getting ready to process objects with "%objID%" pattern name to Booklet (PDF)
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	echo Processing %%d
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%4\%%d.svg %svgin%
	echo svg created
	inkscape --export-area-page --export-pdf=%4\pdftemp-%%d.pdf %4\%%d.svg
	echo pdf created
	move %4\pdftemp-%%d.pdf %4\pdftemp-%%d.pdfx
	del %4\%%d.svg
	)
pushd %4
REM export all pdfx to list.txt
rem based on answer on stackoverflow : https://stackoverflow.com/questions/19297935/naturally-sort-files-in-batch
(
setlocal enabledelayedexpansion
for %%f in (*.pdfx) do (
set numbr=00000000000000000000000000000000%%f
set numbr=!numbr:~-36!
set $!numbr!=%%f
)
for /f "tokens=1,* delims==" %%f in ('set $0') do echo %%g
) >> list.txt
echo.
gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=%namaFile% @list.txt
pause
del *.pdfx
del list.txt
goto end

:BOOKLETCMYK
set namaFile=%objID%-booklet_cmyk.pdf
:BOOKLETCMYKPPROCESS
echo Getting ready to process objects with "%objID%" pattern name to Booklet (PDF)
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	echo Processing %%d
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%4\temp-%%d.svg %svgin%
	inkscape --export-area-page  --export-pdf=%4\%%d-rgb.pdf %4\temp-%%d.svg
	gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%4\%%d-temp.pdf %4\%%d-rgb.pdf
	move %4\%%d-temp.pdf %4\pdftemp-%%d.pdfx
	del %4\%%d-rgb.pdf
	del %4\temp-%%d.svg
	)
pushd %4
REM export all pdfx to list.txt
rem based on answer in stackoverflow : https://stackoverflow.com/questions/19297935/naturally-sort-files-in-batch
(
setlocal enabledelayedexpansion
for %%f in (*.pdfx) do (
set numbr=00000000000000000000000000000000%%f
set numbr=!numbr:~-36!
set $!numbr!=%%f
)
for /f "tokens=1,* delims==" %%f in ('set $0') do echo %%g
) >> list.txt

echo.
gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=%namaFile% @%4\list.txt
del *.pdfx
del list.txt
goto end

:BUNDLE
set dpi=%5
:BUNDLEBATCHPROCESS
echo Getting ready to process objects with "%objID%" pattern name to ZIP Bundle (PNG + EPS Default)
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%4\%%d.png --export-dpi=%dpi%  %svgin%
	echo.
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%4\temp-%%d.svg %svgin%
	echo.
	inkscape %4\temp-%%d.svg --export-eps=%4\%%d.eps --export-area-page --export-ps-level=3 --export-text-to-path --export-ignore-filters >nul
	echo.
	del %4\temp-%%d.svg
	7z a -tzip %4\%%d.zip %4\%%d.png %4\%%d.eps
	del %4\%%d.svg
	del %4\%%d.png
	del %4\%%d.eps
	echo File %%d.zip created
	)
goto end

:end
echo.
REM echo Permintaan anda telah diselesaikan
REM echo File anda telah disimpan di %cd%\%fold%
REM echo tekan enter untuk keluar
del %svgin%
rem pause >nul

:langsung_end
endlocal
exit
:void