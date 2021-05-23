<p align="center" class="has-mb-6">
<img class="not-gallery-item" height="128" src="linux/inkscape-1.0/inkporter/inkporter.svg" alt="logo">
<br><b>Inkporter</b>
<br>
Export SVG Document to Several Format Based on Its ID!
<br>

# Inkpoter GUI

An extension that will help you to export your object in your SVG to several format (SVG, JPG, PDF, Multiple PDF Page, WEBP, and EPS) by its ID. If you're book creator, icon designer, seller on marketplace, web designer, this ekstension will fully help your task. This ekstension also available as CLI version, please refer to [this page](https://app.gitbook.com/@raniaamina/s/mozelup/tools/inkporter) or open Master Branch from this repository.

## How Inkporter Work

The simple explanations is, inkporter will read ID pattern (i.e icon-1, icon-2, icon-3, etc) that you've set and than export them to format file that you need. We can say that inkporter allow you to feel work with artboard-like or multiple-page-like in Inkscape. 

## Dependencies

Currently we make this ekstension for Inkscape 0.9x, we need some lines to make this ekstension work on version 1.x, and of course we'll do it in the future. To make Inkporter run correctly, please make sure that this Dependencies already installed on your system:

- Inkscape
- Ghostscript
- ImageMagick
- webp / libwebp
- zenity (for Linux & MacOS)

### Dependencies download links for Windows

- [Inkscape](https://inkscape.org/)
- [Ghostscript 32bit 9.52](https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs952/gs952w32.exe)
- [libwebp](https://developers.google.com/speed/webp/download)
- [7-zip](https://www.7-zip.org) for ZIP Support
- [Imagemagick](https://imagemagick.org/script/download.php#windows)

## How to Install Inkporter

* Copy Inkporter to Extension Directory
  
  * For Linux : Just copy and paste inkporter.inx, inkporter.py, and inkporter directory to Inkscape extension directory, usually in `$HOME/.config/inkscape/extensions` for linux.
  
  * For Windows : Copy inkporter.inx, inkporter.py, inkporter_ext.bat and inkporter directory to Inkscape Extensions directory, by default it's on `%APPDATA%\Inkscape\extensions` for Windows
  
  Note For Windows : Inkscape 1.0.1 has a problem with importing GTK that needed by Inkporter on linux-windows folder, copy file named `HarfBuzz-0.0.typelib` on misc folder into ` C:\Program Files\Inkscape\lib\girepository-1.0` to solve the problem
  
  > UPDATE!
  > Now you can use same files for Linux & Windows

  Unable to find where is the `extensions` directory for your Inkscape installation?  
you can check it from `Edit > Preferences > System` menu, then look at `User extensions` path in `System Info` section.

* Add Dependencies to Environment Variables (Windows)
  
  In Windows, after you install the required dependencies, you should add the dependency directories to Environment Variable "PATH"
  
  simply, you can do it by go to Control Panel -> System and Security -> System -> Advanced System Settings -> Environment Variables, then double click on "Path" System Variable and add the directories. If you use Windows 8.1 and below, separate each directory with semicolon (;) like C:\Windows;C:\Users\username\libwebp\bin

If the installation is correct, you'll find Inkporter menu on Extensions -> Export -> Inkporter. Please make sure you're copying right version of Inkporter, we provide two version of inkporter which is for Inkscape 0.9x and Inkscape 1.0 version.

## How to Export Your Objects with Inkporter

* Group your objects
* Give each Groups an unique ID Pattern like obj-1, obj-2, obj-3 (you can replace obj with anything what you want)
* Open Inkporter
* Choose the format that you want
* Insert your unique ID Pattern in Inkporter (in this case is "obj")
* Define the export directory
* Click Export and Inkporter will export your objects

## Development Status:

- [x] Inkporter CLI
- [x] UI Research
- [x] UI Development (Phase 1)
- [x] Backend Development (Phase 2)
- [x] Testing (Phase 3)
  - [x] Linux (default, flatpak, snap)
  - [x] MacOS
    
    ```bash
    # run with this trick
    ➜  ~ cd /Applications/Inkscape.app/Contents/MacOS
    ➜  MacOS ./inkscape
    ```
  - [x] Windows
- [x] Add support for Inkscape 1.0

## Contributor

- [Sofyan Sugianto - sofyan@artemtech.id](mailto://sofyan@artemtech.id) (Programmer)
- [Rania Amina - me@raniaamina.id ](https://raniaamina.id) (UI Designer)
- [Rijal](#) (Windows developers)

This project fully supported by Gimpscape Indoensia (The Biggest Indonesia F/LOSS Design Community)

## Disclaimer & Donation

This is early development extension. We don't guarantee anything about this extension so please use at your own risk. Currently, we focus developing inkporter on linux as primary system, so if you use MacOS or Windows forgive us if we can't provide full features of Inkporter. The main problem is dependencies installation for each operating system is different, so it effect to inkporter features.

If you feel helped by this extension, of course you can give us a cup of coffee, please refer to [Dev-Lovers Page](https://devlovers.netlify.com) :")
