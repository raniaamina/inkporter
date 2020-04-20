# Inkpoter Windows (Native) 
Inkporter for Windows

Bismillah

Inkporter merupakan tool sederhana yang dikembangkan oleh @raniaamina untuk mengekspor berkas svg bedasarkan pola pada nama object id yang aslinya dikembangkan untuk sistem operasi linux

![image of tampilan_inkporter](https://github.com/maslanangdev/inkporter/blob/windows/tutorial_image/tampilan_inkporter.png)

Tool ini merupakan versi .bat dari Inkporter untuk CMD Windows (native) yang ditulis oleh RJ95
sehingga pengguna Windows dapat melakukan batch expor svg tanpa menginstall WSL (Windows Subsystem for Linux)

Aplikasi yang dibutuhkan :
- **Inkscape** : https://inkscape.org/
- **Ghostscript** untuk expor pdf-cmyk : https://www.ghostscript.com/download/gsdnld.html (gunakan ghostscript 32bit, karena inkporter.bat ini saya tulis agar menggunakan gswin32 sehingga dapat berjalan di semua arsitektur)
- **ImageMagick** untuk expor JPEG : https://imagemagick.org
- **libwebp** untuk expor webp : https://developers.google.com/speed/webp/download
- **7zip** untuk expor zip : https://www.7-zip.org

Petunjuk Instalasi

* Unduh [Installer inkporter-win](https://github.com/raniaamina/inkporter/releases/tag/1.4) lalu buka Installer untuk memasang inkporter-win
* Unduh dan Install dependensi dibawah ini di direktori defaultnya (Program Files)
	* [Ghostscript 9.52](https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs952/gs952w32.exe)
	* [Imagemagick](https://imagemagick.org/script/download.php#windows)
	* [7-zip](https://www.7-zip.org)

	- **TIP** : Jika kalian menggunakan Python, pastikan untuk meletakkan direktori Inkscape dibawah direktori python agar saat hendak menjalankan Python lewat CMD tidak menjalankan Python dari direktori Inkscape, karena di dalam folder Inkscape juga terdapat Python
	
	![image tip](https://github.com/maslanangdev/inkporter/blob/windows/tutorial_image/tip1.png)
	
	
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

Sekian dari saya, bila anda ingin berdiskusi, memberikan feedback, saran, atau tanya2 tentang inkporter.bat ini bisa PM saya lewat telegram @RJ95ID

sekian Terima Kasih
