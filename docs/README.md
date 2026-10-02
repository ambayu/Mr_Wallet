# Mr. Wallet / SmartFlow — Design System & Architecture Governance

Dokumen ini merupakan panduan resmi (*Single Source of Truth*) untuk desain antarmuka, konsistensi visual, komponen UI, dan arsitektur kode di seluruh aplikasi **Mr. Wallet**.

Setiap perubahan tampilan, penambahan halaman baru, atau modifikasi komponen **WAJIB** mematuhi aturan baku yang tertulis di sini.

---

## 🎨 1. Prinsip Desain: Playful Neo-Brutalism

Aplikasi Mr. Wallet mengusung identitas visual **Playful Neo-Brutalism**: kombinasi antara garis batas tegas (*chunky black borders*), bayangan tajam tanpa blur (*hard drop shadow*), sudut tumpul lembut (*rounded corners*), palet warna pastel ceria, dan tipografi tebal.

### 1.1. Token Border & Shadow
* **Border Color**: `AppColors.borderBlack` (`#1E1E1E`).
* **Border Width**:
  * Card / Container Utama: `2.0px` – `2.5px`.
  * Button: `2.0px` – `2.5px`.
  * Input Field / Dropdown: `1.8px` – `2.0px`.
  * Badge / Chip / Icon Box: `1.5px` – `1.8px`.
* **Shadow (Drop Shadow Deterministik)**:
  * **Wajib tanpa blur** (`blurRadius: 0`).
  * **Offset Baku**:
    * Card: `Offset(2.5, 3.0)` atau `Offset(2.0, 2.5)`.
    * Button: `Offset(2.0, 2.5)` (ditekan menjadi `Offset(0, 0)`).
    * Header Card: `Offset(0, 3.0)`.
  * **Shadow Color**: `AppColors.shadowBlack` (`#1E1E1E`).

### 1.2. Token Border Radius
* **Container / Card Besar**: `22px` – `28px`.
* **Modal Bottom Sheet**: `Radius.vertical(top: Radius.circular(32))`.
* **Button**: `20px` – `26px` (pill/rounded).
* **Input Field**: `18px`.
* **Badges / Filter Pills**: `14px` – `16px`.

### 1.3. Palet Warna Baku (`AppColors`)
| Nama Token | Hex Code | Penggunaan Utama |
|---|---|---|
| `butterYellow` | `#FEF3A7` | Warna latar aksen, modal dialog, background utama ceria |
| `primaryYellow` | `#FFE86C` | Tombol CTA, card highlight |
| `mintGreen` | `#CEF8BA` | Transaksi Pemasukan (Income), tombol simpan/sukses |
| `bubblePink` | `#FFCCD5` | Transaksi Pengeluaran (Expense), tombol hapus/warning |
| `lavenderPurple`| `#E4DBFA` | Kategori transfer, elemen sekunder |
| `skyBlue` | `#D2EEFC` | Wadah rekening bank, filter netral |
| `softPeach` | `#FFDEB5` | Aksen pelengkap, badge info |
| `cardWhite` | `#FFFFFF` | Background kartu dalam, input field |
| `borderBlack` | `#1E1E1E` | Seluruh outline border dan teks utama |
| `textMuted` | `#71717A` | Subtitle, placeholder, timestamp |

---

## 🔤 2. Tipografi (Typography)
* **Font Family**: Mengikuti tema default aplikasi (`Plus Jakarta Sans`).
* **Hirarki Berat Teks (Font Weight)**:
  * Heading / Angka Nominal Besar: `FontWeight.w900` (Extra Bold / Black).
  * Sub-heading / Title Kartu: `FontWeight.w800` (Bold).
  * Label Input / Button Text: `FontWeight.w700` atau `FontWeight.w800`.
  * Body / Keterangan: `FontWeight.w600`.
  * Placeholder / Hint / Caption: `FontWeight.w500`.

---

## 🧩 3. Komponen Wajib (Strict Reuse)
Dilarang membuat styling Container mentah jika sudah tersedia komponen terstandarisasi:
1. **`NeoCard`**: Kontainer kartu neo-brutalis dengan border hitam, bayangan offset, dan properti `clipBehavior` opsional.
2. **`NeoButton`**: Tombol dengan tactile-press feedback, border hitam, dan bayangan offset.
3. **`NeoTextField`**: Input field dengan label terstruktur, border hitam, dan bayangan offset.
4. **`NeoBadge`**: Chip/pill status untuk kategori, filter, dan tanggal.
5. **`NeoHeaderCard`**: AppBar / Header atas halaman dengan styling neo-brutalis.

---

## 📂 4. Direktori Living Docs Per Halaman
Setiap halaman memiliki folder khusus yang memuat `rule.md` (aturan desain & UX halaman) dan `changelog.md` (riwayat pembaruan):
* `docs/pages/home/`
* `docs/pages/transaction_history/`
* `docs/pages/wallets_savings/`
* `docs/pages/savings_goals/`
* `docs/pages/dialogs_forms/`
* `docs/pages/track_analytics/`
* `docs/pages/tasks_reminders/`
