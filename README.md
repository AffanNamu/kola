# Kolanut (Bootstrap Edition)

Production-ready Flutter + Firebase (Free Tier) e-commerce app.
Built with **zero monthly infrastructure cost** at launch.

## Local setup (Termux)
You don't need Flutter installed locally. This repo is designed to be built by **GitHub Actions**.

## GitHub Actions secrets required
Add these in:
**GitHub Repo → Settings → Secrets and variables → Actions → New repository secret**

- `GOOGLE_SERVICES_JSON` : content of `android/app/google-services.json`
- `FIREBASE_OPTIONS_DART` : content of `lib/firebase_options.dart`
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_UPLOAD_PRESET` (unsigned)
- `PAYSTACK_PUBLIC_KEY`
- `FLUTTERWAVE_PUBLIC_KEY`

## Firebase manual steps
1. Create Firebase project
2. Enable Auth (Email/Password + Google if needed)
3. Create Firestore database
4. Paste rules from `FIRESTORE_RULES.txt`
5. Login once -> Firestore creates `/users/{uid}`
6. To make yourself admin: set `/users/{uid}.role = "admin"`

## Admin usage
- Go to `/admin` route (or open Account tab and press "Admin" button if role is admin)
- Add Categories
- Add Banners
- Add Products

## Notes
- Cart is offline-first using Drift (local database).
- Products/Categories/Banners live in Firestore.
- Images are uploaded to Cloudinary (free tier).

# kola
