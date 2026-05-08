import 'package:flutter/material.dart';

import 'HomeScreen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFCECC5),
                  Color(0xFFF7B267),
                  Color(0xFFE07A5F),
                ],
              ),
            ),
          ),
          Positioned(
            right: -60,
            top: -40,
            child: _GlowCircle(diameter: 180, color: Color(0x33FFFFFF)),
          ),
          Positioned(
            left: -40,
            bottom: 80,
            child: _GlowCircle(diameter: 140, color: Color(0x22FFFFFF)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favorite Places',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFF2B2118),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Capture memories, add a note, and keep a beautiful map of moments.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF3D2F22),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.92, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: _HeroCard(size: size),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _goToHome(context),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('Start Exploring'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Keep your places close, even when you travel far.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4A3A2C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.86,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF84A98C), Color(0xFF52796F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.photo_camera_outlined, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.place_outlined, color: Color(0xFFE07A5F)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Save the places that matter and revisit them anytime.',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.note_alt_outlined, color: Color(0xFFE07A5F)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Add a short note so every photo tells a story.',
                  style: TextStyle(fontSize: 15.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
