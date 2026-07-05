# ALUConnect - Authentication Setup Guide

This guide walks through everything needed to get the Authentication step
running: connecting the Flutter app to your existing Firebase project,
enabling the services we use, and running the app for the first time.

Run all terminal commands below from inside the `aluconnect` project folder
on your own machine (not in this chat).

## 1. Enable the Firebase services we need

You said you already created the Firebase project, so just turn on two
services inside it:

1. Go to https://console.firebase.google.com and open your project.
2. In the left sidebar, click **Build > Authentication > Get started**.
   - Click the **Sign-in method** tab.
   - Enable **Email/Password** (the first provider in the list) and Save.
3. In the left sidebar, click **Build > Firestore Database > Create database**.
   - Choose a location close to you (any is fine for a class project).
   - Start in **test mode** for now (we will apply proper rules in step 4).

## 2. Install the FlutterFire CLI (one-time only)

This CLI tool generates the `firebase_options.dart` file our `main.dart`
imports - it contains your Firebase project's keys for each platform.

```bash
dart pub global activate flutterfire_cli
```

If you haven't already installed the regular Firebase CLI, do that too:

```bash
npm install -g firebase-tools
firebase login
```

## 3. Connect this Flutter project to your Firebase project

From inside the `aluconnect` folder:

```bash
flutterfire configure
```

- Pick your existing Firebase project from the list.
- Select the platforms you plan to test on (at minimum: Android, and/or iOS).
- When it finishes, it creates `lib/firebase_options.dart` automatically -
  don't edit that file by hand, and don't worry that it wasn't in the code
  I wrote for you; the CLI generates it.

## 4. Apply Firestore security rules

Open `firestore.rules` in this project (already created for you) and paste
its contents into: Firebase console -> Firestore Database -> **Rules** tab
-> Publish.

These rules mean: you can only write your own profile document, but any
logged-in user can read profiles (needed later so students can browse
startups and startups can review applicants).

## 5. Install the new Flutter packages

```bash
flutter pub get
```

This downloads `firebase_core`, `firebase_auth`, `cloud_firestore`, and
`provider`, which were added to `pubspec.yaml`.

## 6. Run the app

```bash
flutter run
```

Make sure an emulator or physical device is running/connected first
(required by the assignment - the app must run on a device/emulator, not
just a browser).

## 7. Test the full authentication flow

1. Tap **Register** -> choose **Student** -> fill in the form -> **Create
   account**. You should land on the Student Home placeholder screen.
2. Tap the logout icon (top-right) to go back to Login.
3. Log back in with the same email/password - you should return to the
   same Student Home screen.
4. Repeat with a new account choosing **Startup / Organization** this time.

## 8. Verify it in the Firebase console (important for the rubric!)

While testing, keep the Firebase console open in a browser tab so you can
show, in real time:

- **Authentication > Users tab**: a new row appears the instant you
  register a new account.
- **Firestore Database > Data tab**: a new document appears under
  `users`, and another under `students` or `startups`, right after you
  register. Open a document to show the fields (fullName, program, etc.
  for students; name, industry, isVerified for startups).

This live "app action -> console update" demonstration is exactly what the
Firebase Authentication and CRUD rubric items are looking for.

## Troubleshooting

- **"firebase_options.dart not found"**: you skipped step 3, or it's in
  the wrong location. Re-run `flutterfire configure` from the project root.
- **Stuck on the loading spinner**: usually means `Firebase.initializeApp()`
  failed silently - double check step 3 ran without errors, and that you
  have internet access on the emulator/device.
- **"PERMISSION_DENIED" errors in Firestore**: check step 4 - the rules
  must be published, and you must be logged in (rules require
  `request.auth != null`).
