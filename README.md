🌍  Location Based Ads System (AdMob + Yandex)

A Flutter application that dynamically switches between Yandex Ads and Google AdMob based on the user’s country using IP geolocation.

If the user is from Russia 🇷🇺 → Yandex Ads
For all other countries 🌎 → Google AdMob

🚀 Features

🌍 IP-based country detection

🇷🇺 Automatic Yandex Ads for Russian users

🌎 Automatic AdMob Ads for global users

📡 Real-time IP geolocation data display

✨ Modern UI with shimmer loading animation

📊 Banner + Interstitial ads support

🔄 Automatic fallback to AdMob if geolocation fails

🛠 Tech Stack

Flutter (SDK ^3.10.8)

google_mobile_ads: ^7.0.0

yandex_mobileads: ^7.18.0

http: ^1.6.0

shimmer: ^3.0.0

IP geolocation powered by IPGeolocation API

Ad services:

Google AdMob

Yandex Advertising Network

⚙️ How It Works

App initializes both ad SDKs.

Calls IPGeolocation API:

https://api.ipgeolocation.io/ipgeo?apiKey=YOUR_API_KEY

Retrieves:

Country Code

Country Name

ISP

IP

Timezone

Currency

Logic:

if (country == 'RU') {
    Use Yandex Ads;
} else {
    Use AdMob;
}
📦 Installation
1️⃣ Clone Repository
git clone https://github.com/AbdulManan-official/vpn-ads-location-based.git
cd vpn-ads-location-based
2️⃣ Install Dependencies
flutter pub get
3️⃣ Run Project
flutter run
🔐 Important (API Key Security)

Currently the API key is defined in:

const kGeoApiKey = 'YOUR_API_KEY';

⚠️ For production apps:

Do NOT hardcode API keys

Use --dart-define

Or use secure backend proxy

Or remote config

📱 Ad Unit IDs

Demo AdMob IDs are used for testing.

Demo Yandex IDs are used for testing.

Replace them with your real production ad unit IDs before publishing.

🧠 Architecture Overview

main() initializes:

Yandex SDK

Google Mobile Ads SDK

_init() fetches user location

_isRussia boolean controls:

Banner type

Interstitial type

Shimmer loader while fetching IP

Animated UI transitions

Bottom sheet shows full IP details

📊 Displayed User Data

Country

City

Region

IP Address

ISP

Organization

Timezone

Currency

Coordinates

Calling Code

📈 Monetization Strategy

This system allows:

Higher fill rate

Better regional eCPM

Geo-based ad optimization

Smart ad switching

Improved monetization for VPN apps
