# Diary App (Backlog Tracker)

Film, dizi, oyun, muzik ve kitap takip uygulamasi. TMDB, RAWG.io, Trakt.tv, Spotify ve Open Library API'leri ile arama yapip kisisel backlog'unuza ekleyebilirsiniz.

## Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js](https://nodejs.org/) (v18+)
- [MongoDB Atlas](https://www.mongodb.com/atlas) hesabi (ucretsiz tier yeterli)

## Kurulum

### 1. Repoyu klonlayin

```bash
git clone https://github.com/zmzmstz/DiaryApp.git
cd DiaryApp
```

### 2. Environment degiskenlerini ayarlayin

`.env.example` dosyasini `.env` olarak kopyalayin ve degerleri doldurun:

```bash
cp .env.example .env
```

**Not:** `.env` dosyasini proje sahibinden temin edebilirsiniz.

### 3. Backend sunucusunu baslatin

```bash
cd server
npm install
npm start
```

Basarili olursa `Connected to MongoDB` ve `API server running on http://0.0.0.0:5038` mesajlarini goreceksiniz.

### 4. Flutter uygulamasini baslatin

Yeni bir terminal acin:

```bash
cd ..
flutter pub get
flutter run
```

## Proje Yapisi

```
├── lib/                    # Flutter uygulama kodu
│   ├── data/               # Repository ve servisler
│   ├── logic/              # Bloc state management
│   ├── models/             # Veri modelleri
│   └── presentation/       # UI sayfalari ve widgetlar
├── server/                 # Express.js backend API
│   ├── index.js            # Bootstrap (server start + shutdown)
│   ├── package.json        # Node.js bagimliliklari
│   └── src/
│       ├── config/         # Env + Mongo baglanti ayarlari
│       ├── middlewares/    # Auth + error handling
│       ├── modules/        # auth, backlog, search modulleri
│       └── routes/         # Merkez route kayitlari
├── .env.example            # Ornek environment degiskenleri
└── pubspec.yaml            # Flutter bagimliliklari
```

## API Endpointleri

| Method | Endpoint | Aciklama |
|--------|----------|----------|
| GET | /api/health | Sunucu durum kontrolu |
| POST | /api/auth/register | Yeni hesap olustur, `user + accessToken` doner |
| POST | /api/auth/login | Giris yap, `user + accessToken` doner |
| GET | /api/backlog | (Bearer token) Kullanicinin backlog listesi |
| POST | /api/backlog | (Bearer token) Backlog'a ekle |
| PUT | /api/backlog/:id | (Bearer token) Backlog item guncelle |
| DELETE | /api/backlog/:id | (Bearer token) Backlog'dan sil |
| GET | /api/search?q=... | (Bearer token) TMDB + RAWG + Trakt + Spotify + Open Library birlesik arama |

## Environment Notlari

- Backend icin gereken degiskenler:
	- `DB_URI`
	- `DB_NAME`
	- `JWT_SECRET` (verilmezse sadece local development fallback kullanilir)
	- `TMDB_API_KEY`
	- `RAWG_API_KEY`
	- `TRAKT_CLIENT_ID`
	- `SPOTIFY_CLIENT_ID`
	- `SPOTIFY_CLIENT_SECRET`
- Flutter istemcisi backend adresini `API_BASE_URL` ile okur.
	- Ornek: `API_BASE_URL=http://192.168.1.105:5038`
