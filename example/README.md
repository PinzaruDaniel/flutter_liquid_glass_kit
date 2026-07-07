# Liquid Glass Kit example

A runnable showcase for all package widgets. It displays native Liquid Glass
on iOS (with a system-material fallback on pre-iOS-26 devices) and the Flutter
matte-glass fallback on Android. The card examples also show how a supplied
`tintColor` becomes coloured glass on Android.

## Run it

From this directory:

```sh
flutter pub get
flutter run
```

Use `flutter devices` to choose an iOS simulator or Android emulator, then run
`flutter run -d <device-id>` if more than one device is connected.
