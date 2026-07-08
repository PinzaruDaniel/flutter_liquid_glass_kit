import 'package:flutter/material.dart';

class DemoBackground extends StatelessWidget {
  const DemoBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -60,
          left: -60,
          child: _Blob(size: 300, color: Colors.blue.withValues(alpha: 0.25)),
        ),
        Positioned(
          bottom: 100,
          right: -80,
          child: _Blob(size: 260, color: Colors.purple.withValues(alpha: 0.20)),
        ),
        Positioned(
          top: 360,
          right: 30,
          child: _Blob(size: 120, color: Colors.cyan.withValues(alpha: 0.12)),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
