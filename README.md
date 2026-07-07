# flutter_liquid_glass_kit

iOS 26 Liquid Glass UI kit for Flutter.

- **iOS** → native SwiftUI glass surface. iOS 26+ uses `.glassEffect()`; older
  iOS versions use the system material fallback inside that native surface.
- **Android** → pure-Flutter matte glass by default, or coloured glass when
  `LiquidGlassSettings.tintColor` is supplied.

## Widgets

| Widget | Description |
|---|---|
| `LiquidGlassCard` | Glass container / card |
| `LiquidGlassButton` | Pressable glass button with scale feedback |
| `LiquidGlassNavBar` | Floating glass bottom navigation bar |

## Quick start

```dart
import 'package:flutter_liquid_glass_kit/flutter_liquid_glass_kit.dart';

// Card
LiquidGlassCard(
  child: Text('Hello, Glass!', style: TextStyle(color: Colors.white)),
)

// Button
LiquidGlassButton(
  onPressed: () {},
  child: Text('Tap me', style: TextStyle(color: Colors.white)),
)

// Nav bar (inside a Stack)
LiquidGlassNavBar(
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
  items: [
    LiquidGlassNavItem(icon: Icons.home, label: 'Home'),
    LiquidGlassNavItem(icon: Icons.search, label: 'Search'),
    LiquidGlassNavItem(icon: Icons.person, label: 'Profile'),
  ],
)
```

## Customisation

All widgets accept a `LiquidGlassSettings` object:

```dart
LiquidGlassCard(
  settings: LiquidGlassSettings(
    tintColor: Colors.blue,
    tintOpacity: 0.20,
    blurSigma: 28,
    borderOpacity: 0.30,
  ),
  child: ...,
)
```

Two built-in presets: `LiquidGlassSettings.matteLight` and `LiquidGlassSettings.matteDark`.

On Android, omit `tintColor` for adaptive matte glass:

```dart
LiquidGlassCard(
  settings: const LiquidGlassSettings(),
  child: ...,
)
```

## Check rendering mode at runtime

```dart
if (isNativeLiquidGlassSupported) {
  print('Running the native iOS glass surface');
} else {
  print('Running Android Flutter glass');
}
```

## Requirements

- Flutter ≥ 3.19
- Dart ≥ 3.0
- iOS 16+ (native material; iOS 26+ uses Liquid Glass)
- Android API 21+
