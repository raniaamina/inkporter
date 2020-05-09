# Inkporter

Perkakas sederhana untuk mengekspor berkas svg dari Inkscape berdasarkan pattern objek ID yang telah ditentukan. Perkakas ini dapat juga disebut dengan *SVG extractor*. Inkporter tersedia untuk Linux dan Windows serta dalam antarmuka GUI berupa ekstensi inkscape.

#### Dependensi

- Inkscape

- librsvg2-bin

- ghostscript (khusus untuk PDF CMYK)

- webp

### Memasang Inkporter

#### Debian/Ubuntu Base

```bash
# Menambah Key Gimpscape PPA
curl -s --compressed "https://gimpscape.github.io/gimpscape-ppa/tools/KEY.gpg" | sudo apt-key add -
```

```bash
# Menambah sources.list
sudo curl -s --compressed -o /etc/apt/sources.list.d/gimpscape-ppa.list "https://gimpscape.github.io/gimpscape-ppa/tools/gimpscape-ppa.list"
```

```bash
# Memasang Inkporter​
sudo apt update && sudo apt install
```

### Selain Debian/Ubuntu Base

```bash
# unduh skrip inkporter
sudo wget https://raw.githubusercontent.com/raniaamina/inkporter/master/source/inkporter/inkporter -P /usr/local/bin/
```

```bash
# atur agar dapat dieksekusi
sudo chmod +x /usr/local/bin/inkporter
```

### Penggunaan

> Harap diperhatikan, Inkscape versi 1.x diperuntukkan untuk Inkscape versi 0.9x ke bawah. Untuk penggunak Inkscape versi 1.0 atau yang terbaru, pastikan untuk memasang Inkporter versi 2.x



Pastikan berkas svg telah diset ID-nya dengan pola yang ditentukan, misal icon-merah, icon-bir, icon-hjau. Selanjutnya, buka terminal dan jalankan.

```bash
inkporter nama-file.svg icon
```

Pilih format ekspor dan ikuti petunjuk yang tampil di layar.

Untuk detail penggunaan Inkporter silakan lihat di `inkporter --help`



### Sangkalan

Inkporter dikembangkan sukarela oleh Rania Amina & Artemtech serta Komunitas Gimpscape Indonesia. Kami tidak memberikan jaminan apapun untuk perkakas bantu ini, segala hal yang ditimbulkan akibat Inkporter sepenuhnya adalah tanggung jawab pengguna. 



### Lain-Lain

Detail lengkap tentang Inkporter dapat dilihat pada halaman: https://catatan.raniaamina.id/tools/inkporter termasuk untuk Inkporter versi Windos. Jika Anda meras terbantu dengan perkakas ini, kami akan sangat jika Anda berkenan mengulas atau membagikan ke rekan sekitar atau berbagi kopi dengan kami di halaman: https://devlovers.netlify.com/.
