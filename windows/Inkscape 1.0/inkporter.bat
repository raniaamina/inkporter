:: Inkporter Core for Windows
:: Version 1.7

@echo off
setlocal

:: Dictionary

:: svg = SVG File Input
:: target = Export Format
:: objID = ID Pattern
:: exdir = Export Directory
:: dpi = DPI Number
:: bgcol = Background Color (in hex)
:: quality = Quality


:: Basic Usage
:: Inkporter [SVG_FILE] [TARGET] [ID_PATTERN] [EXPORT_DIRECTORY] [OPTIONS]

:: SVG PDF EPS (NO OPTIONS)
:: Inkporter [SVG_FILE] [TARGET] [ID_PATTERN] [EXPORT_DIRECTORY]

:: PNG WEBP
:: Inkporter [SVG_FILE] [TARGET] [ID_PATTERN] [EXPORT_DIRECTORY] [DPI]

:: JPEG
:: Inkporter [SVG_FILE] [TARGET] [ID_PATTERN] [EXPORT_DIRECTORY] [DPI] [COLOR_SPACE] [HEX_BG_COLOR] [QUALITY] 

:: ZIP
:: Inkporter [SVG_FILE] [ZIP] [ID_PATTERN]



set svgin=%1
set target=%2
set objID=%3
set exdir=%4
set dpi=%5
set colsp=%6
set bgcol=%7
set quality=%8


if [%4]==[] set exdir="%cd%"
if [%5]==[] set dpi=96
if [%6]==[] set colsp=rgb
if [%7]==[] set quality=100
if [%8]==[] set bgcol=#ffffff

:main
echo "|| Welcome to :                                                         ||"
echo "||  ___       _                     _                         _         ||"
echo "|| |_ _|_ __ | | ___ __   ___  _ __| |_ ___ _ __    __      _(_)_ __    ||"
echo "||  | || '_ \| |/ / '_ \ / _ \| '__| __/ _ \ '__|___\ \ /\ / / | '_ \   ||"
echo "||  | || | | |   <| |_) | (_) | |  | ||  __/ | |_____\ V  V /| | | | |  ||"
echo "|| |___|_| |_|_|\_\ .__/ \___/|_|   \__\___|_|        \_/\_/ |_|_| |_|  ||"
echo "||                |_|                                                   ||"
echo "||                                                                      ||"
echo "|| For Inkscape 1.0                                                     ||"
echo.  

goto %target%

:prompt
echo.
echo Available SVG files on %cd% :
echo.
echo Date Created                 File Size File Name
echo ================================================
dir | findstr .svg
set /p svgin="Selected file : "
echo.

echo Selected file = %svgin%
echo Please select your output format :
echo.
echo  * Vector               * Bitmaps
echo  1. SVG                  7. PNG
echo  2. PDF                  8. WEBP
echo  3. PDF-CMYK             9. JPEG
echo  4. EPS-Default         10. Booklet (PDF-Raster)
echo  5. Booklet (PDF)
echo  6. Booklet (PDF-CMYK)
echo.
set /p target=Your Choice :
 
set /p objID="Object ID pattern : "
set /p fold="Make a new folder for exported files : "
md "%fold%" 2>nul
set exdir=%cd%\%fold%


if [%fold%]==[] set exdir="%cd%"
:: Vectors
if %target%== 1 goto SVG
if %target%== 2 goto PDF
if %target%== 3 goto PDFCMYK
if %target%== 4 goto EPS
if %target%== 5 goto BOOK
if %target%== 6 goto BOOKCMYK

:: Bitmaps
if %target%== 7 goto DPIPROMPT
if %target%== 8 goto DPIPROMPT
if %target%== 9 goto DPIPROMPT
if %target%== 10 goto DPIPROMPT
if %target%== 12  goto DPIPROMPT
if %target%== 13  goto DPIPROMPT


:: Export targets that doesn't need any OPTIONS

