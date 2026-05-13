import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favoriteplaces/Screens/AddFavoriteScreen.dart';
import 'package:favoriteplaces/Screens/Fav_detailScreen.dart';
import 'package:favoriteplaces/provider/auth_provider.dart';
import 'package:favoriteplaces/provider/favorites_provider.dart';
import 'package:favoriteplaces/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final bool firstTime = prefs.getBool("FirstTime") ?? true;
    if (firstTime) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showWelcomeDialog();
      });
      await prefs.setBool("FirstTime", false);
    }
  }

  void showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Welcome!', style: Theme.of(context).textTheme.bodyLarge),
          content: Text(
            'Thank you for using our app!\n\nCapture a photo of your first special place and add a note to remember it forever.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorite Places'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Not logged in'),
        ),
      );
    }

    final favoritesAsync = ref.watch(favoritesStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorite Places',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () {
                  _handleLogout(context);
                },
              ),
            ],
          ),
        ],
      ),
      body: favoritesAsync.when(
        loading: () => ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => const PlaceCardSkeleton(),
        ),
        error: (error, stackTrace) => ErrorCard(
          message: error.toString(),
          onRetry: () => ref.refresh(favoritesStreamProvider(userId)),
        ),
        data: (places) {
          if (places.isEmpty) {
            return EmptyStateWidget(
              title: 'No places yet',
              subtitle: 'Start adding your favorite places',
              icon: Icons.location_on_outlined,
              onAction: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddFavoriteScreen(),
                  ),
                );
              },
              actionLabel: 'Add First Place',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: places.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final place = places[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FavDetailScreen(favPlace: place),
                  ),
                ),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        place.imageUrl != null
                            ? NetworkImageWidget(
                                imageUrl: place.imageUrl!,
                                size: 64,
                                borderRadius: BorderRadius.circular(12),
                              )
                            : Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[300],
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.title,
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                place.note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (place.address != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        place.address!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                              fontSize: 12,
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
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, place, userId),
                        ),
                      ],
                    ),
                  ),
                );
              };
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddFavoriteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic place, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Place?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlace(place, userId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deletePlace(dynamic place, String userId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Place deleted')),
    );
  }

  void _handleLogout(BuildContext context) {
    ref.read(authProvider.notifier).logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
}
