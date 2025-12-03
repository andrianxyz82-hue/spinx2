# ✅ Supabase Setup Checklist

Checklist cepat untuk memastikan Supabase sudah siap digunakan.

## 🎯 Minimal Setup (5 Menit)

Ini yang **WAJIB** untuk aplikasi bisa jalan:

### 1. Get Credentials ✅
- [ ] Login ke [app.supabase.com](https://app.supabase.com)
- [ ] Pilih project (atau buat baru jika belum ada)
- [ ] Go to **⚙️ Project Settings → API**
- [ ] Copy **Project URL**
- [ ] Copy **anon public** key

### 2. Update File .env ✅
- [ ] Edit `web_controller/.env`
- [ ] Edit `android_receiver/.env`
- [ ] Paste URL dan anon key ke kedua file
- [ ] Verify tidak ada typo

**Example**:
```bash
SUPABASE_URL=https://abcdefgh.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. Verify Realtime Enabled ✅
- [ ] Go to **⚙️ Project Settings → API**
- [ ] Scroll ke **Realtime** section
- [ ] Pastikan toggle **Enable Realtime** = **ON** ✅
- [ ] (Biasanya sudah ON by default)

---

**🎉 Selesai! Aplikasi siap dijalankan.**

## 📱 Test Run

```bash
# Terminal 1: Run Android Receiver
cd android_receiver
flutter run

# Terminal 2: Run Web Controller
cd web_controller  
flutter run -d chrome
```

### Expected Result:
1. ✅ Android receiver shows Device ID
2. ✅ Web controller connects sukses
3. ✅ Commands (Flash, Vibrate) bekerja
4. ✅ Response terkirim balik ke web

---

## 🔒 Optional: Security Setup (Recommended untuk Production)

Jika sudah jalan dan mau lebih aman:

### Rate Limiting
- [ ] Go to **⚙️ Project Settings → API**
- [ ] Scroll ke **Rate Limiting**
- [ ] Set limit (contoh: 10 req/sec)

### Monitoring
- [ ] Go to **📊 Project Settings → Usage**
- [ ] Check realtime connections
- [ ] Monitor bandwidth usage

### SSL/Security
- [ ] Pastikan URL menggunakan **HTTPS** (bukan HTTP)
- [ ] (Optional) Setup custom domain

---

## 🚫 Yang TIDAK Perlu

Anda **TIDAK** perlu:

- ❌ Buat database table (broadcast tidak perlu table)
- ❌ Setup Row Level Security (kecuali untuk production tingkat lanjut)
- ❌ Configure webhooks
- ❌ Setup Edge Functions
- ❌ Enable database replication

Aplikasi ini **HANYA** butuh:
- ✅ Realtime enabled
- ✅ Valid credentials
- ✅ Internet connection

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "Connection failed" | Check URL & anon key di `.env` |
| "SUPABASE_URL not found" | File `.env` belum dibuat atau kosong |
| "WebSocket error" | Check internet connection |
| Commands tidak terkirim | Verify Device ID sama di kedua app |
| Build error | Run `flutter pub get` |

---

**Lihat [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) untuk panduan lengkap dengan screenshots dan troubleshooting detail.**
