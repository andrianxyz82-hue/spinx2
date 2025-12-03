# ✅ Codemagic Build - Quick Checklist

Checklist cepat untuk build APK di Codemagic dengan aman.

## 🎯 Setup (One-time, ~10 menit)

### 1. Repository Ready
- [ ] Code di-push ke Git (GitHub/GitLab/Bitbucket)
- [ ] File `.env` **TIDAK** ter-commit (check dengan `git status`)
- [ ] File `codemagic.yaml` ada di root `android_receiver/`

### 2. Codemagic Account
- [ ] Login ke [codemagic.io](https://codemagic.io)
- [ ] Connect repository
- [ ] Add application `android-receiver`

### 3. Environment Variables (CRITICAL!)
Di Codemagic UI → App Settings → Environment Variables:

- [ ] Add `SUPABASE_URL`
  - Value: `https://your-project.supabase.co`
  - ☑ **Secure** checked

- [ ] Add `SUPABASE_ANON_KEY`
  - Value: `eyJhbGci...` (your anon key)
  - ☑ **Secure** checked

---

## 🚀 Build APK (Every time)

### 1. Start Build
- [ ] Go to Codemagic dashboard
- [ ] Select workflow: **android-receiver-release**
- [ ] Click **Start new build**

### 2. Monitor Build (~5-10 min)
- [ ] Wait untuk build selesai
- [ ] Check logs jika ada error
- [ ] Verify "Build successful" ✅

### 3. Download APK
- [ ] Go to **Artifacts** tab
- [ ] Download `app-release.apk`
- [ ] APK ready untuk install!

---

## 🔒 Security Verification

Build APK sudah aman jika:
- ✅ Credentials dari environment variables (bukan hardcoded)
- ✅ Build dengan flag `--obfuscate`
- ✅ `.env` tidak ter-commit ke Git
- ✅ Environment variables set sebagai "Secure" di Codemagic

---

## 📋 Supabase Settings

### ❌ TIDAK Perlu Setting Ini:
- Database → Realtime (untuk Postgres changes)
- Database → Tables
- Database → Functions
- Authentication setup

### ✅ Yang Perlu (Sudah Selesai):
- Project Settings → API → Realtime: **ON** ✅
- Credentials (URL & anon key) copied ✅

**Alasan**: Aplikasi pakai Realtime **Broadcast/Channels**, bukan Database Realtime.

---

## 🧪 Test APK

Setelah download:

1. **Install di Android Device**
   ```bash
   adb install app-release.apk
   ```

2. **Test Connection**
   - Open app → copy Device ID
   - Open web controller → paste ID → connect
   - Test commands: Flash, Vibrate, Sound

3. **Verify Security**
   - APK tidak contain hardcoded credentials ✅
   - Code ter-obfuscate ✅

---

## 🆘 Common Issues

| Issue | Solution |
|-------|----------|
| "SUPABASE_URL not found" | Add environment variables di Codemagic UI |
| Build gagal | Check logs, pastikan `codemagic.yaml` correct |
| APK install error | Enable "Install from unknown sources" |
| Connection failed | Verify credentials di Codemagic env vars |

---

## 📚 Documentation

- [CODEMAGIC_SETUP.md](file:///d:/Spinx/remote_control_app/CODEMAGIC_SETUP.md) - Detailed setup guide
- [SUPABASE_SETUP.md](file:///d:/Spinx/remote_control_app/SUPABASE_SETUP.md) - Supabase configuration
- [SECURITY.md](file:///d:/Spinx/remote_control_app/SECURITY.md) - Security best practices

---

**🎉 That's it! Build di Codemagic dengan keamanan maksimal.**
