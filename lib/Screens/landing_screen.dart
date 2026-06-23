import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'web_view_page.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushNamed('/login');
  }

  void _goToSignup(BuildContext context) {
    Navigator.of(context).pushNamed('/signup');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  Color(0xFFFFF9F5),
                  Color(0xFFFDF0E6),
                  Color(0xFFFBE2D3),
                ],
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: -20,
            child: _GlowCircle(diameter: 220, color: const Color(0x1AE07A5F)),
          ),
          Positioned(
            left: -50,
            bottom: 120,
            child: _GlowCircle(diameter: 180, color: const Color(0x1A81B29A)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favorite Places',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFF2B2118),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Capture memories, add custom notes, and map the moments that matter to you.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF5A4D41),
                      height: 1.4,
                    ),
                  ).animate().fade(delay: 150.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Center(
                      child: _HeroCard(size: size)
                          .animate()
                          .fade(delay: 300.ms, duration: 600.ms)
                          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack)
                          .slideY(begin: 0.1, end: 0),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _goToLogin(context),
                          icon: const Icon(Icons.login_outlined, size: 20),
                          label: const Text('Sign In to Account'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _goToSignup(context),
                          icon: const Icon(Icons.person_add_outlined, size: 20),
                          label: const Text('Create New Account'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const WebViewPage(
                                      url: 'https://example.com',
                                      title: 'Website',
                                    )));
                          },
                          icon: const Icon(Icons.public_outlined, size: 18),
                          label: const Text('Open Companion Website'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6C5D50),
                            textStyle: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 450.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Your memory vault is kept secure and localized.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8E8071),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fade(delay: 600.ms, duration: 400.ms),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B2118).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFE07A5F), Color(0xFF81B29A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE07A5F).withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.landscape_outlined,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8DD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.place_outlined, color: Color(0xFFE07A5F), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Log your favorite spots with visual memories.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B2118),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.note_alt_outlined, color: Color(0xFF81B29A), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Write journals for each memory to tell its story.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5A4D41),
                  ),
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
