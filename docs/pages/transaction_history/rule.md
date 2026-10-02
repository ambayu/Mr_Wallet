# Halaman Riwayat Transaksi — Rules

## 1. Peran Halaman
Menampilkan riwayat pencatatan arus kas (pemasukan, pengeluaran, transfer, dan rekonsiliasi) dengan pembagian waktu berbasis bulan dan tahun secara ringkas, efisien, dan berprioritas tinggi pada daftar data.

## 2. Aturan Komponen & Layout
- **Warna Latar Belakang (Background)**:
  - Menggunakan **Biru Muda Neo-Brutalist (`Color(0xFFD2EEFC)`)** untuk memberikan nuansa sejuk, bersih, dan kontras tajam terhadap kartu-kartu putih dan outline hitam.
- **Top Ledger Table Header (Tinggi: 104px)**:
  - **Baris 1: Table Bar Full-Height (Periode | Pemasukan | Pengeluaran)**:
    - Tanpa border kartu di dalam kolom masing-masing, teks full-height dipisahkan oleh garis vertikal hitam solid (`1.8px`).
    - **Kolom Periode (Tahun di Atas, Bulan di Bawah)**: Menampilkan tahun kecil di atas (`2026`) dan nama bulan tebal di bawah (`Oktober ▾`). Di-tap untuk membuka dialog gabungan **`_MonthYearPickerDialog`** (strip horizontal tahun scrollable di bagian atas, dan grid 3×4 pilihan bulan di bawahnya).
    - **Kolom Pemasukan**: Label kecil di atas (`Pemasukan`), nominal rupiah tebal hijau (`Color(0xFF16A34A)`) di bawah.
    - **Kolom Pengeluaran**: Label kecil di atas (`Pengeluaran`), nominal rupiah tebal merah (`Color(0xFFDC2626)`) di bawah.
  - **HR (Horizontal Line Divider)**:
    - Garis pembatas horizontal hitam solid penuh (`height: 1.8px`) memisahkan Baris 1 dengan Baris 2.
  - **Baris 2: Tombol Ikon [Lihat Dompet] + Maks 3 Dompet + Tombol Ikon [Lainnya]**:
    - Layout menggunakan `Row` dengan item dompet ber-`Expanded` sehingga terbagi rata (**justify**) memenuhi lebar layar.
    - Tombol pertama berupa **ikon saja** (`account_balance_wallet`) berlatar kuning, lebar tetap 44px, untuk efisiensi ruang. Menampilkan modal bottom sheet berisikan list seluruh akun, logo, saldo aktual, serta tombol buka ke Halaman Detail Dompet (`WalletDetailScreen`).
    - Di sampingnya terdapat daftar akun dompet yang dibatasi **maksimal 3 dompet** yang dipisahkan garis vertikal hitam (`1.6px`), menampilkan nama (di-center) dan saldo singkat akun.
    - Jika total wadah dompet pengguna **lebih dari 3 dompet**, ditampilkan tombol **ikon saja** (`tune`) lebar tetap 44px di sampingnya.
    - Menekan tombol ikon `tune` akan memunculkan dialog neo-brutalis `HeaderWalletPickerDialog` untuk memilih dompet mana saja (maksimal 3) yang ingin disematkan/ditampilkan di header. Konfigurasi ini tersimpan permanen di `SharedPreferences` (`header_wallet_ids`).
- **Halaman Detail Dompet Terpisah (`WalletDetailScreen`)**:
  - Halaman khusus full-page saat dompet dibuka lebih lanjut:
    - Menampilkan kartu saldo utama neo-brutalist dengan warna akun dompet tersebut.
    - Arus masuk & keluar khusus dompet tersebut.
    - Tombol penyesuaian/rekonsiliasi saldo & tambah mutasi langsung.
    - Daftar lengkap transaksi yang terjadi di dompet itu.
- **Baris Aksi Cepat (Sub-Header)**:
  - Badge Sisa Saldo bulan aktif berdampingan dengan filter pills (`Semua`, `Masuk`, `Keluar`) dan tombol `+ Catat` di kanan.
  - Search bar ramping di bawahnya.
