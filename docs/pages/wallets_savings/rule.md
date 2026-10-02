# Halaman Tabungan & Wadah Rekening — Rules

## 1. Peran Halaman
Mengelola target tabungan masa depan (*savings goals*) dan wadah rekening kas/bank pengguna (*multi-account segregation*).

## 2. Aturan Komponen & Layout
- Header dengan judul tebal dan ikon aksi rekonsiliasi.
- Total Tabungan Card berlatar hijau pastel (`Color(0xFFD4F8C4)`) dengan maskot kepiting perayaan selebrasi.
- **Dua tombol aksi terpisah** (dipisah fungsinya):
  - **`+ Wadah`** (pink pastel) → membuka `AddWalletDialog` untuk menambah **wadah rekening** (Tunai/Bank/E-Wallet).
  - **`Pencapaian`** (sky blue pastel) → membuka halaman master `SavingsGoalsScreen`.
- **Section "Wadah Rekening"**: menampilkan daftar seluruh wadah rekening pengguna dari `WalletProvider`. Setiap kartu berisi ikon (warna kustom), nama, tipe (Tunai/Bank/E-Wallet), badge "Utama", dan saldo. Kartu dapat di-tap untuk membuka `WalletDetailScreen`. Tampil empty state bila belum ada wadah.
- **Section "Pencapaian"**: menampilkan maksimal **3 pencapaian teratas** dari `SavingsGoalProvider` dengan tombol "Lihat Semua". Setiap kartu memiliki progress bar dan tombol **`Tambah Dana`** (`AddFundsDialog`).
- Jika belum ada pencapaian, tampilkan empty state dengan ajakan membuat pencapaian.
- Card motivasi di bagian bawah berlatar kuning cerah dengan maskot tropis santai.
