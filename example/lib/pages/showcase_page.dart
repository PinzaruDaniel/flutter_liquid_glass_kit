import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass_kit/flutter_liquid_glass_kit.dart';

import '../widgets/demo_page_scaffold.dart';
import '../widgets/section_label.dart';

class ShowcasePage extends StatelessWidget {
  const ShowcasePage({
    super.key,
    required this.loading,
    required this.onToggleLoading,
  });

  final bool loading;
  final VoidCallback onToggleLoading;

  @override
  Widget build(BuildContext context) {
    return DemoPageScaffold(
      title: 'Liquid Glass Kit',
      leadingEmoji: isNativeLiquidGlassSupported ? '🍎' : '🪟',
      subtitle: isNativeLiquidGlassSupported
          ? 'Native iOS 26 rendering'
          : 'Flutter glassmorphism fallback',
      children: [
        const SectionLabel('Glass Card'),
        const SizedBox(height: 12),
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'All features unlocked',
                        style: TextStyle(
                          color: Color(0xAAFFFFFF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Enjoy unlimited access to all liquid glass UI components, '
                'native SwiftUI rendering on iOS 26, and cross-platform fallbacks.',
                style: TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        const SectionLabel('Glass Buttons'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            LiquidGlassButton(
              onPressed: () {},
              child: const Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            LiquidGlassButton(
              onPressed: loading ? null : onToggleLoading,
              isLoading: loading,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
            LiquidGlassButton(
              onPressed: null,
              child: const Text(
                'Disabled',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const SectionLabel('Tinted Glass Card'),
        const SizedBox(height: 12),
        LiquidGlassCard(
          settings: const LiquidGlassSettings(
            tintColor: Color(0xFF4F46E5),
            tintOpacity: 0.38,
            blurSigma: 24,
            borderOpacity: 0.26,
          ),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.lock_outline, color: Colors.white),
            title: Text(
              'Private Mode',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Your activity stays on device',
              style: TextStyle(color: Color(0xAAFFFFFF)),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.white38),
          ),
        ),
      ],
    );
  }
}
