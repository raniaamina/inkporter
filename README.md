<p align="center" class="has-mb-6">
<img class="not-gallery-item" height="128" src="/inkporter.svg" alt="logo">
<br><b>Inkporter</b></br>
<br>
Export SVG Document to Several Format by Its ID!
<br>

# Inkpoter GUI
An extension that will help you to export your object in your SVG to several format (SVG, JPG, PDF, Multiple PDF Page, WEBP, and EPS) by its ID. If you're book creator, icon designer, seller on marketplace, web designer, this ekstension will fully help your task. This ekstension also available as CLI version, please refer to [this page](https://app.gitbook.com/@raniaamina/s/mozelup/tools/inkporter).

## How Inkporter Work
The simple explanations is, inkporter will read ID pattern (i.e icon-1, icon-2, icon-3, etc) that you've set and than export them to format file that you need. We can say that inkporter allow you to feel work with artboard-like or multiple-page-like in Inkscape. 

## Dependencies
Currently we make this ekstension for Inkscape 0.9x, we need some lines to make this ekstension work on version 1.x, and of course we'll do it in the future. To make Inkporter run correctly, please make sure that this Dependencies already installed on your system:
- Inkscape
- librsvg2-bin (this package has different name on some linux distro repositories)
- Ghostscript
- ImageMagick
- webp / libwebp


## How to Use Inkporter
Just copy and paset inkporter.inx and inkporter.py to Inkscape extension directory, usually in `$HOME/.config/inkscape/extensions` for linux.

Unable to find where is the `extensions` directory for your Inkscape installation?  
you can check it from `Edit > Preferences > System` menu, then look at `User extensions` path in `System Info` section.

If the installation is correct, you'll find Inkporter menu on Extensions -> Export -> Inkporter.

## Development Status:
- [x] Inkporter CLI
- [x] UI Research
- [x] UI Development (Phase 1)
- [x] Backend Development (Phase 2)
- [ ] Testing (Phase 3)
  - [x] Linux (default, flatpak, snap)
  - [ ] MacOS
  - [x] Windows


## Contributor
- [Sofyan Sugianto - sofyan@artemtech.id](mailto://sofyan@artemtech.id) (Programmer)
- [Rania Amina - me@raniaamina.id ](https://raniaamina.id) (UI Designer)

This project fully supported by Gimpscape Indoensia (The Biggest Indonesia F/LOSS Design Community)

## Disclaimer & Donation
This is early development extension. We don't guarantee anything about this extension so please use at your own risk. If you feel helped by this extension, of course you can give us a cup of coffee, please refer to [Dev-Lovers Page](https://devlovers.netlify.com) :")
