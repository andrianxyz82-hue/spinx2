# Remote Control App - Setup Guide

Aplikasi Remote Control terdiri dari dua bagian:
1. **Web Controller** - Interface web untuk mengirim perintah
2. **Android Receiver** - Aplikasi Android yang menerima dan menjalankan perintah

## 🚀 Quick Start

### Prasyarat

- Flutter SDK (3.0.0+)
- Akun Supabase
- Android device/emulator untuk Android Receiver

### Setup Environment Variables

#### 1. Web Controller

```bash
cd web_controller

# Copy template environment file
cp .env.example .env

# Edit .env dan isi dengan kredensial Supabase Anda
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your_anon_key_here
```

#### 2. Android Receiver

```bash
cd android_receiver

# Copy template environment file
cp .env.example .env

# Edit .env dan isi dengan kredensial Supabase Anda
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your_anon_key_here
```

### Install Dependencies

#### Web Controller
```bash
cd web_controller
flutter pub get
```

#### Android Receiver
```bash
cd android_receiver
flutter pub get
```

## 🏃 Running the Apps

### Web Controller (Development)

```bash
cd web_controller
flutter run -d chrome
```

### Android Receiver

```bash
cd android_receiver

# Development mode
flutter run --dart-define-from-file=.env

# Build release APK dengan obfuscation untuk keamanan
flutter build apk --release --obfuscate --split-debug-info=./debug-info --dart-define-from-file=.env
```

## 📱 Cara Menggunakan

1. **Jalankan Android Receiver** di device Android
   - Aplikasi akan generate Device ID unik
   - Copy Device ID dengan tap pada ID tersebut

2. **Buka Web Controller** di browser
   - Masukkan Device ID dari Android Receiver
   - Klik tombol connect atau tekan Enter

3. **Kirim Perintah** melalui Web Controller:
   - Flash ON/OFF - Nyalakan/matikan flashlight
   - Vibrate - Getarkan device
   - Play Sound - Mainkan audio (perlu file ping.mp3 di assets)

## 🔒 Keamanan

**PENTING**: File `.env` berisi kredensial sensitif dan **TIDAK BOLEH** di-commit ke Git!

Lihat [SECURITY.md](./SECURITY.md) untuk panduan lengkap tentang:
- Environment variables best practices
- Code obfuscation untuk production
- Proteksi terhadap reverse engineering
- Security checklist

### Build untuk Production

```bash
cd android_receiver

# Build dengan obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# Output: build/app/outputs/flutter-apk/app-release.apk
```

## 📁 Struktur Proyek

```
remote_control_app/
├── web_controller/           # Flutter Web App
│   ├── lib/
│   │   ├── config/
│   │   │   └── env_config.dart   # Environment configuration
│   │   └── main.dart
│   ├── .env                  # Environment variables (TIDAK di-commit)
│   ├── .env.example          # Template environment variables
│   ├── .gitignore
│   └── pubspec.yaml
├── android_receiver/         # Flutter Android App
│   ├── lib/
│   │   ├── config/
│   │   │   └── env_config.dart   # Environment configuration
│   │   └── main.dart
│   ├── assets/
│   │   └── ping.mp3          # Audio file untuk play sound
│   ├── .env                  # Environment variables (TIDAK di-commit)
│   ├── .env.example          # Template environment variables
│   ├── .gitignore
│   └── pubspec.yaml
├── SECURITY.md               # Security best practices
└── README.md                 # File ini
```

## 🔧 Troubleshooting

### Error: SUPABASE_URL not found

**Penyebab**: File `.env` tidak ada atau kosong

**Solusi**:
```bash
# Copy template dan isi kredensial
cp .env.example .env
# Edit .env dengan text editor dan isi SUPABASE_URL & SUPABASE_ANON_KEY
```

### Error: Flutter not found

**Solusi**:
```bash
# Install Flutter SDK dari https://flutter.dev/docs/get-started/install
# Atau update path:
export PATH="$PATH:`pwd`/flutter/bin"
```

### Supabase Connection Failed

**Penyebab**: Kredensial salah atau Realtime Channels tidak aktif

**Solusi**:
1. Verifikasi URL dan anon key di Supabase Dashboard
2. Pastikan Realtime di-enable di Project Settings > API
3. Cek RLS policies tidak memblock broadcast

## 🆘 Support

Untuk pertanyaan atau issues:
1. Cek [SECURITY.md](./SECURITY.md) untuk security-related questions
2. Review kode di `lib/config/env_config.dart` untuk environment setup
3. Lihat console logs untuk error details

## 📝 Environment Variables

Kedua aplikasi membutuhkan environment variables berikut:

| Variable | Description | Example |
|----------|-------------|---------|
| `SUPABASE_URL` | URL project Supabase Anda | `https://abc123.supabase.co` |
| `SUPABASE_ANON_KEY` | Anonymous/Public key dari Supabase | `eyJhbGc...` |

**Cara mendapatkan credentials**:
1. Login ke [Supabase Dashboard](https://app.supabase.com)
2. Pilih project Anda
3. Go to Settings > API
4. Copy "Project URL" dan "anon public" key

## ⚙️ Configuration

### Supabase Realtime Setup

Aplikasi ini menggunakan Supabase Realtime Channels. Pastikan:

1. Realtime enabled di project settings
2. Broadcast permissions dikonfigurasi dengan benar
3. (Opsional) Setup RLS policies untuk keamanan ekstra

### Custom Audio (Android Receiver)

Untuk menggunakan custom sound:
1. Tambahkan file audio ke `android_receiver/assets/ping.mp3`
2. File sudah di-declare di `pubspec.yaml` dalam `assets/`

## 🎯 Next Steps

Setelah setup berhasil:
- [ ] Test koneksi antara web controller dan Android receiver
- [ ] Build release APK dengan obfuscation
- [ ] Setup RLS policies di Supabase untuk keamanan
- [ ] Configure rate limiting di Supabase API settings
- [ ] Review [SECURITY.md](./SECURITY.md) untuk production deployment

---

**Happy Coding!** 🚀
