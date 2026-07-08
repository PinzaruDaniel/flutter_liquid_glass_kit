import 'package:flutter/material.dart';

class SearchItem {
  const SearchItem(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

const searchItems = [
  SearchItem(
    Icons.water_drop_outlined,
    'Native surface',
    'SwiftUI glass on iOS, Flutter fallback elsewhere',
  ),
  SearchItem(
    Icons.speed,
    'Optimized Android',
    'Shared backdrop grouping keeps scrolling smooth',
  ),
  SearchItem(
    Icons.motion_photos_on,
    'Tab motion',
    'Tap Home, Search, Saved, and Profile to inspect animation',
  ),  SearchItem(
    Icons.map,
    'Tab motion',
    'Tap Home, Search, Saved, and Profile to inspect animation',
  ),  SearchItem(
    Icons.fax_rounded,
    'Tab motion',
    'Tap Home, Search, Saved, and Profile to inspect animation',
  ), SearchItem(
    Icons.backpack_outlined,
    'Tab motion',
    'Tap Home, Search, Saved, and Profile to inspect animation',
  ),
];
