# 🕌 Ruang Shalat

Aplikasi mobile panduan ibadah shalat berbasis Flutter. Dibuat untuk Tugas Kelompok mata kuliah **Pemrograman Mobile** Semester 6.

---

## ✨ Fitur

| Fitur | Deskripsi | Status |
|-------|-----------|--------|
| 🏠 **Beranda** | Jadwal shalat harian, countdown waktu shalat berikutnya | ✅ Selesai |
| 📖 **Al-Qur'an** | Teks Arab, latin, terjemahan surah (berbasis API) | ✅ Selesai |
| 📚 **Panduan** | Tata cara shalat wajib, wudhu, doa, dan dzikir (Offline) | ✅ Selesai |
| 🧭 **Kiblat** | Kompas penunjuk arah kiblat | 🔄 Dalam Pengembangan |
| ⚙️ **Lainnya** | Profil, tasbih digital, pengaturan | 🔄 Dalam Pengembangan |

---

## 🌐 Integrasi API

Aplikasi ini menggunakan beberapa RESTful API eksternal pihak ketiga untuk mendatangkan data secara dinamis dan *real-time*:

1. **[MyQuran API v2](https://api.myquran.com/)**
   - Mengambil data seluruh kota/kabupaten di Indonesia.
   - Mengambil data jadwal shalat akurat berdasarkan ID kota untuk keperluan hari ini dan prediksi bulanan.
2. **[EQuran.id API v2](https://equran.id/)**
   - Mendapatkan daftar kumpulan surah Al-Qur'an.
   - Mengambil detail ayat per ayat secara dinamis, mencakup teks Arab, transliterasi Latin, dan terjemahan bahasa Indonesia.

*Catatan: Fitur Panduan Ibadah (Shalat, Wudhu, Doa) beroperasi sepenuhnya secara luring (offline) berkat integrasi data internal statis di dalam *source code*.*

---

## 📁 Struktur Folder

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart       # Konstanta warna (Emerald Green, Gold)
│   └── theme/
│       └── app_theme.dart        # Konfigurasi Material 3 ThemeData
│
├── features/
│   ├── home/
│   │   └── home_screen.dart      # Beranda: jadwal shalat & countdown
│   ├── guide/
│   │   └── guide_screen.dart     # Panduan: shalat, wudhu, doa
│   ├── qibla/                    # (coming soon)
│   └── settings/                 # (coming soon)
│
├── shared/
│   └── widgets/
│       └── main_bottom_nav_bar.dart  # Bottom navigation bar reusable
│
└── main.dart                     # Entry point aplikasi
```

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **Bahasa**: Dart
- **UI**: Material Design 3
- **State Management**: `setState` (StatefulWidget)
- **Min SDK**: Android 5.0 (API 21) / iOS 12

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK sudah terinstall ([panduan instalasi](https://docs.flutter.dev/get-started/install))
- Android Studio / VS Code
- Emulator atau perangkat fisik

### Langkah-langkah

1. **Clone repository**
   ```bash
   git clone git@github.com:afrizalfikrii/ruangshalat.git
   cd ruangshalat
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

4. **Build APK** (opsional)
   ```bash
   flutter build apk --release
   ```

---

## 🎨 Panduan Desain

| Elemen | Nilai |
|--------|-------|
| Warna Utama | `#1E6351` (Emerald Green) |
| Warna Aksen | `#D4AF37` (Gold) |
| Background | `#F5F5F7` |
| Design System | Material 3 |

---

## 📂 Konvensi Kode

- **Penamaan file**: `snake_case.dart`
- **Penamaan class**: `PascalCase`
- **Warna**: Selalu gunakan `AppColors.*` bukan hardcoded hex
- **Theme**: Selalu gunakan `AppTheme.light` bukan inline `ThemeData`
- **Fitur baru**: Buat folder baru di `lib/features/<nama_fitur>/`

---

## 👥 Tim

| Nama | Role |
|------|------|
| Afrizal Fikri | Developer |
| *(tambahkan anggota lain)* | *(role)* |

---

## 📝 Lisensi

Proyek ini dibuat untuk keperluan akademis — Tugas Kelompok Pemrograman Mobile.
