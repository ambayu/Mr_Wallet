# Dialogs & Modal Forms — Rules

## 1. Peran Komponen
Modal form bottom-sheet untuk aktivitas pendukung: pembuatan kategori baru, scan struk, pemilihan dompet, dan rekonsiliasi saldo.

> Catatan: input transaksi **bukan lagi** bottom-sheet. Sejak redesign, pencatatan transaksi memakai **halaman penuh** `AddTransactionScreen` (lihat `lib/presentation/screens/add_transaction_screen.dart`) yang dipanggil via `Navigator.push`. Detail alurnya ada di bagian 2.

## 2. Aturan Halaman Input Transaksi (`AddTransactionScreen`)
- **Bentuk**: Halaman penuh (`Scaffold`) dengan header neo-brutalis, bukan modal.
- **Alur Step-by-Step**:
  1. **Pilih Tipe Transaksi (Tab Atas)**: Segmented control `[ Pengeluaran ] [ Pemasukan ] [ Transfer ]`.
  2. **Pilih Kategori (Grid 4 Kolom Per Grup dengan Smart Sorting)**:
     - Seluruh kategori dikelompokkan dengan label grup neo-brutalis (`CategoryGroupHelper`) yang otomatis beradaptasi dengan tab aktif:
       - **Saat Tab [Pengeluaran]**:
         1. **Kebutuhan Harian** (Makan, Minum, Camilan, Belanja, Sayur, Buah, Baju)
         2. **Kendaraan & Transport** (Bensin, Motor, Mobil, Parkir, Transport, Liburan)
         3. **Tagihan & Tempat Tinggal** (Pulsa, WiFi, Listrik, Air, Kos, Rumah, Laundry, Langganan, Pajak, Asuransi, Servis)
         4. **Kesehatan & Edukasi** (Kesehatan, Obat, Skincare, Cantik, Sekolah, Buku, Anak)
         5. **Hiburan & Gaya Hidup** (Nongkrong, Game, Olahraga, Hobi, Kado, Sedekah, Rokok, Hewan, Gadget, Lotre)
         6. **Finansial & Lainnya** (Cicilan, Admin, Selisih, Transfer, Gaji, Bonus, Usaha, Investasi)
         7. **Kategori Lain** (Kategori buatan pengguna)
       - **Saat Tab [Pemasukan] (Smart Sorting)**:
         1. 🌟 **Sumber Pendapatan Utama** (*Gaji, Bonus, Usaha, Investasi, Kado, Sedekah, Selisih, Transfer*) langsung naik ke urutan paling atas untuk pencatatan instan.
         2. Kebutuhan Harian & Jual/Refund
         3. Gaya Hidup & Barang
         4. Tagihan, Properti & Transport
         5. Kesehatan & Edukasi
         6. Kategori Lain
     - Penamaan kategori baku menggunakan **1 kata ringkas** agar muat rapi di grid 4 kolom tanpa terpotong.
     - Menyediakan tile `+ Tambah` di akhir grup untuk menambah kategori baru.
     - Pada tab Transfer, menampilkan banner khusus transfer antar-rekening tanpa perlu memilih kategori pengeluaran.
  3. **Panel Mengambang (Bottom Sheet)**: saat kategori diketuk, muncul `_TransactionFormSheet` berisi:
     - **Header & Badge Status**: Menampilkan nama kategori serta badge status kecil (`Pengeluaran`, `Pemasukan`, atau `Transfer Saldo`) sesuai tab yang aktif. Tanpa tombol toggle tipe redundan di dalam form.
     - **Input Nominal**: Berformat otomatis **Currency Rupiah** (contoh: `Rp 50.000`).
     - **Pilih Dompet**: Otomatis ke **Dompet Utama**, atau dompet yang dioper via `initialWalletId`.
     - **Pilih Tanggal**: Fleksibel memilih tanggal transaksi.
     - **Catatan**: Opsional, default memakai nama kategori.
  4. **Simpan**: Sukses menutup sheet sekaligus halaman, lalu menampilkan snackbar konfirmasi.
- **Parameter**: `initialWalletId` (opsional, pre-select dompet) dan `initialDate` (opsional, pre-select tanggal).

## 3. Aturan Modal AI Smart Text (`AITextModal`)
- **Fungsi**: Memproses input teks bahasa alami bebas menjadi data transaksi terstruktur menggunakan API Route9 Gemini (`gemini-3.7-3.8`).
- **Alur & Fitur**:
  1. **Input Teks Alami**: Pengguna dapat mengetik bebas (contoh: *"Beli nasi padang 25rb pakai Dompet Tunai"*).
  2. **Riwayat Teks Perintah**: Menyimpan hingga 20 riwayat teks perintah terakhir di `SharedPreferences`, dapat diketuk untuk langsung mengisi/mengeksekusi ulang.
  3. **Menu Konfirmasi Tindakan**: Menampilkan kartu konfirmasi hasil ekstraksi AI (kategori, nominal rupiah, dompet sumber, tipe, dan catatan) secara transparan.
  4. **Eksekusi Aman**: Transaksi hanya disimpan ke database setelah pengguna menekan tombol `[ Konfirmasi & Simpan ]`.

## 4. Aturan Modal Tambah Kategori (`AddCategoryDialog`)
- **Kategori Fleksibel / Type-Agnostic**: Tidak membedakan Pengeluaran vs Pemasukan saat pembuatan. Kategori dapat dipakai secara bebas di kedua tipe transaksi.
- Input nama kategori (teks tebal, border hitam 1.8px).
- **Pemilih Ikon Terpusat (`CategoryIconHelper`)**: Grid scrollable berisi 50+ ikon Material terkurasi yang mencakup kebutuhan harian, gaya hidup, transportasi, perumahan, tagihan, hiburan, dan pendapatan.
- Pilihan warna aksen neo-brutalis pastel.
- Menyimpan data langsung ke tabel SQLite `categories` dan otomatis memperbarui state form.

## 4. Aturan Modal Tambah Wadah Rekening (`AddWalletDialog`)
- Input **Nama Rekening / Dompet**.
- Input **Saldo Awal** (Rp).
- **Pemilih Logo Wadah** (`WalletIconHelper.options`): grid ikon neo-brutalis yang dapat dipilih bebas oleh pengguna. Logo inilah yang ditampilkan di seluruh aplikasi (daftar wadah, header, detail dompet, dropdown transaksi).
- **Tanpa pemilihan tipe wadah** — konsep tipe (CASH/BANK/EWALLET) dihapus dari UI; ikon mewakili identitas wadah.
- Pilihan warna kartu neo-brutalis pastel.
- Menyimpan ke tabel SQLite `wallets` dengan `type` default internal dan `icon` sesuai pilihan pengguna.
