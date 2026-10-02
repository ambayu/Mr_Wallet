# Halaman Tabungan & Wadah Rekening — Changelog

## [Initial]
- Tata letak dasar tujuan tabungan dan kartu maskot kepiting perayaan selebrasi.

## [Unreleased]
- **Memisahkan konsep "Wadah Rekening" dan "Pencapaian"**: tombol lama `+ Tambah Tabungan` yang membuka form wadah rekening diganti menjadi dua tombol — `+ Wadah` (tambah wadah rekening) dan `Pencapaian` (buka halaman Kelola Pencapaian).
- Mengganti daftar pencapaian **hardcoded** (Liburan ke Jepang / Beli Laptop / Dana Darurat) dengan data asli dari `SavingsGoalProvider` (maks 3 teratas).
- Menambahkan tombol **`Tambah Dana`** di setiap kartu pencapaian (`AddFundsDialog`).
- Menambahkan empty state pencapaian.
- Menambahkan **section "Wadah Rekening"**: daftar seluruh wadah rekening (ikon, nama, tipe, badge Utama, saldo) yang dapat di-tap menuju `WalletDetailScreen`, beserta empty state-nya.
