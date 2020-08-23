@echo off
setlocal

move %2 %2_inkporter-temp.svg >nul 2>nul

set exdir=%4\
set target=%1
set svgin=%2_inkporter-temp.svg
set objID=%3
set dpi=%5

if [%1]==[] goto main

REM pushd %4 2>nul

:main
echo "|| Welcome to :                                                         ||"
echo "||  ___       _                     _                         _         ||"
echo "|| |_ _|_ __ | | ___ __   ___  _ __| |_ ___ _ __    __      _(_)_ __    ||"
echo "||  | || '_ \| |/ / '_ \ / _ \| '__| __/ _ \ '__|___\ \ /\ / / | '_ \   ||"
echo "||  | || | | |   <| |_) | (_) | |  | ||  __/ | |_____\ V  V /| | | | |  ||"
echo "|| |___|_| |_|_|\_\ .__/ \___/|_|   \__\___|_|        \_/\_/ |_|_| |_|  ||"
echo "||                |_|                                                   ||"
echo "||                                                                      ||"
echo "|| For Inkscape 0.92.x                                     Version 1.5  ||"
echo.  

if [%1]==[] goto mainpilih
if %1==--about goto credits
if %1==--help goto help


:extensions_switcher

pushd %4

if %target%== png goto PNGBATCHPPROCESS
if %target%== pdf goto PDFBATCHPPROCESS
if %target%== pdf_cmyk goto PDFCMYKBATCHPPROCESS
if %target%== eps goto EPSBATCHPPROCESS
if %target%== svg goto SVGPLAINBATCHPROCESS
if %target%== jpeg goto JPEGBATCHPPROCESS
if %target%== jpeg_cmyk goto JPEGCMYKBATCHPPROCESS
if %target%== webp goto WEBPBATCHPPROCESS
if %target%== booklet goto BOOKLETPPROCESS
if %target%== booklet_cmyk goto BOOKLETCMYKPROCESS
if %target%== bundle goto BUNDLEBATCHPROCESS

goto pilihtarget

:mainpilih
REM set exdir="%cd%"
REM echo exdir=%exdir%
echo.
echo Available SVG files on %cd% :
echo.
echo Date Created                 File Size File Name
echo ================================================
dir | findstr .svg
set /p svg="Selected file : "
echo.

goto pilihtarget

:pilihtarget
REM set exdir ="%cd%"
REM echo exdir=%exdir%
set svgin=%1
if [%1]==[] set svgin="%svg%"
echo Selected file = %svgin%
echo Please select your output format :
echo 1) PNG                6) JPEG               11) ZIP (PNG + EPS-Default)
echo 2) PDF                7) JPEG-CMYK
echo 3) PDF-CMYK           8) WebP
echo 4) EPS-Default        9) Booklet (PDF)
echo 5) SVG-Plain          10 Booklet (PDF-CMYK)
echo.
set /p target=Your Choice : 
if %target%== 1 goto PNG
if %target%== 2 goto PDF
if %target%== 3 goto PDFCMYK
if %target%== 4 goto EPS
if %target%== 5 goto SVGPLAIN
if %target%== 6 goto JPEG
if %target%== 7 goto JPEGCMYK
if %target%== 8 goto WEBP
if %target%== 9 goto BOOKLET
if %target%== 10 goto BOOKLETCMYK
if %target%== 11 goto BUNDLE


if %target%== exit goto langsung_end
echo Please select from available file formats
echo Press enter to go back...
pause >nul
goto pilihtarget

:credits
echo.
echo Original bash script created by Rania Amina
echo Windows .bat port created by maslanang (RJ95)
echo Supported by GimpScape ID
echo Licensed Under GPLv3
echo. 
echo Used Dependencies
echo Inkscape : https://inkscape.org/
echo Ghostscript : https://www.ghostscript.com/
echo ImageMagick : https://www.imagemagick.org/
echo 7-Zip : https://www.7-zip.org/
echo libwebp : https://developers.google.com/speed/webp/

goto void

:help
echo Inkporter-win 1.5 For Inkscape 0.92.x
echo.
echo Usage :
echo inkporter                 runs inkporter and inkporter will prompts you to choose .svg file
echo inkporter [svg_file]      runs inkporter without being prompted to choose svg file
echo.
echo Parameters :
echo --help                    display this message
echo --about                   display version and credits
echo. 
goto void

:PNG
echo Selected Format : PNG

