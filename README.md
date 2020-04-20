# Inkpoter Windows (Native) 
Inkporter for Windows

Bismillah

Inkporter merupakan tool sederhana yang dikembangkan oleh @raniaamina untuk mengekspor berkas svg bedasarkan pola pada nama object id yang aslinya dikembangkan untuk sistem operasi linux

![image of tampilan_inkporter](https://raw.githubusercontent.com/raniaamina/inkporter/windows/tutorial_image/tampilan_inkporter.png)

Tool ini merupakan versi .bat dari Inkporter untuk CMD Windows (native) yang ditulis oleh RJ95
sehingga pengguna Windows dapat melakukan batch expor svg tanpa menginstall WSL (Windows Subsystem for Linux)

Aplikasi yang dibutuhkan :
- [Inkscape](https://inkscape.org/)
- [Ghostscript 9.52](https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs952/gs952w32.exe) untuk expor pdf-cmyk
- [Imagemagick](https://imagemagick.org/script/download.php#windows) untuk expor JPEG
- [libwebp](https://developers.google.com/speed/webp/download) untuk expor webp
- [7-zip](https://www.7-zip.org) untuk expor zip

Petunjuk Instalasi

* Unduh [Installer inkporter-win](https://github.com/raniaamina/inkporter/releases/tag/1.4) lalu buka Installer untuk memasang inkporter-win
* Unduh dan Install dependensi dibawah ini di direktori defaultnya (Program Files)
	* [Ghostscript 9.52](https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs952/gs952w32.exe)
	* [Imagemagick](https://imagemagick.org/script/download.php#windows)
	* [7-zip](https://www.7-zip.org)
	* [WebP](https://developers.google.com/speed/webp/download) ekstrak ke direktori %PROGRAMFILES%\Inkporter\deps\libwebp
	
Petunjuk pemakaian :

saya akan menggunakan contoh bahwa saya memiliki berkas svg bernama *drawing.svg* di direktori D:\project
dengan objek yang ingin saya expor adalah *obj-1* *obj-2* *obj-3* *obj-4* *obj-5* *obj-6*


* untuk menggunakan inkporter

	* Klik kanan pada folder project, lalu pilih "Buka Inkporter di sini" lalu jendela inkporter-win akan muncul
	* pilih format yang dinginkan (disini saya ambil contoh pdf maka saya akan memasukkan angka 2)
	* setelah memilih format output maka akan muncul semua nama berkas svg yang ada di direktori saat ini
	* masukkan nama berkas (**drawing.svg**)
	* lalu masukkan pola nama object id (**obj**)
	* berkas akan diekspor ke folder baru, masukkan nama yang anda inginkan seperti **hasil expor**
	* berkas akan diproses dan selamat berkas berhasil terekspor

Sekian dari saya, bila anda ingin berdiskusi, memberikan feedback, saran, atau tanya2 tentang inkporter.bat ini bisa hubungi saya lewat telegram [@RJ95ID](https://t.me/RJ95ID)

sekian Terima Kasih
