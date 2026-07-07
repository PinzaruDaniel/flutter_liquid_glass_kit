package com.danielpinzaru.flutter_liquid_glass_kit

import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Android stub for flutter_liquid_glass_kit.
 *
 * All glass rendering on Android is handled by the pure-Flutter
 * BackdropFilter fallback in FallbackGlass.dart — no native code needed.
 */
class LiquidGlassKitPlugin : FlutterPlugin {
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // No-op: Android uses the Flutter-side FallbackGlass renderer
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // No-op
  }
}
