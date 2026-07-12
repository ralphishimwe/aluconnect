# ALUConnect

A Flutter mobile app that connects ALU students looking for internship experience with student-led startups and early-stage ventures inside the ALU ecosystem. Startups post opportunities, students discover and apply to them, and everything updates live thanks to Cloud Firestore.

## Tech Stack

- **Flutter** (Dart) - single codebase for Android/iOS
- **Firebase Authentication** - email/password accounts
- **Cloud Firestore** - real-time database (no custom backend server)
- **Provider** - state management (ChangeNotifier for session/auth state, StreamBuilder for live data)

## Key Features

- Student and Startup sign-up/login, with role-based home screens
- Startup verification gate - only ALU-recognized startups (verified by an admin) can post opportunities
- Opportunity posting, editing, and deletion (startup side)
- Live opportunity discovery, category filtering, and search (student side)
- One-tap apply with real-time status tracking (under review / accepted / rejected)
- Applicant review with reversible accept/reject decisions (startup side)
- Editable profiles for both roles
- Every list and status updates live via Firestore listeners - no manual refresh needed anywhere

## Getting Started

1. Install dependencies:
   ```
   flutter pub get
   ```
2. Connect your own Firebase project:
   ```
   flutterfire configure
   ```
3. Publish `firestore.rules` to your Firebase project (Firestore Database → Rules → Publish) - this file does **not** auto-deploy from the repo.
4. Run the app on an emulator or physical device:
   ```
   flutter run
   ```

## Project Structure

```
lib/
  models/       Data classes (one per Firestore collection)
  providers/    AuthProvider - app-wide session/auth state
  services/     All Firestore/Auth reads and writes live here
  screens/      Auth, Home (student/startup tabs), Opportunities, Applicants, Profile
  widgets/      Shared, reusable UI components
  utils/        Colors, categories, validators, and small helpers
```

## Documentation

See the full technical report (PDF) in this folder for the system architecture, data model, state management approach, and design reasoning.
