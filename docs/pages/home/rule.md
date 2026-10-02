# Halaman Home (Dashboard) — Rules

## 1. Peran Halaman
Layar beranda utama yang menyajikan ringkasan saldo total kekayaan bersih, aksi cepat utama (*Quick Actions*), maskot kepiting Mr. Wallet, serta pratinjau tujuan tabungan & transaksi terkini.

## 2. Aturan Komponen & Layout
- **Banner Saldo Utama**:
  - Berlatar belakang warna pastel `primaryYellow` / `butterYellow`.
  - Border hitam tebal `2.2px` dengan bayangan neo-brutalis.
  - Menampilkan angka nominal dengan `CurrencyFormatter.formatRupiah` berbobot `FontWeight.w900`.
  - Maskot kepiting pop-out di pojok kanan bawah.
- **Quick Action Buttons**:
  - Tombol **"Tabung"**: Menggantikan tombol terpisah pengeluaran dan pemasukan menjadi 1 tombol utama yang langsung mengarahkan user ke halaman riwayat dan pencatatan transaksi (`index 1`).
  - Tombol **"Scan"**: Memicu modal Camera Bill Snap OCR.
  - Setiap tombol aksi wajib berukuran proporsional, berborder hitam, dan memiliki icon serta label yang kontras.
- **Card Section Bawah**:
  - Berlatar belakang putih bersih dengan border halus dan bayangan lembut.
  - Memiliki header dengan link cepat "Lihat Semua".
