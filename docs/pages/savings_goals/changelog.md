# Halaman Kelola Pencapaian (Target Tabungan) — Changelog

## [Unreleased]
- Menambahkan fitur baru **Pencapaian / Target Tabungan** (savings goals).
- Menambah tabel `savings_goals` (skema DB naik ke **versi 2**) dengan `onUpgrade` aman + seed awal (Liburan ke Jepang, Beli Laptop, Dana Darurat).
- Membuat `SavingsGoalModel`, `SavingsGoalRepository`, dan `SavingsGoalProvider` (didaftarkan di `main.dart`).
- Membuat halaman master **`SavingsGoalsScreen`** ("Kelola Pencapaian"): ringkasan total, daftar kartu progres, aksi edit/hapus/tambah dana, dan empty state.
- Membuat dialog **`AddSavingsGoalDialog`** (tambah/edit: nama, target dana, tenggat, ikon, warna) dan **`AddFundsDialog`** (tambah/tarik dana manual).
- Integrasi halaman **Tabungan**: memisahkan tombol `+ Wadah` dan `Pencapaian`, mengganti daftar pencapaian hardcoded dengan data asli.
- Integrasi halaman **Home**: kartu "Tujuan Keuangan" kini dinamis dari pencapaian teratas.