::===SVG=====================================================================================
:svg
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg --export-filename=%exdir%\%%d.svg %svgin%
	echo.
	echo %%d.svg has been created
	)
goto end


::===PDF=====================================================================================
:pdf
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-area-page --export-id-only --export-filename=%exdir%\%%d.pdf %svgin%
	echo.
	echo %%d.pdf has been created
	)
	
goto end


::===PDF-CMYK====================================================================================
:pdf-cmyk
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	echo.
	inkscape --export-id=%%d --export-id-only --export-filename=%exdir%\%%d-rgb-temp.pdf %svgin%
	gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%exdir%\%%d-cmyk.pdf %exdir%\%%d-rgb-temp.pdf
	del %exdir%\%%d-rgb-temp.pdf
	echo %%d-cmyk.pdf has been created
	)
goto end

::===EPS====================================================================================
:eps
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape %svgin% --export-id=%%d --export-id-only --export-filename=%exdir%\%%d.eps --export-type=eps --export-area-page --export-ps-level=3 --export-text-to-path --export-ignore-filters >nul 2>nul
	echo %%d.eps has been created
	)
goto end


::===Book====================================================================================
:book
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-filename=%exdir%\%%d-booklet-temp.pdf %svgin%
	move %exdir%\%%d-booklet-temp.pdf %exdir%\%%d-booklet-temp.pdfx >nul
	echo Processing %%d
	)
	
pushd %exdir%
:: based on answer on stackoverflow : https://stackoverflow.com/questions/19297935/naturally-sort-files-in-batch
(
setlocal enabledelayedexpansion
for %%f in (*.pdfx) do (
set numbr=00000000000000000000000000000000%%f
set numbr=!numbr:~-36!
set $!numbr!=%%f
)
for /f "tokens=1,* delims==" %%f in ('set $0') do echo %%g
) >>inkporter-pagelist.txt

echo.
set filename=%objID%_booklet.pdf
gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=%filename% @inkporter-pagelist.txt
del *.pdfx
del inkporter-pagelist.txt
goto end

::===Book-CMYK====================================================================================
:book-cmyk
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-filename=%exdir%\%%d-booklet-rgb-temp.pdf %svgin%
	gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%exdir%\%%d-booklet-cmyk-temp.pdf %exdir%\%%d-booklet-rgb-temp.pdf
	move %exdir%\%%d-booklet-cmyk-temp.pdf %exdir%\%%d-booklet-cmyk-temp.pdfx >nul
	del %exdir%\%%d-booklet-rgb-temp.pdf
	echo Processing %%d
	)
:: change the directory to exdir
pushd %exdir%
:: based on answer on stackoverflow : https://stackoverflow.com/questions/19297935/naturally-sort-files-in-batch
(
setlocal enabledelayedexpansion
for %%f in (*.pdfx) do (
set numbr=00000000000000000000000000000000%%f
set numbr=!numbr:~-36!
set $!numbr!=%%f
)
for /f "tokens=1,* delims==" %%f in ('set $0') do echo %%g
) >>inkporter-pagelist.txt

echo.
set filename=%objID%_booklet-cmyk.pdf
gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=%filename% @inkporter-pagelist.txt
del *.pdfx
del inkporter-pagelist.txt
goto end

::gonna drop this in the furture
:bundle
md %exdir%\temp-inkporter

for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-plain-svg --export-filename=%exdir%\temp-inkporter\%%d-temp.svg %svgin%
	inkscape %exdir%\temp-inkporter\%%d-temp.svg --export-type=eps --export-filename=%exdir%\temp-inkporter\%%d.eps --export-area-page --export-ps-level=3 --export-text-to-path --export-ignore-filters >nul 2>nul
	inkscape --export-id=%%d --export-filename=%exdir%\temp-inkporter\%%d.png %svgin% >nul
	7z a -tzip %exdir%\%%d.zip %exdir%\temp-inkporter\%%d.png %exdir%\temp-inkporter\%%d.eps
	echo.
	echo %%d.zip has been created
	)
