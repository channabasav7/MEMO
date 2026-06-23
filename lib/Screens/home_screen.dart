import 'package:favoriteplaces/screens/add_favorite_screen.dart';
import 'package:favoriteplaces/screens/fav_detail_screen.dart';
import 'package:favoriteplaces/provider/auth_provider.dart';
import 'package:favoriteplaces/provider/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'date_desc'; // 'date_desc', 'date_asc', 'alpha_asc', 'alpha_desc'

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final firstTime = prefs.getBool('FirstTime') ?? true;
    if (firstTime && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showWelcomeDialog();
        }
      });
      await prefs.setBool('FirstTime', false);
    }
  }

  void showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Welcome Explorer!'),
        content: const Text(
          'Capture a photo of your first special place and add a journal note to remember it forever.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Let\'s Go'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
  }

  Future<void> _deletePlace(String userId, String placeId) async {
    await ref.read(favoritesProvider(userId).notifier).deletePlace(placeId);
  }

  void _confirmDelete(BuildContext context, String userId, String placeId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete place?'),
        content: const Text('This will remove this place from your local log.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deletePlace(userId, placeId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Widget _buildSortChip(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _sortBy = value),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF6C5D50)),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selectedColor: const Color(0xFFE07A5F),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF6C5D50),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.transparent : const Color(0xFFECE7DF),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.uid;
    final theme = Theme.of(context);

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 72, color: Color(0xFFE07A5F)),
                const SizedBox(height: 16),
                Text(
                  'Sign in to see your places',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your saved places stay on this device for the signed-in account.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/login'),
                  child: const Text('Sign In Now'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final favoritesState = ref.watch(favoritesProvider(userId));
    final places = favoritesState.places;

    // 1. Filter places based on search query
    var filteredPlaces = places.where((place) {
      final query = _searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;
      return place.title.toLowerCase().contains(query) ||
          place.note.toLowerCase().contains(query) ||
          (place.address?.toLowerCase().contains(query) ?? false);
    }).toList();

    // 2. Sort places based on chosen parameter
    filteredPlaces.sort((a, b) {
      if (_sortBy == 'alpha_asc') {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      } else if (_sortBy == 'alpha_desc') {
        return b.title.toLowerCase().compareTo(a.title.toLowerCase());
      } else if (_sortBy == 'date_asc') {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      } else { // 'date_desc' is default
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Color(0xFF6C5D50)),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: favoritesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, Explorer',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'You have logged ${places.length} special places.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6C5D50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search title, note, or location...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF8E8071)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF8E8071)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFECE7DF)),
                      ),
                    ),
                  ),
                ),
                if (places.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildSortChip('date_desc', 'Newest First', Icons.arrow_downward),
                        const SizedBox(width: 8),
                        _buildSortChip('date_asc', 'Oldest First', Icons.arrow_upward),
                        const SizedBox(width: 8),
                        _buildSortChip('alpha_asc', 'Alphabetical A-Z', Icons.sort_by_alpha),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: places.isEmpty
                      ? _EmptyState(
                          onAdd: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddFavoriteScreen()),
                            );
                          },
                        )
                      : filteredPlaces.isEmpty
                          ? Center(
                              child: Text(
                                'No matching places found.',
                                style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF8E8071)),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                              itemCount: filteredPlaces.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final place = filteredPlaces[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2B2118).withOpacity(0.04),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => FavDetailScreen(favPlace: place),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Hero(
                                              tag: 'image-${place.id}',
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(16),
                                                child: place.imageBytes != null
                                                    ? Image.memory(
                                                        place.imageBytes!,
                                                        width: 90,
                                                        height: 90,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        width: 90,
                                                        height: 90,
                                                        color: const Color(0xFFF5F2EC),
                                                        child: const Icon(Icons.image_not_supported, color: Color(0xFF8E8071)),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    place.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                  if (place.createdAt != null) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _formatDate(place.createdAt),
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: const Color(0xFF8E8071),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    place.note,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: const Color(0xFF5A4D41),
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                  if (place.address != null && place.address!.isNotEmpty) ...[
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFE07A5F)),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            place.address!,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: theme.textTheme.bodySmall?.copyWith(
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _confirmDelete(context, userId, place.docId ?? place.id),
                                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ).animate().fade(delay: (index * 40).ms, duration: 350.ms).slideX(begin: 0.04, end: 0);
                              },
                            ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddFavoriteScreen()),
          );
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Memory'),
        backgroundColor: const Color(0xFFE07A5F),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFDE8DD),
              ),
              child: const Icon(Icons.landscape_outlined, size: 56, color: Color(0xFFE07A5F)),
            ),
            const SizedBox(height: 24),
            Text(
              'No travel memories yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start documenting the special places you visit. They will stay stored safely on this device.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6C5D50)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Add Your First Memory'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE07A5F),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
