# Inkpoter Windows (Native) 
Inkporter for Windows

Bismillah

Inkporter merupakan tool sederhana yang dikembangkan oleh @raniaamina untuk mengekspor berkas .svg bedasarkan pola pada nama object id yang aslinya dikembangkan untuk sistem operasi linux

ini merupakan versi .bat dari Inkporter untuk CMD Windows (native) yang ditulis oleh RJ95
sehingga pengguna Windows dapat melakukan batch export svg tanpa menginstall WSL
dalam versi .bat ini saya menambahkan export bedasarkan page

Aplikasi yang dibutuhkan yang dibutuhkan :
**Inkscape** : https://inkscape.org/
**Ghostscript** untuk export pdf-cmyk : https://www.ghostscript.com/download/gsdnld.html
(gunakan ghostscript 32bit, karena inkporter.bat ini saya tulis agar menggunakan gswin32 sehingga dapat berjalan di semua arsitektur)

Petunjuk Instalasi

- Unduh dan salin inkporter.bat ke direktori installasi
- tambahkan direktori installasi inkscape dan ghostscript ke %PATH%
	- buka Control Panel -> System and Security -> System 
	- klik pada pojok kanan kiri *Advanced system setting* lalu akan muncul system properties
	- masuk ke *Environment Variables...*
	- Edit System variable *Path* lalu tambahkan direktori installasi Inkscape (C:\Program Files\Inkscape) dan Ghostscript (untuk versi terbaru saat ini ditulis = C:\Program Files\gs\gs9.52\bin)

Petunjuk pemakaian :

Pilihan 1-4 (png, pdf, pdf-cmyk, eps) akan mengekspor berkas bedasarkan Page,
sedangkan pilihan 5-8 (png, pdf, pdf-cmyk, eps) akan mengekspor berkas bedasarkan pola nama object id

saya akan menggunakan contoh bahwa saya memiliki berkas svg bernama *drawing.svg* di direktori D:\project
dengan objek yang ingin saya export adalah *obj-1* *obj-2* *obj-3* *obj-4* *obj-5* *obj-6*
1. buka cmd
2. ketik **D:** lalu enter untuk pindah ke partisi D:\
3. selanjutnya ketik **cd project** lalu enter untuk masuk ke folder bernama project
4. di sana saya akan menjalankan inkporter, untuk menjalankannya ketik **inkporter** lalu tekan enter
5. pilih format yang dinginkan (disini saya ambil contoh pdf maka saya akan memasukkan angka 6)
6. masukkan nama berkas (*drawing.svg*)
7. lalu masukkan pola nama object id (*obj*)
8. tool ini akan mengekspor berkas ke folder baru, masukkan nama yang anda inginkan seperti *hasil export*
9. berkas anda akan diproses dan selamat berkas berhasil terekspor

Sekian dari saya, bila anda ingin berdiskusi, memberikan feedback, saran, atau tanya2 tentang inkporter.bat ini bisa PM saya lewat telegram @RJ95ID

sekian Terima Kasih
