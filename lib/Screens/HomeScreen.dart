import 'package:favoriteplaces/Screens/AddFavoriteScreen.dart';
import 'package:favoriteplaces/Screens/Fav_detailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/fav_place_provider.dart' show favPlaceProvider;

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
            'Thank you for installing our app \n take a photo of your first place \n add a note',
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
    final favplaces = ref.watch(favPlaceProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorite Places',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        centerTitle: true,
      ),
      body: favplaces.isEmpty
          ? const Center(child: Text('No Favorite Places'))
          : ListView.builder(
              itemCount: favplaces.length,
              itemBuilder: (context, index) {
                final place = favplaces[index];
                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FavDetailScreen(favPlace: place),
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      tileColor: Colors.white,
                      leading: Image.file(
                        place.image,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                      title: Text(place.title),
                      subtitle: Text(place.note),
                      trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            ref
                                .read(favPlaceProvider.notifier)
                                .removePlace(place.id);
                          }),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const AddFavoriteScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
