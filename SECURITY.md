# Security Guide - Remote Control App

## 🔒 Overview

Panduan ini menjelaskan langkah-langkah keamanan yang telah diterapkan untuk melindungi kredensial Supabase dan mencegah reverse engineering pada aplikasi Remote Control.

## 📁 Environment Variables

### Implementasi

Kredensial Supabase disimpan dalam file `.env` yang **TIDAK** di-commit ke version control:

```bash
# File: .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### Keuntungan
- ✅ Kredensial tidak terekspos di kode sumber
- ✅ Tidak ter-commit ke Git repository
- ✅ Mudah mengganti kredensial untuk environment berbeda (dev/staging/production)

### Setup untuk Developer Baru

1. Copy file template:
   ```bash
   # Web Controller
   cp web_controller/.env.example web_controller/.env
   
   # Android Receiver
   cp android_receiver/.env.example android_receiver/.env
   ```

2. Edit file `.env` dan isi dengan kredensial Supabase Anda:
   ```bash
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_actual_anon_key
   ```

## 🛡️ Proteksi Reverse Engineering

### Code Obfuscation (Android)

Untuk build production APK dengan obfuscation, gunakan command berikut:

```bash
cd android_receiver

# Build APK dengan obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# Build App Bundle dengan obfuscation
flutter build appbundle --release --obfuscate --split-debug-info=./debug-info
```

### Apa yang Dilindungi?

- **Nama class & function**: Diubah jadi karakter acak (a, b, c, dst)
- **String literals**: Tetap ada, tapi logic sulit dipahami
- **Debug info**: Disimpan terpisah untuk crash reporting

### Contoh Hasil Obfuscation

**Sebelum:**
```dart
class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'];
}
```

**Sesudah obfuscation:**
```
class a {
  static String get b => c.d['SUPABASE_URL'];
}
```

## 🔐 Keamanan Berlapis

### 1. Environment Variables
- Kredensial tidak hardcoded di source code
- File `.env` di-ignore oleh Git

### 2. Code Obfuscation
- Perlu untuk production builds
- Menyulitkan reverse engineering

### 3. Supabase Row Level Security (RLS)
**PENTING**: Ini adalah pertahanan utama!

Anon key memang public-facing, tapi keamanan sebenarnya ada di:
- RLS policies di Supabase
- Rate limiting
- API validation

### 4. Certificate Pinning (Opsional - Advanced)
Untuk keamanan ekstra, gunakan certificate pinning untuk memverifikasi koneksi ke Supabase.

## 🚀 Best Practices Deployment

### Development
```bash
# Gunakan .env lokal
flutter run
```

### Production
```bash
# Build dengan obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# Simpan debug-info untuk crash reporting
# JANGAN commit folder debug-info ke Git
```

### Environment Berbeda

Buat file `.env` terpisah:
- `.env.dev` - Development
- `.env.staging` - Staging  
- `.env.production` - Production

Lalu load sesuai environment:
```dart
await dotenv.load(fileName: '.env.production');
```

## ⚠️ Hal yang HARUS Dihindari

❌ **JANGAN** commit file `.env` ke Git  
❌ **JANGAN** hardcode kredensial di kode  
❌ **JANGAN** share file `.env` via chat/email  
❌ **JANGAN** build production tanpa obfuscation  
❌ **JANGAN** lupa setup RLS di Supabase

## ✅ Checklist Keamanan

Sebelum deploy ke production:

- [ ] File `.env` ada di `.gitignore`
- [ ] Credentials tidak ada di source code
- [ ] Build menggunakan `--obfuscate` flag
- [ ] RLS policies aktif di Supabase
- [ ] API rate limiting dikonfigurasi
- [ ] Error messages tidak expose sensitive info
- [ ] Debug logging dimatikan di production

## 📱 Verifikasi Keamanan

### Test 1: Git Check
```bash
# Pastikan .env tidak tracked
git status

# .env seharusnya TIDAK muncul di untracked files jika sudah di .gitignore
```

### Test 2: Decompile Check (Advanced)
```bash
# Extract APK
apktool d app-release.apk

# Cek apakah class names ter-obfuscate
# Hasilnya harus sulit dibaca (a.class, b.class, dll)
```

## 🆘 Jika Credentials Terekspos

Jika kredensial tidak sengaja ter-commit atau terekspos:

1. **Segera regenerate** anon key di Supabase Dashboard
2. Update file `.env` dengan key baru
3. Rebuild dan redeploy aplikasi
4. Rotate API keys jika perlu
5. Review RLS policies

## 📚 Referensi

- [Flutter Obfuscation Docs](https://docs.flutter.dev/deployment/obfuscate)
- [Supabase Security Best Practices](https://supabase.com/docs/guides/platform/going-into-prod)
- [Row Level Security (RLS)](https://supabase.com/docs/guides/auth/row-level-security)

## 💡 Tips Tambahan

1. **Gunakan Secrets Manager** untuk CI/CD (GitHub Secrets, etc)
2. **Enable API rate limiting** di Supabase dashboard
3. **Monitor API usage** untuk detect anomali
4. **Rotate keys secara berkala** sebagai best practice
5. **Setup logging & monitoring** untuk security events

---

**Catatan**: Keamanan adalah proses berlapis. Tidak ada satu solusi yang 100% aman, tapi kombinasi dari best practices di atas akan membuat aplikasi Anda jauh lebih sulit untuk di-exploit.
