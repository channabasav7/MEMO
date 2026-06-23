import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:favoriteplaces/data/fav_placedata.dart';

class FavDetailScreen extends StatelessWidget {
  const FavDetailScreen({super.key, required this.favPlace});

  final FavPlace favPlace;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF2B2118)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFFBF9F6),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'image-${favPlace.id}',
                  child: Container(
                    height: size.height * 0.42,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F2EC),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2B2118).withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                      child: favPlace.imageBytes != null
                          ? Image.memory(
                              favPlace.imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Icon(Icons.image_not_supported, size: 72, color: Color(0xFF8E8071)),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (favPlace.createdAt != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE8DD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _formatDate(favPlace.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFFE07A5F),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F3ED),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFF81B29A), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Favorite',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF81B29A),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fade(duration: 350.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 16),
                      Text(
                        favPlace.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF2B2118),
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                        ),
                      ).animate().fade(delay: 100.ms, duration: 350.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 8),
                      if (favPlace.address != null && favPlace.address!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFE07A5F)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                favPlace.address!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF5A4D41),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fade(delay: 150.ms, duration: 350.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFECE7DF), thickness: 1.2),
                      const SizedBox(height: 16),
                      Text(
                        'JOURNAL ENTRY',
                        style: theme.textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF8E8071),
                        ),
                      ).animate().fade(delay: 200.ms, duration: 300.ms),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F2EC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFECE7DF), width: 1.2),
                        ),
                        child: Text(
                          favPlace.note,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF3D2F22),
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ).animate().fade(delay: 250.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 24),
                      _buildTravelerMetrics(theme).animate().fade(delay: 350.ms, duration: 400.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelerMetrics(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EAE1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B2118).withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F3ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.explore_outlined, color: Color(0xFF81B29A), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Travel Coordinates',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2B2118),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  favPlace.latitude != null && favPlace.longitude != null
                      ? 'Lat: ${favPlace.latitude!.toStringAsFixed(4)}, Lon: ${favPlace.longitude!.toStringAsFixed(4)}'
                      : 'Saved securely on your local vault',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6C5D50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
