# 🏗️ Codemagic Setup Guide - Android Receiver

Panduan lengkap untuk build APK Android Receiver di Codemagic dengan keamanan maksimal.

## 🎯 Overview

Codemagic akan:
- ✅ Build APK dengan **obfuscation** (aman dari reverse engineering)
- ✅ Load credentials dari **environment variables** (tidak exposed di logs)
- ✅ Generate APK siap deploy
- ✅ Simpan debug info untuk crash reporting

## 📋 Prerequisites

- [ ] Akun Codemagic (gratis di [codemagic.io](https://codemagic.io))
- [ ] Repository Git (GitHub/GitLab/Bitbucket)
- [ ] Supabase credentials (URL & anon key)

---

## 🚀 Setup Steps

### Step 1: Push Code ke Git Repository

```bash
cd d:/Spinx/remote_control_app/android_receiver

# Initialize git (jika belum)
git init

# Add files (pastikan .env sudah di .gitignore!)
git add .
git commit -m "Initial commit - Android Receiver"

# Push ke remote repository
git remote add origin https://github.com/username/android-receiver.git
git push -u origin main
```

⚠️ **PENTING**: Pastikan file `.env` **TIDAK** ter-commit!

```bash
# Verify .env tidak ter-commit
git status
# .env seharusnya TIDAK muncul karena sudah di .gitignore
```

---

### Step 2: Connect Repository ke Codemagic

1. **Login ke Codemagic**
   - Go to [codemagic.io](https://codemagic.io)
   - Login dengan GitHub/GitLab/Bitbucket

2. **Add Application**
   - Klik **Add application**
   - Pilih repository: `android-receiver`
   - Klik **Finish setup**

---

### Step 3: Configure Environment Variables

**CRITICAL**: Jangan hardcode credentials di `codemagic.yaml`!

1. **Go to App Settings**
   - Pilih app `android-receiver`
   - Klik **⚙️ Settings** (di kanan atas)

2. **Add Environment Variables**
   - Scroll ke **Environment variables**
   - Klik **Add variable**

   **Variable 1**:
   ```
   Name: SUPABASE_URL
   Value: https://your-project.supabase.co
   ☑ Secure (check this!)
   ```

   **Variable 2**:
   ```
   Name: SUPABASE_ANON_KEY
   Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ☑ Secure (check this!)
   ```

3. **Save Changes**

**Mengapa "Secure"?**
- ✅ Values tidak ditampilkan di logs
- ✅ Tidak bisa dilihat di UI setelah disimpan
- ✅ Lebih aman dari credential exposure

---

### Step 4: Add codemagic.yaml Configuration

File [`codemagic.yaml`](file:///d:/Spinx/remote_control_app/android_receiver/codemagic.yaml) sudah saya buatkan.

**Pastikan file ini ada di root folder `android_receiver/`:**
```
android_receiver/
├── codemagic.yaml  ← File ini
├── lib/
├── android/
└── pubspec.yaml
```

**Commit dan push**:
```bash
git add codemagic.yaml
git commit -m "Add Codemagic configuration"
git push
```

---

### Step 5: Start Build

1. **Go to Codemagic Dashboard**
   - Pilih app `android-receiver`

2. **Start New Build**
   - Klik **Start new build**
   - Pilih workflow: **android-receiver-release**
   - Klik **Start build**

3. **Monitor Build Progress**
   - Build akan memakan waktu ~5-10 menit
   - Watch logs untuk errors

---

## 📦 Build Output

### APK Location

Setelah build sukses:
```
Artifacts:
├── app-release.apk  ← APK aman dengan obfuscation ✅
└── debug-info/      ← Debug symbols (jangan dipublish!)
```

### Download APK

1. Go to build yang sudah selesai
2. Klik tab **Artifacts**
3. Download `app-release.apk`

---

## 🔒 Security Features

### ✅ What's Protected

1. **Environment Variables**
   - Credentials dari Codemagic environment vars
   - Tidak hardcoded di code
   - Tidak muncul di logs (karena "Secure")

2. **Code Obfuscation**
   ```yaml
   flutter build apk \
     --release \
     --obfuscate \
     --split-debug-info=./debug-info
   ```
   - Class & function names di-scramble
   - Sulit di-reverse engineer

3. **Debug Info Split**
   - Debug symbols disimpan terpisah
   - APK tidak contain symbols
   - Bisa digunakan untuk crash reporting

---

## 🔍 Build Troubleshooting

### ❌ Error: "SUPABASE_URL not found"

**Penyebab**: Environment variables belum diset di Codemagic

**Solusi**:
1. Go to **App Settings > Environment variables**
2. Add `SUPABASE_URL` dan `SUPABASE_ANON_KEY`
3. Check ☑ **Secure** option
4. Retry build

---

### ❌ Error: "Build failed - Gradle error"

**Penyebab**: Dependencies issue

**Solusi**:
```yaml
# Add ke codemagic.yaml di scripts section
- name: Clean before build
  script: |
    flutter clean
    flutter pub get
    flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

---

### ❌ Build Berhasil tapi APK Size Terlalu Besar

**Solusi**: Build App Bundle instead

```yaml
# Uncomment di codemagic.yaml
- name: Build App Bundle
  script: |
    flutter build appbundle \
      --release \
      --obfuscate \
      --split-debug-info=./debug-info
```

App Bundle biasanya 30-50% lebih kecil dari APK.

---

## 📊 Build Configuration Explained

### codemagic.yaml Breakdown

```yaml
# 1. Create .env from environment variables
cat > .env <<EOF
SUPABASE_URL=$SUPABASE_URL      # ← Dari Codemagic UI
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
EOF

# 2. Build dengan obfuscation
flutter build apk \
  --release \              # Production mode
  --obfuscate \            # Scramble code
  --split-debug-info=./debug-info  # Split debug symbols
```

---

## 🎯 Multiple Environments (Optional)

Jika mau separate Dev & Production:

### Option 1: Multiple Workflows

```yaml
workflows:
  android-debug:
    environment:
      groups:
        - dev_credentials
    scripts:
      - flutter build apk --debug
  
  android-release:
    environment:
      groups:
        - prod_credentials
    scripts:
      - flutter build apk --release --obfuscate
```

### Option 2: Environment Groups

Di Codemagic UI:
1. Create group **dev_credentials**
   - SUPABASE_URL_DEV
   - SUPABASE_ANON_KEY_DEV

2. Create group **prod_credentials**
   - SUPABASE_URL_PROD
   - SUPABASE_ANON_KEY_PROD

---

## 📱 Deploy APK

### Manual Distribution

1. Download APK dari Codemagic
2. Share via:
   - Email
   - Cloud storage (Drive, Dropbox)
   - Internal distribution platform

### Auto-Publish ke Google Play (Advanced)

```yaml
publishing:
  google_play:
    credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
    track: internal  # atau: alpha, beta, production
    submit_as_draft: true
```

Setup:
1. Create Google Cloud Service Account
2. Download JSON credentials
3. Add ke Codemagic environment variables
4. Uncomment section di `codemagic.yaml`

---

## ✅ Post-Build Checklist

Setelah APK di-download:

- [ ] Install di test device
- [ ] Verify .env values loaded correctly
- [ ] Test connection ke Supabase Realtime
- [ ] Test semua commands (flash, vibrate, sound)
- [ ] Check APK size (<50MB ideal)
- [ ] Verify obfuscation (decompile test dengan jadx/apktool)
- [ ] Test di berbagai Android versions (8.0+)

---

## 🆘 Getting Help

**Build Logs**: 
- Codemagic menampilkan detailed logs
- Check untuk error messages
- Search error di [Codemagic Docs](https://docs.codemagic.io)

**Common Issues**:
- Missing environment variables
- Gradle version conflicts
- Flutter SDK issues
- Android SDK license issues

---

## 📚 References

- [Codemagic Documentation](https://docs.codemagic.io)
- [Flutter Build APK Docs](https://docs.flutter.dev/deployment/android)
- [Code Obfuscation Guide](https://docs.flutter.dev/deployment/obfuscate)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)

---

## 💡 Pro Tips

1. **Cache Dependencies**: Codemagic otomatis cache Flutter SDK & dependencies
2. **Parallel Builds**: Bisa build multiple configurations sekaligus
3. **Webhooks**: Auto-trigger build on git push
4. **Slack Notifications**: Integrate dengan Slack untuk build notifications
5. **Version Naming**: Use semantic versioning (1.0.0, 1.0.1, etc)

---

**✨ Setup selesai! Sekarang Anda bisa build APK dengan aman di Codemagic.**

**Next Steps**:
1. Push code ke Git ✅
2. Connect ke Codemagic ✅
3. Add environment variables ✅
4. Start build ✅
5. Download & test APK ✅