set /p objID="Object ID pattern : "
set /p dpi="DPI (96 for default) :  "
if [%dpi%]==[] set dpi=96
set /p fold="Make a new folder for exported files : "
md "%fold%" 2>nul
set der=%cd%
set exdir="%cd%\%fold%"
if [%fold%]==[] set exdir="%cd%"
echo your objects will be saved in %exdir%

:PNGBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%exdir%\%%d.png --export-dpi=%dpi%  %svgin% >nul
	echo %%d.png has been created
	echo.
	)
goto end

:PDF
echo Selected Format : PDF

set /p objID="Object ID pattern : "
set /p fold="Make a new folder for exported files : "
md "%fold%" 2>nul
set der=%cd%
set exdir="%cd%\%fold%"
if [%fold%]==[] set exdir="%cd%"
echo your objects will be saved in %exdir%

:PDFBATCHPPROCESS

for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%exdir%\%%d-temp.svg %svgin%
	inkscape --export-area-page --without-gui --export-pdf=%exdir%\%%d.pdf %exdir%\%%d-temp.svg
	del %exdir%\%%d-temp.svg
	echo.
	echo %%d.pdf has been created
	)
goto end

:EPS
echo Selected Format : EPS

set /p objID="Object ID pattern : "
set /p fold="Make a new folder for exported files : "
md "%fold%" 2>nul
set der=%cd%
set exdir="%cd%\%fold%"
if [%fold%]==[] set exdir="%cd%"
echo your objects will be saved in %exdir%

:EPSBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%exdir%\%%d-temp.svg %svgin%
	inkscape %exdir%\%%d-temp.svg --export-eps=%exdir%\%%d.eps --export-area-page --export-ps-level={3} --export-text-to-path --export-ignore-filters >nul 2>nul
	del %exdir%\%%d-temp.svg
	echo.
	echo %%d.eps has been created
	)
goto end

:PDFCMYK
echo "Selected Format : PDF with CMYK colorspace"

set /p objID="Object ID pattern : "
set /p fold="Make a new folder for exported files : "
md "%fold%" 2>nul
set der=%cd%
set exdir="%cd%\%fold%"
if [%fold%]==[] set exdir="%cd%"
echo your objects will be saved in %exdir%

:PDFCMYKBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	echo now processing %%d
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%exdir%\%%d-temp.svg %svgin%
	inkscape --export-area-page --without-gui --export-pdf=%exdir%\%%d-rgb.pdf %exdir%\%%d-temp.svg
	gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%exdir%\%%d-cmyk.pdf %exdir%\%%d-rgb.pdf
	del %exdir%\%%d-temp.svg
	del %exdir%\%%d-rgb.pdf
	echo %%d-cmyk.pdf has been created
	echo.
	)
goto end

:SVGPLAIN
echo Selected Format : SVG Plain

set /p objID="Object ID pattern : "
set /p fold="Make a new folder for exported files : "
md "%fold%" 2>nul
set der=%cd%
set exdir="%cd%\%fold%"
if [%fold%]==[] set exdir="%cd%"
echo your objects will be saved in %exdir%

:SVGPLAINBATCHPROCESS

for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%exdir%\%%d.svg %svgin%
	echo.
	echo %%d.svg has been created
	)
goto end


:JPEG
echo Selected Format : JPEG

set /p objID="Object ID pattern : "
set /p dpi="DPI (just type 96 for default) :  "
if [%dpi%]==[] set dpi=96
set /p fold="Make a new folder for exported files : "
set exdir="%cd%\%fold%"
if [%fold%]==[] set exdir="%cd%"
md "%fold%" 2>nul
set der=%cd%

echo your objects will be saved in %exdir%

:JPEGBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%exdir%\%%d-temp.png --export-dpi=%dpi% --file=%svgin% >nul
	magick convert %exdir%\%%d-temp.png -background #ffffff -flatten -quality 100 %exdir%\%%d.jpeg
	del %exdir%\%%d-temp.png
	echo %%d.jpeg has been created
	echo.
	)
goto end

:JPEGCMYK
echo Selected Format : JPEG-CMYK

set /p objID="Object ID pattern : "
set /p dpi="DPI (just type 96 for default) :  "
if [%dpi%]==[] set dpi=96
set /p fold="Make a new folder for exported files : "

md "%fold%" 2>nul
set der=%cd%
set exdir="%cd%\%fold%"
if [%fold%]==[] set exdir="%cd%"
echo your objects will be saved in %exdir%

:JPEGCMYKBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%exdir%\%%d-temp.png --export-dpi=%dpi% %svgin% >nul
	magick convert %exdir%\%%d-temp.png -background #ffffff -flatten -quality 100 -colorspace CMYK %exdir%\%%d-cmyk.jpeg
	echo %%d-cmyk.jpeg has been created
	echo.
	del %exdir%\%%d-temp.png
	)
goto end


:WEBP
set dpi = 96
echo Selected Format : WEBP

set /p objID="Object ID pattern : "
set /p dpi="DPI (just type 96 for default) :  "
if [%dpi%]==[] set dpi=96
set /p fold="Make a new folder for exported files : "

md "%fold%" 2>nul
set der=%cd%
set exdir="%cd%\%fold%"
if [%fold%]==[] set exdir="%cd%"
echo your objects will be saved in %exdir%



:WEBPBATCHPPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-png=%exdir%\%%d-temp.png --export-dpi=%dpi%  %svgin% >nul
	cwebp %exdir%\%%d-temp.png -o %exdir%\%%d.webp
	del %exdir%\%%d-temp.png
	echo %%d.webp has been created
	echo.
	)
goto end

:BOOKLET
echo Selected Format : Booklet (PDF)
set /p objID="Object ID pattern : "
REM set /p namaberkas="Output filename (put .pdf in the end, unless you want something else) : "
set exdir="%cd%"
echo your objects will be saved in %exdir%
echo.

:BOOKLETPPROCESS
set namaberkas=booklet_%objID%.pdf
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	echo Now processing %%d
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%exdir%\%%d-temp.svg --file=%svgin%
	inkscape --export-area-page --without-gui --export-pdf=%exdir%\pdftemp-%%d.pdfx %exdir%\%%d-temp.svg
	del %exdir%\%%d-temp.svg
	)
pushd %exdir%
dir /b | findstr pdftemp >> list.txt
echo.
gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=%namaberkas% @list.txt
del *.pdfx
del list.txt
goto langsung_end

:BOOKLETCMYK
echo Selected Format : Booklet (PDF-CMYK)
set /p objID="Object ID pattern : "
REM set /p namaberkas="Output filename (put .pdf in the end, unless you want something else) : "
set exdir="%cd%"
echo your objects will be saved in %cd%\%fold%

:BOOKLETCMYKPROCESS
set namaberkas=booklet_%objID%_cmyk.pdf
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	echo Now processing %%d
	inkscape --export-id=%%d --export-id-only --export-plain-svg=%exdir%\%%d-temp.svg --file=%svgin%
	
	inkscape --export-area-page --without-gui --export-pdf=%exdir%\%%d-rgb.pdf %exdir%\%%d-temp.svg
	
	gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%exdir%\%%d-cmyk.pdf %exdir%\%%d-rgb.pdf >nul
	move %exdir%\%%d-cmyk.pdf %exdir%\%%d-pdftemp-cmyk.pdfx >nul
	del %exdir%\%%d-rgb.pdf
	del %exdir%\%%d-temp.svg
	)
pushd %exdir%
dir /b | findstr pdftemp >> list.txt
echo.
gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=%namaberkas% @list.txt
del *.pdfx
del list.txt
goto langsung_end

:BUNDLE
echo Selected Format : ZIP Bundle (PNG + EPS Default)

set /p objID="Object ID pattern : "
set /p fold="Make a new folder for exported files : "
set exdir="%cd%\%fold%"
if [%fold%]==[] set exdir="%cd%"
echo your objects will be saved in %exdir%
md "%fold%" 2>nul
set der=%cd%

:BUNDLEBATCHPROCESS
md %exdir%\temp

for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg=%exdir%\temp\%%d-temp.svg %svgin%
	inkscape %exdir%\temp\%%d-temp.svg --export-eps=%exdir%\temp\%%d.eps --export-area-page --export-ps-level={3} --export-text-to-path --export-ignore-filters >nul 2>nul
	inkscape --export-id=%%d --export-png=%exdir%\temp\%%d.png %svgin% >nul
	7z a -tzip %exdir%\%%d.zip %exdir%\temp\%%d.png %exdir%\temp\%%d.eps
	echo.
	echo %%d.zip has been created
	)
rmdir /s /q %exdir%\temp
goto end

:end
echo COMPLETE
del %2_inkporter-temp.svg >nul 2>nul
if not [%3]==[] exit

:langsung_end
echo See you

:void
endlocal
