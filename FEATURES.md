# GeoAttend - Dokumentasi Fitur

---

## 📋 Daftar Isi

### User Features
- [Dashboard](#dashboard)
- [Clock In/Out](#clock-inout)
- [History](#history)
- [Leave Requests](#leave-requests)

### Admin Features
- [Manage Users](#manage-users)
- [Daily Monitor](#daily-monitor)
- [Attendance Reports](#attendance-reports)
- [Leave Management](#leave-management)
- [Holidays](#holidays)
- [Settings](#settings)

### Technical
- [Location & Geofencing](#location--geofencing)
- [Camera & Photo System](#camera--photo-system)
- [Audit Log](#audit-log)
- [Security](#security)

---

# User Features

---

## Dashboard

Halaman utama untuk karyawan melihat status kehadiran.

### Komponen
| Komponen | Deskripsi |
|----------|-----------|
| Status Card | Menampilkan status hari ini (Belum Hadir / Sudah Clock In / Sudah Pulang) |
| Shift Info | Informasi shift yang ditugaskan |
| Late Indicator | Indikator keterlambatan jika clock in setelah waktu mulai shift |

---

## Clock In/Out

Fitur absensi dengan validasi lokasi dan foto.

### Alur Kerja
```
📍 Cek Lokasi → 📸 Ambil Foto → ✅ Submit → 📝 Record Tersimpan
```

### Tombol
| Tombol | Kondisi Tampil |
|--------|----------------|
| Clock In | Belum melakukan clock in hari ini |
| Clock Out | Sudah clock in, belum clock out |

### Validasi
- ✅ GPS aktif dan akurat (< 100m)
- ✅ Dalam radius geofence (untuk office employee)
- ✅ Foto selfie wajib

---

## History

Riwayat kehadiran karyawan.

### Informasi Ditampilkan
- Tanggal & waktu clock in/out
- Status (Hadir, Terlambat, Izin, dst)
- Lokasi tercatat
- Link ke foto bukti

---

## Leave Requests

Pengajuan cuti dan izin.

### Tipe Pengajuan
| Tipe | Keterangan |
|------|------------|
| Cuti Tahunan | Jatah cuti tahunan |
| Sakit | Izin sakit (bukti opsional) |
| Izin | Izin keperluan pribadi |
| Lainnya | Kategori lainnya |

### Workflow Status
```
📝 Pending → ✅ Approved / ❌ Rejected
```

### Field Input
- Tipe cuti
- Tanggal mulai - selesai
- Alasan
- Bukti pendukung (file upload, opsional)

---

# Admin Features

---

## Manage Users

Kelola data karyawan perusahaan.

### Fitur
| Fitur | Deskripsi |
|-------|-----------|
| View All | Lihat semua karyawan |
| Edit Profile | Update data karyawan |
| Assign Shift | Tetapkan shift kerja |
| Set Type | Office / Field employee |
| Toggle Geofence | Aktifkan/nonaktifkan validasi lokasi |

### Tipe Karyawan
| Tipe | Geofence | Keterangan |
|------|----------|------------|
| Office | ✅ Wajib | Validasi lokasi kantor |
| Field | ❌ Tidak | Bebas lokasi |

---

## Daily Monitor

Pantau kehadiran harian.

### Fitur
- Real-time status kehadiran hari ini
- Filter berdasarkan status
- Export data harian

---

## Attendance Reports

Laporan kehadiran lengkap.

### Filter
- Periode tanggal
- Karyawan spesifik
- Status kehadiran

### Export Excel
| Fitur | Detail |
|-------|--------|
| Watermark | Header dengan info perusahaan, exporter, tanggal |
| Audit | Tercatat di audit log |
| Format | .xlsx |

---

## Leave Management

Kelola pengajuan cuti karyawan.

### Aksi Admin
| Aksi | Keterangan |
|------|------------|
| Approve | Setujui pengajuan |
| Reject | Tolak dengan catatan |
| View Detail | Lihat alasan dan bukti |

---

## Holidays

Kelola hari libur perusahaan.

### Fitur
- Tambah hari libur
- Edit informasi
- Aktifkan/nonaktifkan

### Data
| Field | Keterangan |
|-------|------------|
| Tanggal | Tanggal libur |
| Nama | Nama hari libur |
| Deskripsi | Keterangan tambahan |

---

## Settings

Pengaturan perusahaan dan shift.

### Pengaturan Perusahaan
| Setting | Keterangan |
|---------|------------|
| Nama | Nama perusahaan |
| Lokasi Kantor | Latitude & Longitude |
| Radius | Radius geofence (meter) |
| Jam Mulai | Waktu mulai kerja default |

### Pengaturan Shift
| Field | Keterangan |
|-------|------------|
| Nama | Nama shift (Pagi, Siang, Malam) |
| Waktu Mulai | Jam mulai shift |
| Waktu Selesai | Jam selesai shift |

---

# Technical

---

## Location & Geofencing

Sistem validasi lokasi 2 layer: frontend quick-check + backend final validation.

### Arsitektur
```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Browser API   │────▶│  Frontend Check  │────▶│ Backend Validate│
│  (Geolocation)  │     │  (Quick Filter)  │     │ (Final Decision)│
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

### Konfigurasi GPS
```typescript
const options = {
  enableHighAccuracy: true,    // Gunakan GPS hardware
  timeout: 15000,              // Timeout 15 detik
  maximumAge: 60000            // Cache lokasi max 1 menit
};
```

### Validasi Akurasi
| Layer | Batas | Response |
|-------|-------|----------|
| Frontend | 100m | Error sebelum lanjut |
| Backend | 100m | 400 LOW_ACCURACY |

### Error Codes
| Kode | Pesan |
|------|-------|
| `PERMISSION_DENIED` | Akses lokasi ditolak |
| `POSITION_UNAVAILABLE` | GPS tidak tersedia |
| `TIMEOUT` | Timeout mendapatkan lokasi |
| `LOW_ACCURACY` | Akurasi GPS > 100m |
| `OUTSIDE_GEOFENCE` | Di luar radius kantor |

### Perhitungan Jarak (Haversine)
```typescript
function calculateDistance(lat1, lng1, lat2, lng2): number {
  const R = 6371000; // Radius bumi (meter)
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  
  const a = Math.sin(dLat/2) ** 2 +
            Math.cos(lat1 * Math.PI/180) * Math.cos(lat2 * Math.PI/180) *
            Math.sin(dLng/2) ** 2;
  
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}
```

### Validasi Geofence (Backend)
```typescript
// Ambil lokasi kantor
const { data: company } = await supabase
  .from('companies')
  .select('office_latitude, office_longitude, radius_meters')
  .single();

// Hitung jarak
const distance = calculateDistance(lat, lng, company.office_latitude, company.office_longitude);

// Validasi
if (distance > company.radius_meters) {
  return { error: 'OUTSIDE_GEOFENCE', distance };
}
```

### Komponen UI

#### LocationStatus
| State | Display |
|-------|---------|
| Loading | "Detecting your location..." |
| Error | Pesan error + tombol retry |
| Inside | ✅ "You are at the location" |
| Outside | ⚠️ "Outside allowed area" + jarak |

#### LocationMap
- Leaflet map dengan OpenStreetMap tiles
- Marker posisi user
- Circle akurasi GPS
- Zoom level 16

---

## Camera & Photo System

Sistem capture foto dengan watermark embedded.

### Arsitektur
```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
│   Camera    │────▶│   Capture    │────▶│  Watermark  │────▶│   Upload     │
│   Stream    │     │   to Canvas  │     │   Overlay   │     │   Storage    │
└─────────────┘     └──────────────┘     └─────────────┘     └──────────────┘
```

### Konfigurasi Kamera
```typescript
const stream = await navigator.mediaDevices.getUserMedia({
  video: {
    facingMode: 'user',      // Kamera depan (selfie)
    width: { ideal: 1280 },
    height: { ideal: 720 }
  },
  audio: false
});
```

### Proses Capture
1. Gambar frame video ke canvas
2. Tambahkan watermark overlay
3. Convert ke JPEG (quality 0.8)
4. Upload ke storage

### Watermark Content
| Baris | Content | Contoh |
|-------|---------|--------|
| 1 | 👤 Nama | 👤 John Doe |
| 2 | 📋 Tipe | 📋 Clock In |
| 3 | 🕐 Waktu | 🕐 Sabtu, 28 Des 2024, 08:00:00 |
| 4 | 📍 GPS | 📍 -6.200000, 106.816666 |

### Watermark Code
```typescript
const addWatermark = (ctx, width, height) => {
  // Background hitam semi-transparan
  ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
  ctx.fillRect(0, height - 100, width, 100);
  
  // Text putih
  ctx.fillStyle = 'white';
  ctx.font = 'bold 16px Arial';
  ctx.fillText(`👤 ${employeeName}`, 10, height - 75);
  ctx.fillText(`📋 ${recordType}`, 10, height - 55);
  ctx.fillText(`🕐 ${timestamp}`, 10, height - 35);
  ctx.fillText(`📍 ${lat}, ${lng}`, 10, height - 15);
};
```

### Upload ke Storage
```typescript
const blob = await (await fetch(photoDataUrl)).blob();
const fileName = `${userId}/${Date.now()}_${recordType}.jpg`;

const { data } = await supabase.storage
  .from('attendance-photos')
  .upload(fileName, blob, { contentType: 'image/jpeg' });
```

### Storage Bucket
| Property | Value |
|----------|-------|
| Nama | `attendance-photos` |
| Public | ✅ Yes |
| Format | JPEG |
| Max Size | ~500KB |
| Path | `{user_id}/{timestamp}_{type}.jpg` |

---

## Audit Log

Sistem pencatatan aktivitas untuk keamanan dan compliance.

### Events
| Action | Resource | Trigger |
|--------|----------|---------|
| `clock_in` | attendance | Clock in berhasil |
| `clock_out` | attendance | Clock out berhasil |
| `approve_leave` | leave_request | Admin approve |
| `reject_leave` | leave_request | Admin reject |
| `export_data` | attendance_report | Export Excel |
| `suspicious_location` | attendance | Lokasi mencurigakan |

### Data Structure
```typescript
{
  user_id: string,
  user_email: string,
  user_role: string,
  company_id: string,
  action: string,
  resource_type: string,
  resource_id: string,
  details: JSON,
  ip_address: string,
  user_agent: string,
  created_at: timestamp
}
```

### Akses
| Role | Akses |
|------|-------|
| Admin | Log perusahaan sendiri |
| Developer | Semua log |

---

## Security

### Row Level Security (RLS)
| Role | Akses Data |
|------|------------|
| Employee | Data sendiri |
| Admin | Data perusahaan |
| Developer | Semua data |

### Validasi Backend
| Check | Response |
|-------|----------|
| Auth Token | 401 Unauthorized |
| GPS Accuracy | 400 LOW_ACCURACY |
| Geofence | 400 OUTSIDE_GEOFENCE |
| Duplicate | 400 DUPLICATE_RECORD |
| Active Profile | 403 Forbidden |

### Proteksi Foto
- ✅ Watermark embedded (tidak bisa dihapus)
- ✅ Timestamp dari server
- ✅ GPS tersimpan di database

---

## Diagram Alur Clock In

```
┌──────────────────────────────────────────────────────────────┐
│                    USER KLIK CLOCK IN                         │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                      AMBIL LOKASI GPS                         │
│  enableHighAccuracy: true | timeout: 15s                      │
└──────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
        ┌──────────┐                   ┌──────────────┐
        │  Sukses  │                   │    Gagal     │
        └──────────┘                   └──────────────┘
              │                               │
              ▼                               ▼
┌──────────────────────┐              ┌──────────────────┐
│  CEK AKURASI < 100m  │              │  TAMPILKAN ERROR │
└──────────────────────┘              └──────────────────┘
              │
      ┌───────┴───────┐
      ▼               ▼
┌──────────┐    ┌──────────────┐
│    Ya    │    │    Tidak     │
└──────────┘    └──────────────┘
      │                │
      ▼                ▼
┌──────────────┐  ┌──────────────────────┐
│ CEK GEOFENCE │  │ ERROR: Low Accuracy  │
└──────────────┘  └──────────────────────┘
      │
      ├── ✅ Dalam radius ──▶ BUKA KAMERA
      │
      └── ⚠️ Luar radius ───▶ WARNING (field employee bisa lanjut)
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────┐
│                       BUKA KAMERA                             │
│  facingMode: 'user' (kamera depan)                            │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                    USER AMBIL FOTO                            │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│               TAMBAH WATERMARK KE FOTO                        │
│  👤 Nama | 📋 Tipe | 🕐 Waktu | 📍 GPS                        │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                   UPLOAD FOTO KE STORAGE                      │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                 KIRIM KE BACKEND (Edge Function)              │
│  Validasi: Auth → Accuracy → Geofence → Duplicate             │
└──────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
        ┌──────────┐                   ┌──────────────┐
        │  Sukses  │                   │    Error     │
        └──────────┘                   └──────────────┘
              │                               │
              ▼                               ▼
┌──────────────────────┐              ┌──────────────────┐
│  ✅ Record Tersimpan │              │  Tampilkan Error │
│  + Audit Log Created │              │  + Kode Error    │
└──────────────────────┘              └──────────────────┘
```

---

## Role & Permission Matrix

| Fitur | Employee | Admin | Developer |
|-------|----------|-------|-----------|
| Dashboard | ✅ | ✅ | ✅ |
| Clock In/Out | ✅ | ✅ | ✅ |
| History (sendiri) | ✅ | ✅ | ✅ |
| Leave Request | ✅ | ✅ | ✅ |
| Manage Users | ❌ | ✅ | ✅ |
| Daily Monitor | ❌ | ✅ | ✅ |
| Attendance Reports | ❌ | ✅ | ✅ |
| Leave Management | ❌ | ✅ | ✅ |
| Holidays | ❌ | ✅ | ✅ |
| Settings | ❌ | ✅ | ✅ |
| Audit Logs | ❌ | ✅ (company) | ✅ (all) |
