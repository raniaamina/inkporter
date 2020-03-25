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

Petunjuk Instalasi

- Unduh dan salin inkporter.bat ke direktori installasi Inkscape
- tambahkan direktori installasi inkscape dan ghostscript ke %PATH%
	- buka Control Panel -> System and Security -> System 
	- klik pada pojok kiri atas *Advanced system setting* lalu akan muncul system properties
	
	 ![image set path 1](https://github.com/maslanangdev/inkporter/blob/windows/tutorial_image/3.png)

	- masuk ke *Environment Variables...*
	
	 ![image set path 2](https://github.com/maslanangdev/inkporter/blob/windows/tutorial_image/4.png)
	
	- Edit System variable *Path*
	
	 ![image set_path 3](https://github.com/maslanangdev/inkporter/blob/windows/tutorial_image/5.png)
	
	- lalu tambahkan direktori installasi Inkscape (C:\Program Files\Inkscape) dan Ghostscript (untuk versi terbaru saat ini ditulis = C:\Program Files\gs\gs9.52\bin)
	
	![image set_path 4](https://github.com/maslanangdev/inkporter/blob/windows/tutorial_image/7.png)
	
	- **TIP** Jika kalian menggunakan Python, pastikan untuk meletakkan direktori Inkscape dibawah direktori python agar saat hendak menjalankan Python lewat CMD tidak menjalankan Python dari direktori Inkscape, karena di dalam folder Inkscape juga terdapat Python
	
	![image tip](https://github.com/maslanangdev/inkporter/blob/windows/tutorial_image/tip1.png)
	
	
Petunjuk pemakaian :

saya akan menggunakan contoh bahwa saya memiliki berkas svg bernama *drawing.svg* di direktori D:\project
dengan objek yang ingin saya expor adalah *obj-1* *obj-2* *obj-3* *obj-4* *obj-5* *obj-6*

* untuk mengarahkan CMD pada direktori yang di tuju

	* buka cmd
	* ketik **nama_partisi:** misal **D:** lalu enter untuk pindah ke partisi D:\
 	* selanjutnya ketik **cd nama_folder** misal **cd project** lalu tekan enter untuk masuk ke folder bernama project

* untuk menggunakan inkporter

	* di sana saya akan menjalankan inkporter, untuk menjalankannya ketik **inkporter** lalu tekan enter
	* pilih format yang dinginkan (disini saya ambil contoh pdf maka saya akan memasukkan angka 2)
	* setelah memilih format output maka akan muncul semua nama berkas svg yang ada di direktori saat ini
	* masukkan nama berkas (**drawing.svg**)
	* lalu masukkan pola nama object id (**obj**)
	* berkas akan diekspor ke folder baru, masukkan nama yang anda inginkan seperti **hasil expor**
	* berkas akan diproses dan selamat berkas berhasil terekspor

Sekian dari saya, bila anda ingin berdiskusi, memberikan feedback, saran, atau tanya2 tentang inkporter.bat ini bisa PM saya lewat telegram @RJ95ID

sekian Terima Kasih
