import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass_kit/flutter_liquid_glass_kit.dart';

import '../models/search_item.dart';
import '../widgets/demo_page_scaffold.dart';
import '../widgets/section_label.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPageScaffold(
      title: 'Explore Glass',
      leadingEmoji: '🔎',
      subtitle: 'Tap or swipe to test navigation motion',
      children: [
        const SectionLabel('Animated Results'),
        const SizedBox(height: 12),
        for (final item in searchItems) ...[
          LiquidGlassCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(item.icon, color: Colors.white),
              title: Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item.subtitle,
                style: const TextStyle(color: Color(0xAAFFFFFF)),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.white38),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
