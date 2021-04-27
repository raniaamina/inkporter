@echo off
setlocal

move %2 %2_inkporter-temp.svg >nul 2>nul

set exdir=%4\
set target=%1
set svgin=%2_inkporter-temp.svg
set objID=%3
set dpi=%5

if [%1]==[] goto main

:main
echo "|| Welcome to :                                                         ||"
echo "||  ___       _                     _                         _         ||"
echo "|| |_ _|_ __ | | ___ __   ___  _ __| |_ ___ _ __    __      _(_)_ __    ||"
echo "||  | || '_ \| |/ / '_ \ / _ \| '__| __/ _ \ '__|___\ \ /\ / / | '_ \   ||"
echo "||  | || | | |   <| |_) | (_) | |  | ||  __/ | |_____\ V  V /| | | | |  ||"
echo "|| |___|_| |_|_|\_\ .__/ \___/|_|   \__\___|_|        \_/\_/ |_|_| |_|  ||"
echo "||                |_|                                                   ||"
echo "||                                                                      ||"
echo "|| For Inkscape 1.0                                      Version 1.6.3  ||"
echo.  

:extensions_switcher

pushd %4

if %target%== png goto PNGBATCHPROCESS
if %target%== pdf goto PDFBATCHPROCESS
if %target%== eps goto EPSBATCHPROCESS
if %target%== svg goto SVGPLAINBATCHPROCESS
if %target%== jpeg goto JPEGBATCHPROCESS
if %target%== jpeg_cmyk goto JPEGBATCHPROCESS
if %target%== webp goto WEBPBATCHPROCESS
if %target%== booklet goto BOOKLETPROCESS
if %target%== booklet_cmyk goto BOOKLETPROCESS
if %target%== bundle goto BUNDLEBATCHPROCESS
if %target%== pdf_cmyk goto PDFBATCHPROCESS

goto pilihtarget

:PNGBATCHPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-filename=%exdir%\%%d.png --export-dpi=%dpi%  %svgin% >nul
	echo %%d.png has been created
	echo.
	)
goto end


:PDFBATCHPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg --export-filename=%exdir%\%%d-temp.svg %svgin%

	if %target%== pdf inkscape --export-area-page --export-dpi=%dpi% --export-filename=%exdir%\%%d.pdf %exdir%\%%d-temp.svg
	if %target%== pdf_cmyk inkscape --export-area-page --export-dpi=%dpi% --export-filename=%exdir%\%%d-rgb.pdf %exdir%\%%d-temp.svg

	if %target%== pdf_cmyk gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=%exdir%\%%d-cmyk.pdf %exdir%\%%d-rgb.pdf
	if %target%== pdf_cmyk del %%d-rgb.pdf
	del %exdir%\%%d-temp.svg
	echo.
	if %target%== pdf echo %%d.pdf has been created
	if %target%== pdf_cmyk echo %%d-cmyk.pdf has been created
	)
	
goto end


:EPSBATCHPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg --export-filename=%exdir%\%%d-temp.svg %svgin%
	inkscape %exdir%\%%d-temp.svg --export-dpi=%dpi% --export-filename=%exdir%\%%d.eps --export-type=eps --export-area-page --export-ps-level=3 --export-text-to-path --export-ignore-filters >nul 2>nul
	del %exdir%\%%d-temp.svg
	echo.
	echo %%d.eps has been created
	)
goto end


:SVGPLAINBATCHPROCESS

for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-id-only --export-plain-svg --export-filename=%exdir%\%%d.svg %svgin%
	echo.
	echo %%d.svg has been created
	)
goto end


echo your objects will be saved in %exdir%

:JPEGBATCHPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-filename=%exdir%\%%d-temp.png --export-dpi=%dpi% %svgin% >nul
	if %target%== jpeg magick convert %exdir%\%%d-temp.png -background #ffffff -flatten -quality 100 %exdir%\%%d.jpeg
	if %target%== jpeg_cmyk magick convert %exdir%\%%d-temp.png -background #ffffff -flatten -colorspace CMYK -quality 100 -colorspace CMYK %exdir%\%%d-cmyk.jpeg
	del %exdir%\%%d-temp.png
	if %target%== jpeg echo %%d.jpeg has been created
	if %target%== jpeg_cmyk echo %%d-cmyk.jpeg has been created
	echo.
	)
goto end

:WEBPBATCHPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	inkscape --export-id=%%d --export-filename=%exdir%\%%d-temp.png --export-dpi=%dpi%  %svgin% >nul
	cwebp %exdir%\%%d-temp.png -o %exdir%\%%d.webp
	del %exdir%\%%d-temp.png
	echo %%d.webp has been created
	echo.
	)
goto end


:BOOKLETPROCESS
for /f "delims=," %%d in ('inkscape --query-all %svgin% ^| findstr %objID%') do (
	echo Now processing %%d
	inkscape --export-id=%%d --export-id-only --export-plain-svg --export-filename=%exdir%\%%d-pdf-temp.svg %svgin%
	inkscape %exdir%\%%d-pdf-temp.svg --export-dpi=%dpi% --export-area-page --export-type=pdf --export-filename=%exdir%\pdftemp-%%d.pdf
	move %exdir%\pdftemp-%%d.pdf %exdir%\pdftemp-%%d.pdfx >nul
	del %exdir%\%%d-pdf-temp.svg
	)
:: change the directory to exdir
pushd %exdir%
:: based on answer on stackoverflow : https://stackoverflow.com/questions/19297935/naturally-sort-files-in-batch
(
setlocal enabledelayedexpansion
for %%f in (*.pdfx) do (
set numbr=0000000000000000000000000000000000000000000000000000%%f
set numbr=!numbr:~-56!
set $!numbr!=%%f
)
for /f "tokens=1,* delims==" %%f in ('set $0') do echo %%g
) >>inkporter-pagelist.txt
echo.
if %target%== booklet gswin32c -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=booklet_%objID%.pdf @inkporter-pagelist.txt
if %target%== booklet_cmyk gswin32c -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -dAutoRotatePages=/None -sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dDownsampleMonoImages=false -dDownsampleGrayImages=false -sOutputFile=booklet_%objID%-cmyk.pdf @inkporter-pagelist.txt
del *.pdfx
del inkporter-pagelist.txt
goto end

:endline
:end
echo COMPLETE
:: del %2_inkporter-temp.svg >nul 2>nul
if not [%2]==[] exit

:langsung_end
echo See you

:void
endlocal