rmdir /s /q %exdir%\temp-inkporter
goto end




:: Export targets that needs DPI Prompted

:DPIPROMPT
set /p dpi="DPI Value = "
if %dpi%==[] set dpi=96
:: PNG WEBP
if %target%=png goto %target%
if %target%=webp goto %target%
goto JPEGREQ

:png
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-filename=%exdir%\%%d.png --export-dpi=%dpi%  %svgin% >nul
	echo %%d.png has been created
	)

goto end

:webp
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-filename=%exdir%\%%d-temp.png --export-dpi=%dpi%  %svgin% >nul
	cwebp %exdir%\%%d-temp.png -o %exdir%\%%d.webp
	del %exdir%\%%d-temp.png
	echo %%d.webp has been created
	)
goto end

:: JPEG PDF-RASTER PDF-CMYK-RASTER BOOKLET-RASTER BOOKLET-CMYK-RASTER
:JPEGREQ
set /p bgcol="Image Background Color (in HEX) = "
set /p quality="JPEG Quality Value = "
set /p colorspace="Colorspace (RGB/CMYK) = "

:REQCHECK
if %bgcol%==[] set bgcol=#ffffff
if %quality%==[] set quality=100
if %colsp%==[] set colsp=rgb

if %colsp%==rgb set suffix=
if %colsp%==rgb set colorarg=
if %colsp%==cmyk set colorarg=-colorspace cmyk
if %colsp%==cmyk set suffix=-cmyk
goto %target%process

:jpeg
goto REQCHECK
:jpegprocess
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-filename=%exdir%\%%d-temp.png --export-dpi=%dpi% %svgin% >nul
	magick convert %exdir%\%%d-temp.png -background %bgcol% -flatten %colorarg% -quality %quality% %exdir%\%%d%suffix%.jpeg
	del %exdir%\%%d-temp.png
	echo %%d%suffix%.jpeg has been created
	echo.
	)
goto end

:book-raster
goto REQCHECK
:book-rasterprocess
set namaberkas=booklet_raster_%objID%.pdf
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	echo Now processing %%d
	inkscape --export-id=%%d --export-filename=%exdir%\%%d-temp.png --export-dpi=%dpi% %svgin% >nul
	magick convert %exdir%\%%d-temp.png -background %bgcol% -flatten %colorarg% -quality %quality% %exdir%\%%d-bookletras-temp-%colsp%.pdf
	move %exdir%\%%d-bookletras-temp-%colsp%.pdf %exdir%\%%d-bookletras-temp-%colsp%.pdfx >nul
	del %exdir%\%%d-temp.png
	)
	
pushd %exdir%
(
setlocal enabledelayedexpansion
for %%f in (*.pdfx) do (
set numbr=00000000000000000000000000000000%%f
set numbr=!numbr:~-36!
set $!numbr!=%%f
)
for /f "tokens=1,* delims==" %%f in ('set $0') do echo %%g
) >> inkporter-list.txt
echo.
gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=%namaberkas% @inkporter-list.txt
del *.pdfx
del inkporter-list.txt
goto end


::ZIPping
:zip
pushd %exdir%
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	dir /b | findstr %%d > %%d-zip-inkporter-list.txt
	for /f "delims=," %%x in ('type %%d-zip-inkporter-list.txt') do (
		mkdir %%d-inktemp
		move %%x %%d-inktemp\%%x
		)
	move %%d-zip-inkporter-list.txt %%d-inktemp\%%d-zip-inkporter-list.txt
	pushd %%d-inktemp
	7z a -tzip %%d.zip @%%d-zip-inkporter-list.txt 
	for /f "delims=," %%x in ('type %%d-zip-inkporter-list.txt') do (
		del %%x
		)
	rmdir /s /q %exdir%\temp-inkporter
	cd ..
	)


:end
exit
