# Flutter Mobile App Production Build Guide

This mobile app is pre-configured to dynamically load the backend API connection URL from your compiler options. This means you do NOT need to modify the source code files when shifting between development and production environments.

---

## 🚀 How to Build for Production

When building the app, you inject the backend base URL using the `--dart-define` flag.

### 🤖 Android (APK / App Bundle)

1. **Direct Download APK** (for side-loading onto devices):
   ```bash
   flutter build apk --release --dart-define=API_BASE_URL=https://your-backend-api-url.onrender.com
   ```
   *Output path:* `build/app/outputs/flutter-apk/app-release.apk`

2. **Google Play Store App Bundle** (.aab):
   ```bash
   flutter build appbundle --release --dart-define=API_BASE_URL=https://your-backend-api-url.onrender.com
   ```
   *Output path:* `build/app/outputs/bundle/release/app-release.aab`

---

### 🍎 iOS (App Store / IPA)

*Note: Requires macOS and Xcode.*

1. **Xcode Archive / IPA compilation**:
   ```bash
   flutter build ipa --release --dart-define=API_BASE_URL=https://your-backend-api-url.onrender.com
   ```
   *Output path:* `build/ios/archive/` and `build/ios/ipa/`

---

### 🌐 Flutter Web (Alternative)

If you compile the Flutter project to run as a web page:
```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-backend-api-url.onrender.com
```
*Output path:* `build/web/` (upload the contents of this folder to Netlify, Vercel, or Firebase Hosting).

---

## 🛠️ Verification / Troubleshooting

If the mobile app is unable to connect to the backend:
1. Make sure your backend hosting provider has CORS enabled to receive requests (the backend's `Program.cs` currently has `AllowAll` CORS enabled, which will allow mobile connections).
2. Ensure you specify the `API_BASE_URL` *without* a trailing slash (e.g., `https://api.my-domain.com` instead of `https://api.my-domain.com/`).
