# Halaman Riwayat Transaksi — Changelog

## [Unreleased]
- Mengganti opsi "Semua Dompet" di baris kedua header menjadi tombol **`[ 💼 Lihat Dompet ▾ ]`**.
- Membuat modal interaktif **`WalletListModal`**:
  - Menampilkan daftar lengkap wadah dompet pengguna, ikon/logo wadah (Tunai, Bank, E-Wallet), status Dompet Utama, serta saldo aktual.
  - Menyediakan tombol "Pilih" (untuk memfilter riwayat di layar transaksi) dan tombol panah `>` untuk membuka **Halaman Detail Dompet**.
  - Menyediakan tombol cepat `+ Tambah Wadah Rekening Baru`.
- Membuat halaman baru **`WalletDetailScreen`** (Halaman Khusus Detail Dompet):
  - Menampilkan kartu neo-brutalis saldo utama dompet lengkap dengan statistik Masuk & Keluar khusus akun tersebut.
  - Tombol aksi cepat "Sesuaikan Saldo" (rekonsiliasi) dan "Catat Mutasi".
  - Daftar riwayat transaksi terfilter khusus untuk dompet yang bersangkutan.
- Menambahkan informasi saldo singkat pada item bar horizontal dompet di header riwayat.
- Membatasi tampilan dompet di baris 2 header menjadi **maksimal 3 dompet** agar header tidak kepenuhan/sesak.
- Mengubah tombol `Lihat Dompet` dan `Lainnya` di baris 2 header menjadi **tombol ikon saja** (lebar tetap 44px) agar lebih hemat ruang dan efisien.
- Menampilkan tombol ikon `tune` di samping 3 dompet jika total dompet pengguna > 3.
- Mengubah Baris 2 header menjadi layout **justify** (`Row` + `Expanded`): item dompet terbagi rata memenuhi lebar layar, bukan lagi menumpuk ke kiri.
- Membuat dialog neo-brutalis **`HeaderWalletPickerDialog`** untuk memilih 1 hingga 3 dompet yang disematkan ke baris header, dengan penyimpanan persisten di `SharedPreferences` (`header_wallet_ids`).
- Memperbaiki pemilih tahun pada header: sebelumnya hanya 11 tahun statis (`tahun − 5` s/d `+ 5`) dan tidak bisa digeser. Sekarang menjadi dialog **`_YearPickerDialog`** yang **fleksibel & scrollable** dengan rentang `tahun berjalan − 30` hingga `tahun berjalan + 10`, auto-scroll ke tahun aktif, dan penanda titik hijau pada tahun berjalan (selalu ter-update).
- Mengarahkan tombol `+ Catat` (header) dan `+ Catat di Bulan Ini` (empty state) ke halaman penuh **`AddTransactionScreen`** via `Navigator.push`, dengan `initialDate` mengikuti bulan yang sedang dibuka.
- **Penyatuan Pemilih Periode (Bulan & Tahun)**:
  - Menggabungkan sel Bulan dan Tahun pada Baris 1 header menjadi **satu sel stacked** (Tahun kecil di atas, Bulan tebal di bawah + panah dropdown).
  - Mengganti dialog terpisah menjadi dialog gabungan **`_MonthYearPickerDialog`**: strip horizontal pilihan tahun di atas (auto-scroll, rentang 30 tahun ke belakang hingga 10 tahun ke depan, indikator titik hijau tahun aktif) dan grid 3×4 pilihan bulan di bawah dengan konfirmasi sekali ketuk.
