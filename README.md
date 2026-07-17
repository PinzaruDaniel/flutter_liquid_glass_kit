# flutter_liquid_glass_kit

Platform-adaptive Liquid Glass components for Flutter. The package uses native
SwiftUI glass on iOS and an optimized Flutter matte-glass renderer elsewhere.

| Platform | Renderer |
|---|---|
| iOS 26+ | Native SwiftUI `.glassEffect()` |
| iOS 16-25 | Native system-material fallback |
| Android, web, desktop | Flutter blur, tint, highlight, border, and shadow |

## Installation

```bash
flutter pub add flutter_liquid_glass_kit
```

```dart
import 'package:flutter_liquid_glass_kit/flutter_liquid_glass_kit.dart';
```

## Components

### Card

```dart
const LiquidGlassCard(
  padding: EdgeInsets.all(20),
  child: Text('Hello, Glass!'),
)
```

`width` and `height` are optional fixed dimensions. When they are omitted, the
card follows its parent constraints and child size. `margin` is outside the
glass surface; `padding` is inside it.

### Button

```dart
LiquidGlassButton(
  onPressed: () {},
  isLoading: false,
  child: const Text('Continue'),
)
```

A null `onPressed` disables the button. `isLoading: true` also disables taps and
replaces the child with a progress indicator. Use `pressScaleFactor` and
`animationDuration` to customize press feedback.

### Navigation bar

`LiquidGlassNavBar` returns a `Positioned` widget and must be placed inside a
`Stack`. It is controlled: update `currentIndex` from `onTap`.

```dart
Scaffold(
  body: Stack(
    children: [
      pages[currentIndex],
      LiquidGlassNavBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          LiquidGlassNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            iosSystemImage: 'house',
            iosSelectedSystemImage: 'house.fill',
          ),
          LiquidGlassNavItem(
            icon: Icons.search,
            label: 'Search',
            androidIcon: Text('S'),
          ),
        ],
      ),
    ],
  ),
)
```

On the Flutter fallback, users can hold and drag the selection indicator. Icons
and labels preview the item under the indicator, but navigation occurs only
after release. Cancelling restores the current item.

`androidIcon` and `activeAndroidIcon` accept arbitrary widgets. They inherit
the active `IconTheme` and `DefaultTextStyle`. Native iOS uses SF Symbol names
from `iosSystemImage` and `iosSelectedSystemImage`, with automatic mappings for
common Material icons.

## Shared settings

Define a baseline once with `LiquidGlassSettingsScope`:

```dart
LiquidGlassSettingsScope(
  settings: LiquidGlassSettings.matteDark.copyWith(
    tintColor: const Color(0xFF9333EA),
    tintOpacity: 0.30,
  ),
  child: const MyAppContent(),
)
```

Or define settings while grouping non-overlapping fallback surfaces:

```dart
LiquidGlassBackdropGroup(
  settings: const LiquidGlassSettings.matteDark,
  child: ListView(children: glassCards),
)
```

Settings resolve in this order:

1. Settings passed directly to a card, button, nav bar, or `PlatformGlass`.
2. The nearest `LiquidGlassSettingsScope` or configured backdrop group.
3. `LiquidGlassSettings.matteLight`.

A component can override the shared baseline:

```dart
const LiquidGlassCard(
  settings: LiquidGlassSettings(
    tintColor: Color(0xFF16A34A),
    tintOpacity: 0.32,
  ),
  child: Text('Local green tint'),
)
```

## Settings reference

| Parameter | Default | Behavior |
|---|---:|---|
| `tintColor` | `null` | Custom surface color. Null selects an adaptive matte tint on the fallback. |
| `tintOpacity` | `0.15` | Tint strength from `0.0` to `1.0`. Saturated colors usually work well at `0.20-0.40`. |
| `blurSigma` | `20` | Requested backdrop blur. Forwarded to native iOS and capped on Android. |
| `androidBlurSigma` | `12` | Maximum Android blur. Set to `0` for a fast matte-only surface. |
| `borderOpacity` | `0.25` | Fallback border-highlight opacity. |
| `borderWidth` | `1` | Fallback border width in logical pixels. |
| `shadowOpacity` | `0.12` | Fallback drop-shadow opacity. Set to `0` on dense screens to reduce paint cost. |
| `shadowBlurRadius` | `16` | Fallback shadow blur radius. |
| `shadowOffset` | `(0, 4)` | Fallback shadow offset. |

Built-in presets:

- `LiquidGlassSettings.matteLight`: bright neutral glass.
- `LiquidGlassSettings.matteDark`: strong charcoal glass with a lower Android
  blur cap.

For a visible custom tint, provide both color and opacity:

```dart
const LiquidGlassSettings(
  tintColor: Color(0xFF9333EA),
  tintOpacity: 0.30,
)
```

## Android performance

Wrap scrollable sections containing several non-overlapping glass surfaces in
`LiquidGlassBackdropGroup`. It shares backdrop input and, by default, pauses
blur while scrolling while preserving tint, border, and content:

```dart
LiquidGlassBackdropGroup(
  disableBlurWhileScrolling: true,
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => LiquidGlassCard(
      child: ItemRow(items[index]),
    ),
  ),
)
```

Set `disableBlurWhileScrolling: false` to keep blur active during motion. Other
useful optimizations:

- Lower `androidBlurSigma` to `6-8`, or `0` for matte-only rendering.
- Reduce `shadowBlurRadius` or set `shadowOpacity` to `0` in long lists.
- Use lazy lists such as `ListView.builder`.
- Avoid continuously animated backgrounds behind large blurred surfaces.
- Use `LiquidGlassScrollBehavior` to remove Android overscroll effects that can
  alter backdrop sampling.

Do not put overlapping `PageView` pages, route transitions, or floating surfaces
in one backdrop group. Grouped filters share input and overlapping surfaces can
sample the wrong backdrop. `LiquidGlassNavBar` already disables shared backdrop
filtering for its floating fallback surface.

## Rendering mode

```dart
if (isNativeLiquidGlassSupported) {
  print('Native iOS surface');
} else {
  print('Flutter fallback surface');
}
```

This value is true on iOS even before iOS 26 because those systems still use a
native material fallback. Android, web, and desktop return false.

## Requirements

- Flutter 3.19 or newer
- Dart 3.0 or newer
- iOS 16+; iOS 26+ uses native Liquid Glass
- Android API 21+
