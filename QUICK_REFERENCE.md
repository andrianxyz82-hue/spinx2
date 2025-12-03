# 🚀 Quick Reference - Secure Build Commands

## Development Mode
```bash
# Web Controller
cd web_controller
flutter run -d chrome

# Android Receiver  
cd android_receiver
flutter run
```

## Production Build (AMAN - Dengan Obfuscation)
```bash
cd android_receiver

# Build APK dengan obfuscation & split debug info
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Build App Bundle untuk Play Store
```bash
cd android_receiver
flutter build appbundle --release --obfuscate --split-debug-info=./debug-info
```

## ⚠️ JANGAN Build Tanpa Obfuscation untuk Production
```bash
# ❌ TIDAK AMAN - Mudah di-reverse engineer
flutter build apk --release

# ✅ AMAN - Pakai obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

## Penjelasan Flags

| Flag | Fungsi |
|------|--------|
| `--release` | Build mode production (optimized) |
| `--obfuscate` | Acak nama class/function agar sulit dibaca |
| `--split-debug-info=./debug-info` | Simpan debug info terpisah untuk crash reporting |

## Keamanan File .env

### ✅ AMAN - File sudah di .gitignore
```bash
# Cek status git (seharusnya .env TIDAK muncul)
git status

# .env tidak akan muncul di untracked files
```

### ⚠️ Jika .env Ter-commit
```bash
# 1. Hapus dari Git (tapi tetap di local)
git rm --cached .env

# 2. Commit perubahan
git commit -m "Remove .env from version control"

# 3. Regenerate credentials di Supabase Dashboard
```

## Setup untuk Developer Baru
```bash
# 1. Copy template
cp .env.example .env

# 2. Edit .env dan isi credentials
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your_anon_key

# 3. Install dependencies
flutter pub get

# 4. Run
flutter run
```

## Troubleshooting

### Error: SUPABASE_URL not found
```bash
# Solusi: Pastikan file .env ada dan terisi
ls -la .env
cat .env
```

### Build Gagal
```bash
# Clean build cache
flutter clean
flutter pub get
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

---

**📖 Dokumentasi Lengkap**: Lihat [SECURITY.md](file:///d:/Spinx/remote_control_app/SECURITY.md) dan [README.md](file:///d:/Spinx/remote_control_app/README.md)
