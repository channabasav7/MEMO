import 'dart:io';
import 'package:favoriteplaces/data/fav_placedata.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favoriteplaces/provider/fav_place_provider.dart';

class AddFavoriteScreen extends ConsumerStatefulWidget {
  const AddFavoriteScreen({super.key});

  @override
  ConsumerState<AddFavoriteScreen> createState() => _AddFavoriteScreenState();
}

class _AddFavoriteScreenState extends ConsumerState<AddFavoriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  void _savePlace() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedImage == null) {
      // You might want to show an error to the user here
      return;
    }
    ref.read(favPlaceProvider.notifier).addPlace(
          FavPlace(
            id: DateTime.now().toString(),
            title: _titleController.text,
            note: _descriptionController.text,
            image: _selectedImage!,
          ),
        );
    Navigator.of(context).pop();
  }

  Future<void> _pickImage() async {
    XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);

    if (pickedImage == null) return;
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Favorite Places",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _selectedImage == null
                    ? SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          child: const Icon(Icons.image_outlined, size: 200),
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(),
                            padding: const EdgeInsets.all(20),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      )
                    : Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'cancel',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.copyWith(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _savePlace,
                      child: Text(
                        'Save',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
