import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass_kit/flutter_liquid_glass_kit.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liquid Glass Kit Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GlassShowcase(),
    );
  }
}

class GlassShowcase extends StatefulWidget {
  const GlassShowcase({super.key});

  @override
  State<GlassShowcase> createState() => _GlassShowcaseState();
}

class _GlassShowcaseState extends State<GlassShowcase> {
  int _navIndex = 0;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackdropGroup(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Gradient background ───────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // ── Decorative blobs ──────────────────────────────────────────
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.25),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple.withValues(alpha: 0.20),
                ),
              ),
            ),

            // ── Page content ──────────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Liquid Glass Kit',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isNativeLiquidGlassSupported
                          ? '🍎 Native iOS 26 rendering'
                          : '🪟 Flutter glassmorphism fallback',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Card ─────────────────────────────────────────────
                    const _SectionLabel('Glass Card'),
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
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                ),
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

                    // ── Buttons ──────────────────────────────────────────
                    const _SectionLabel('Glass Buttons'),
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
                          onPressed: _loading
                              ? null
                              : () async {
                                  setState(() => _loading = true);
                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                  );
                                  setState(() => _loading = false);
                                },
                          isLoading: _loading,
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        LiquidGlassButton(
                          onPressed: null, // disabled state
                          child: const Text(
                            'Disabled',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // ── Tinted card ───────────────────────────────────────
                    const _SectionLabel('Tinted Glass Card'),
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
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Floating glass nav bar ───────────────────────────────────
            LiquidGlassNavBar(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
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
                  badge: 3,
                  iosSystemImage: 'magnifyingglass',
                ),
                LiquidGlassNavItem(
                  icon: Icons.favorite_outline,
                  activeIcon: Icons.favorite,
                  label: 'Saved',
                  iosSystemImage: 'heart',
                  iosSelectedSystemImage: 'heart.fill',
                ),
                LiquidGlassNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  iosSystemImage: 'person',
                  iosSelectedSystemImage: 'person.fill',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xAAFFFFFF),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}
