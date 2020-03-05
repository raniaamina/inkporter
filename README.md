## inkporter

Perkakas sederhana untuk mengekspor berkas svg dari Inkscape berdasarkan pattern objek ID yang telah ditentukan. Perkakas ini dapat juga disebut dengan *SVG extractor*.

### Dependensi

- Inkscape
- ghostscript (khusus untuk PDF CMYK)

### Cara Penggunaan

#### Persiapan
1. Unduh berkas inkporter
Buka terminal Anda kemudian jalankan perintah di bawah ini.
```bash
sudo wget https://raw.githubusercontent.com/raniaamina/bash-script/master/inkporter/inkporter -P /usr/local/bin/
```
2. Atur agar inkporter dapat dieksekusi
```bash
sudo chmod +x /usr/local/bin/inkporter
```


#### Penggunaan
Untuk dapat menggunakan inkporter ini, Anda diharuskan untuk mengeset objek ID pada masing-masing objek yang Anda inginkan. Objek ID di Inkscape dapat di set melalui dialog objek yang dapat dipanggil dengan pintasan ctrl+shift+o.

Pilih nama objek dengan menggunakan pattern atau pola tertentu, misalnya hlm-1, hlm-2, atau ic_home ic_back, dan seterusnya. Simpan berkas SVG tersebut (saya asumsikan di simpan di home dengan nama tes-file.svg)

Buka terminal Anda, kemudian jalankan inkporter dengan format perintah sebagai berikut.
```bash
inkporter /lokasi/file.svg objectID
```

Sehingga untuk berkas yang telah dibuat tadi format perintahnya menjadi
```bash
inkporter tes-file.svg hlm

# atau

inkporter tes-file.svg ic
```
Saat pemrosesan berlangsung Anda akan diminta untuk memilih format output (PNG, PDF, atau SVG) dan menentukan folder untuk menyimpan hasil ekspor.

Tunggu sampai proses selesai, dan ... selamat, objek-objek dalam berkas svg Anda berhasil diekspor sesuai dengan ID yang telah Anda tentukan.

### Kegunaan & Format Ekspor yang Didukung
Skrip ini memanglah sangat sederhana, namun semoga dapat membantu untuk menuntaskan beberapa pekerjaan Anda semisal;
- ekspor ikon (baik untuk keperluan personal maupun dijual ke pasar kreatif)
- ekspor halaman-halaman buku 
- slicing assets (sangat berguna untuk ui/web designer)
- dan hal-hal lainnya

agar menjadi lebih lebih efisien dan cepat.

Untuk saat ini inkporter dapat melakukan ekspor ke beberapa format berikut:
- PNG
- PDF
- PDF CMYK (memerlukan ghostscript)
- EPS Default


### Menggunakan Inkporter di Windows (udah pindah aja pake linux, bikin ribet)
Inkporter dapat dijalankan di Windows 10 dengan melalui WSL. Silakan ikuti langkah-langkah berikut.
-  Aktifkan WSL 
    - Bukan menu, lalu pada kotak pencarian ketik "Turn Windows features on or off"
    - Setelah terbuka, kemudian centang "Windows Subsystem for Linux" 
    - Reboot
    
- Pasang Ubuntu via Store
    - Buka Windows store
    - Cari "Ubuntu" kemudian klik Install
    - Setelah selesai bukan terminal ubuntu tersebut
    - Masukkan username dan sandi untuk akun Linux ini
    
- Persiapan pemasangan Inkporter
    ```
    sudo apt update
    sudo apt install inkscape ghostscript git
    wget https://raw.githubusercontent.com/raniaamina/bash-script/master/inkporter/inkporter -P ~/.local/bin/
    sudo chmod +x ~/.local/bin/inkporter
    ```
    tutup terminal kemudian buka lagi
    
Sampai pada tahap ini, Anda sudah dapat menggunakan inkporter sesuai panduan di atas. Ah, untuk mempermudah, saya sarankan untuk membuat symlink/pintasan ke drive C atau D anda di home. Sebagai informasi, lokasi C dan D di wsl ini ada di /mnt/c dan /mnt/d, dengan demikian untuk mengkses berkas berkas kerja (SVG) yang telah dibuat, Anda herus mengarahkannya terlebih dahulu ke path tersebut. 

Misalnya berkas svg Anda (contoh: icon.svg) ada di lokal disk D di dalam folder bernama "pekerjaan" => D:\pekerjaan\icon.svg, maka untuk menjalankan inkporter, silakan atur perintahnya seperti berikut;

`inkporter /mnt/d/pekerjaan/icon.svg nama-id`

yang merepotkan adalah ketika menetukan tempat penyimpanan hasil ekspor, karena Anda haruslah mengetik alamat penuh.

Nah, salah satu solusinya adalah dengan menjalankan inkporter langsung di folder tempat berkas svg disimpan. Pada contoh di atas, baiknya Anda melakukan;

```
cd /mnt/d/pekerjaan
```

selanjutnya baru
```
inkporter icon.svg nama-id
```

dengan demikian Anda cukup mengetik nama folder tempat hasil akan disimpan, dan tara folder tersebut akan langsung ada di folder yang sama dengan berkas svg Anda.

### Lain-Lain
Skrip ini bebas untuk digunakan, dimodifikasi, dan sebarkan dengan atau tanpa memberikan keterangan tentang kreator untuk tujuan apapun. 
Untuk berdiskusi seputar inkporter ini atau ingin berdonasi karena terbantu karena perkakas ini, silakan merujuk ke halaman [devlovers ini](https://devlovers.netlify.com/).
