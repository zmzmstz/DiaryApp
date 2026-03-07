# Diary App (Backlog Tracker)

Film, dizi ve oyun takip uygulamasi. TMDB, RAWG.io ve Trakt.tv API'leri ile arama yapip kisisel backlog'unuza ekleyebilirsiniz.

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
node index.js
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
│   ├── index.js            # API endpointleri
│   └── package.json        # Node.js bagimliliklari
├── .env.example            # Ornek environment degiskenleri
└── pubspec.yaml            # Flutter bagimliliklari
```

## API Endpointleri

| Method | Endpoint | Aciklama |
|--------|----------|----------|
| POST | /api/auth/register | Yeni hesap olustur |
| POST | /api/auth/login | Giris yap |
| GET | /api/backlog/:username | Kullanicinin backlog listesi |
| POST | /api/backlog | Backlog'a ekle |
| PUT | /api/backlog/:id | Backlog item guncelle |
| DELETE | /api/backlog/:id | Backlog'dan sil |
