# 🔧 Supabase Setup Guide

Panduan lengkap untuk setup Supabase agar aplikasi Remote Control berjalan dengan baik.

## 📋 Prerequisites

- ✅ Akun Supabase (gratis di [supabase.com](https://supabase.com))
- ✅ Project Supabase yang sudah dibuat
- ✅ Credentials (URL & anon key) sudah dicopy ke file `.env`

## 🚀 Setup Steps

### Step 1: Enable Realtime

Aplikasi ini menggunakan **Supabase Realtime Channels** untuk komunikasi real-time antara web controller dan Android receiver.

1. **Login ke Supabase Dashboard**
   - Go to [app.supabase.com](https://app.supabase.com)
   - Pilih project Anda

2. **Enable Realtime**
   - Klik **Project Settings** (icon ⚙️ di sidebar kiri bawah)
   - Pilih tab **API**
   - Scroll ke bagian **Realtime**
   - Pastikan **Enable Realtime** dalam keadaan **ON** (biasanya default ON)

   ![Realtime Settings](https://supabase.com/docs/img/realtime-settings.png)

### Step 2: Configure Realtime Broadcast

Aplikasi ini menggunakan **Broadcast** feature dari Realtime Channels.

1. **Verifikasi Broadcast Enabled**
   - Di **Project Settings > API > Realtime**
   - Pastikan **Enable Realtime** aktif
   - Broadcast biasanya sudah enabled by default

2. **Tidak Perlu Database Table**
   - ✅ Kabar baik: Untuk Broadcast, Anda **TIDAK** perlu membuat table apapun
   - ✅ Channel dibuat secara dynamic di client-side
   - ✅ Data tidak disimpan di database, hanya real-time messaging

### Step 3: Verify API Settings

1. **Get Credentials**
   - Go to **Project Settings > API**
   - Copy nilai berikut:
     - **Project URL** (contoh: `https://xxxxx.supabase.co`)
     - **anon public** key (di section Project API keys)

2. **Update File .env**
   
   **Web Controller** (`web_controller/.env`):
   ```bash
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOi... (your anon key)
   ```

   **Android Receiver** (`android_receiver/.env`):
   ```bash
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOi... (your anon key)
   ```

   ⚠️ **PENTING**: URL dan anon key harus **SAMA** untuk kedua aplikasi!

## 🔒 Security Setup (Recommended)

### Option 1: Basic (No RLS - Untuk Testing)

Untuk development/testing, Anda bisa langsung pakai tanpa setup apapun:
- ✅ Realtime Broadcast tidak memerlukan RLS
- ✅ Anon key bisa digunakan langsung
- ⚠️ Semua orang dengan anon key bisa listen channels

**Recommended untuk**: Development, testing, proof of concept

### Option 2: Advanced (Dengan Security - Untuk Production)

Untuk production, tambahkan layer security:

#### A. Rate Limiting

1. Go to **Project Settings > API**
2. Scroll ke **Rate Limiting**
3. Configure limits (contoh):
   - **Requests per second**: 10
   - **Burst**: 20

#### B. Custom Domain (Optional)

Gunakan custom domain untuk hide Supabase URL asli:
- Go to **Project Settings > Custom Domains**
- Add domain Anda
- Update `.env` dengan custom domain

#### C. Monitor Usage

1. Go to **Project Settings > Usage**
2. Monitor:
   - Realtime connections
   - Bandwidth usage
   - Active channels

## 🧪 Testing Configuration

### Test 1: Verify Realtime is Active

Dari browser console atau test app:

```javascript
// Test di browser console
const { createClient } = supabase
const client = createClient('YOUR_URL', 'YOUR_ANON_KEY')

const channel = client.channel('test-channel')
  .on('broadcast', { event: 'test' }, (payload) => {
    console.log('Received:', payload)
  })
  .subscribe()

// Send test message
channel.send({
  type: 'broadcast',
  event: 'test',
  payload: { message: 'Hello!' }
})
```

### Test 2: Test dari Aplikasi

1. **Jalankan Android Receiver**
   ```bash
   cd android_receiver
   flutter run
   ```
   - Copy Device ID yang muncul

2. **Jalankan Web Controller**
   ```bash
   cd web_controller
   flutter run -d chrome
   ```
   - Paste Device ID
   - Klik Connect
   - Status harus berubah jadi **"Connected to [device-id]"**

3. **Test Commands**
   - Klik tombol "Flash ON" di web
   - Android receiver harus menerima command dan execute
   - Web controller harus menerima response

## ❌ Troubleshooting

### Issue: Connection Failed / Not Connected

**Penyebab Umum:**
1. URL atau anon key salah
2. Realtime tidak enabled
3. Internet connection issue

**Solusi:**
```bash
# 1. Verifikasi credentials di .env
cat .env

# 2. Pastikan URL benar (harus HTTPS)
SUPABASE_URL=https://xxxxx.supabase.co  ✅
SUPABASE_URL=http://xxxxx.supabase.co   ❌ (HTTP bukan HTTPS)

# 3. Pastikan anon key complete (panjang ~300+ karakter)
```

### Issue: "Subscribed" tapi tidak terima messages

**Penyebab:**
- Channel name berbeda antara sender dan receiver
- Event name tidak match

**Solusi:**
- Pastikan Device ID sama persis
- Channel format: `device_{deviceId}` (contoh: `device_abc123`)
- Event names: `command` (web → android), `response` (android → web)

### Issue: Error 429 (Too Many Requests)

**Penyebab:**
- Rate limit tercapai

**Solusi:**
1. Go to Project Settings > API > Rate Limiting
2. Increase limits
3. Atau implement retry logic di app

### Issue: WebSocket Connection Error

**Penyebab:**
- Network firewall blocking WebSocket
- Proxy issue

**Solusi:**
1. Test dari network lain
2. Check firewall settings
3. Try disable VPN if using

## 📊 Monitoring & Logs

### View Realtime Connections

1. Go to **Database > Realtime Inspector**
2. Lihat:
   - Active channels
   - Connected clients
   - Message flow

### Enable Logging (Development)

Di aplikasi Flutter, tambahkan logging untuk debug:

```dart
// Di main.dart, tambahkan sebelum Supabase.initialize
import 'dart:developer' as developer;

void main() async {
  // ... existing code ...
  
  // Enable logging
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    debug: true, // Enable debug logs
  );
}
```

## 🎯 Production Checklist

Sebelum deploy ke production:

- [ ] Realtime enabled di project settings
- [ ] Rate limiting configured
- [ ] Monitor bandwidth usage
- [ ] Test connection dari berbagai network
- [ ] Implement error handling di app
- [ ] Setup alerts untuk high usage
- [ ] Document channel naming convention
- [ ] Backup credentials securely

## 🔗 Useful Links

- [Supabase Realtime Docs](https://supabase.com/docs/guides/realtime)
- [Realtime Broadcast Guide](https://supabase.com/docs/guides/realtime/broadcast)
- [Realtime Quotas & Limits](https://supabase.com/docs/guides/platform/going-into-prod#realtime-quotas)
- [Flutter Supabase Docs](https://supabase.com/docs/reference/dart/introduction)

## 💡 Pro Tips

1. **Channel Names**: Gunakan format konsisten (contoh: `device_{id}`)
2. **Message Size**: Keep messages kecil (<1KB) untuk performance
3. **Connection Pooling**: Reuse channel connections jangan create baru terus
4. **Error Handling**: Always handle connection errors
5. **Reconnection**: Implement auto-reconnect logic
6. **Testing**: Test dengan multiple devices sebelum production

## 🆘 Need Help?

Jika masih ada masalah:

1. Check [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) untuk commands
2. Review [SECURITY.md](./SECURITY.md) untuk security setup
3. Lihat logs di Supabase Dashboard
4. Test dengan curl atau Postman untuk isolate issue

---

**✨ Setup selesai? Mari test aplikasi!**

```bash
# Terminal 1: Android Receiver
cd android_receiver
flutter run

# Terminal 2: Web Controller
cd web_controller
flutter run -d chrome
```

Good luck! 🚀
