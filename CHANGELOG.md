## 1.0.6

- Expand README guidance and document all public constructors and parameters.

## 1.0.5

- Preserve custom Android tint colors through the glass highlight gradient instead of washing them out with white.
- Make `LiquidGlassSettings.matteDark` render a clearly dark matte surface and inherit correctly through performance-only backdrop groups.
- Add shared baseline settings through `LiquidGlassBackdropGroup`, with per-component overrides.
- Improve Android scrolling performance by pausing grouped backdrop blur during motion, retaining stable backdrop keys, and isolating nav drag repaints.

## 1.0.4

- Improve the Android navigation indicator with finger-following drag selection, active item previews, press expansion, and an iOS-style vertical stretch during tab jumps.
- Add Android widget icons for `LiquidGlassNavItem`.
- Scope example backdrop groups per page to keep Android glass colors stable during horizontal navigation.

## 1.0.3

- Add `LiquidGlassScrollBehavior` to keep Android glass colors stable during overscroll.

## 1.0.2

- Added pages for example app.
- Improve animation for android navigation bar.
- Improve native iOS usage.

## 1.0.1

- Prepare the package for a `1.0.1` patch release.
- Format the example search item list.

## 1.0.0

- Initial release as `flutter_liquid_glass_kit`.
- Add Swift Package Manager support for iOS plugin consumers.
- Render Liquid Glass natively on iOS with SwiftUI glass surfaces.
- Add native iOS floating tab bar support.
- Add optimized Flutter matte-glass fallback for Android and other platforms.
- Add reusable glass card, button, and navigation bar widgets.
- Add runnable example app.
