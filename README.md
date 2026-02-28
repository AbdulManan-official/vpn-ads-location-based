# 🌍 Location Based Ads System

> **AdMob + Yandex** — A Flutter app that dynamically switches ad networks based on the user's country using IP geolocation.

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10.8-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![AdMob](https://img.shields.io/badge/AdMob-7.0.0-EA4335?style=for-the-badge&logo=google&logoColor=white)
![Yandex Ads](https://img.shields.io/badge/Yandex_Ads-7.18.0-FFCC00?style=for-the-badge&logo=yandex&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

</div>

---

## 🧭 How It Decides

```
User Opens App
      │
      ▼
Detect Country via IP
      │
      ├─── 🇷🇺 Russia ──────► Yandex Ads
      │
      └─── 🌎 Everywhere else ► Google AdMob
```

---

## ✨ Features

| Feature | Description |
|---|---|
| 🌍 **IP Geolocation** | Detects user country in real-time |
| 🇷🇺 **Yandex Ads** | Automatically served to Russian users |
| 🌎 **Google AdMob** | Default for all other countries |
| 📡 **Live IP Data** | Displays country, ISP, timezone, currency, etc. |
| ✨ **Shimmer Loader** | Modern loading animation while fetching IP |
| 📊 **Banner + Interstitial** | Supports both ad formats |
| 🔄 **Auto Fallback** | Falls back to AdMob if geolocation fails |

---

## 🛠️ Tech Stack

```yaml
SDK:        Flutter ^3.10.8
Ads:        google_mobile_ads: ^7.0.0
            yandex_mobileads: ^7.18.0
Network:    http: ^1.6.0
UI:         shimmer: ^3.0.0
Geolocation: IPGeolocation API
```

---

## ⚙️ How It Works

1. **App initializes** both Yandex and AdMob SDKs simultaneously.
2. **Calls IPGeolocation API** to fetch the user's location:
   ```
   GET https://api.ipgeolocation.io/ipgeo?apiKey=YOUR_API_KEY
   ```
3. **Parses the response** to extract country code, name, ISP, IP, timezone, and currency.
4. **Applies the routing logic:**
   ```dart
   if (countryCode == 'RU') {
     // Load Yandex Banner + Interstitial
   } else {
     // Load AdMob Banner + Interstitial
   }
   ```

---

## 📦 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/AbdulManan-official/vpn-ads-location-based.git
cd vpn-ads-location-based
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

---

## 🔐 API Key Security

The geolocation API key is currently defined as:

```dart
const kGeoApiKey = 'YOUR_API_KEY';
```

> ⚠️ **Before going to production, never hardcode API keys.** Use one of these approaches instead:

| Method | Command / Notes |
|---|---|
| `--dart-define` | `flutter run --dart-define=GEO_API_KEY=your_key` |
| Backend Proxy | Route requests through your own server |
| Remote Config | Firebase Remote Config or similar |
| `.env` file | Use `flutter_dotenv` package |

---

## 📱 Ad Unit IDs

> ⚠️ Demo/test ad unit IDs are used by default. Replace them with your real production IDs before publishing.

```dart
// AdMob
const kAdMobBannerId    = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
const kAdMobInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

// Yandex
const kYandexBannerId      = 'YOUR_YANDEX_BANNER_ID';
const kYandexInterstitialId = 'YOUR_YANDEX_INTERSTITIAL_ID';
```

---

## 🧠 Architecture Overview

```
main()
  ├── MobileAds.instance.initialize()   ← AdMob SDK
  └── YandexAds.initialize()            ← Yandex SDK

_init()
  └── fetchIPGeolocation()
        └── _isRussia = (countryCode == 'RU')
              ├── true  → loadYandexBanner() + loadYandexInterstitial()
              └── false → loadAdMobBanner() + loadAdMobInterstitial()

UI
  ├── ShimmerLoader  (while fetching)
  ├── AnimatedTransition (on load complete)
  └── BottomSheet → Full IP Details
```

---

## 📊 Displayed IP Data

The app surfaces the following data from the geolocation API:

- 🌍 Country & Country Code
- 🏙️ City & Region
- 🌐 IP Address
- 📡 ISP & Organization
- 🕐 Timezone
- 💰 Currency
- 📍 Coordinates (lat/lng)
- 📞 Calling Code

---

## 📈 Monetization Strategy

This geo-aware ad system delivers:

- **Higher fill rates** — Each network excels in its own region
- **Better regional eCPM** — Yandex dominates Russian inventory; AdMob leads globally
- **Smart ad switching** — Zero manual configuration needed per user
- **Improved VPN app monetization** — Especially effective when users connect through various regions

---

## 🗂️ Project Structure

```
lib/
├── main.dart              # Entry point, SDK init
├── services/
│   └── geo_service.dart   # IP geolocation logic
├── ads/
│   ├── admob_ads.dart     # AdMob banner + interstitial
│   └── yandex_ads.dart    # Yandex banner + interstitial
└── ui/
    ├── home_screen.dart   # Main UI with shimmer
    └── ip_details_sheet.dart  # Bottom sheet with IP data
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">
  Made with ❤️ by <a href="https://github.com/AbdulManan-official">Abdul Manan</a>
</div>
