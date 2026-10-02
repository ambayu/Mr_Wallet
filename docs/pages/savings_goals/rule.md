# Halaman Kelola Pencapaian (Target Tabungan) — Rules

## 1. Peran Halaman
Master menu untuk mengelola **Pencapaian / Target Tabungan** (*savings goals*): membuat impian ("mau beli apa"), menetapkan target dana, memantau progres, menambah/menarik dana, mengedit, dan menghapus.

## 2. Struktur Data
- Tabel `savings_goals` (skema DB versi 2):
  - `id`, `name`, `target_amount`, `saved_amount`, `deadline` (nullable), `icon`, `color`, `created_at`.
- Model: `SavingsGoalModel` (getter `progress`, `progressPercent`, `remaining`, `isAchieved`).
- Repository: `SavingsGoalRepository` (getAll, insert, update, delete, `addFunds` atomik dengan `MAX(0, ...)`).
- Provider: `SavingsGoalProvider` (goals, totalTarget, totalSaved, addGoal, updateGoal, deleteGoal, addFunds).

## 3. Aturan Komponen & Layout
- **Header (AppBar)**: Latar `butterYellow`, border bawah hitam `2.2px`, tombol kembali bulat neo-brutalis, judul "Kelola Pencapaian".
- **Kartu Ringkasan**: NeoCard hijau pastel (`#D4F8C4`) menampilkan total terkumpul / total target + progress bar keseluruhan.
- **Tombol `+ Tambah Pencapaian`**: NeoButton pink pastel (`#FFCCD8`), tinggi 48, radius 24.
- **Kartu Pencapaian**: NeoCard putih berisi ikon (warna kustom goal), nama, `terkumpul / target`, tenggat (opsional), progress bar, persentase/`🎉 Tercapai!`, dan tombol **`Tambah Dana`**.
- **Aksi per Kartu**: Ikon **Edit** (kuning) dan **Hapus** (merah pastel) di kanan atas kartu.
- **Empty State**: Ikon + pesan ajakan membuat pencapaian pertama.

## 4. Dialog Terkait
- **`AddSavingsGoalDialog`**: mode tambah & edit. Field: nama ("Mau Beli / Capai Apa?"), target dana (auto-format rupiah), tenggat opsional (date picker), pilihan ikon (10 opsi), pilihan warna (6 opsi).
- **`AddFundsDialog`**: menambah atau menarik dana (`saved_amount`) secara manual. **Tidak** memotong saldo wadah rekening — pencatatan progres bersifat mandiri sesuai keputusan desain.

## 5. Integrasi
- **Halaman Tabungan** (`wallets_screen.dart`): dua tombol terpisah — `+ Wadah` (tambah wadah rekening) dan `Pencapaian` (buka halaman ini). Daftar pencapaian menampilkan maksimal 3 teratas + tombol "Lihat Semua".
- **Halaman Home** (`home_screen.dart`): kartu "Tujuan Keuangan" menampilkan pencapaian teratas secara dinamis.
