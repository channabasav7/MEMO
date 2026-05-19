import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:favoriteplaces/data/fav_placedata.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favoriteplaces/provider/auth_provider.dart';
import 'package:favoriteplaces/provider/favorites_provider.dart';
import 'package:favoriteplaces/storage_service.dart';
import 'package:favoriteplaces/widgets.dart';

class AddFavoriteScreen extends ConsumerStatefulWidget {
  const AddFavoriteScreen({super.key});

  @override
  ConsumerState<AddFavoriteScreen> createState() => _AddFavoriteScreenState();
}

class _AddFavoriteScreenState extends ConsumerState<AddFavoriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  double _uploadProgress = 0;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _savePlace() async {
    final authState = ref.read(authProvider);
    final userId = authState.user?.uid;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hasImage = kIsWeb ? _selectedImageBytes != null : _selectedImage != null;

    if (!hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo first.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final storageService = StorageService();
      final placeId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload image
      final imageUrl = await storageService.uploadImage(
        userId: userId,
        placeId: placeId,
        imageFile: _selectedImage,
        imageBytes: _selectedImageBytes,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      // Create place object with image URL
      final place = FavPlace(
        id: placeId,
        title: _titleController.text,
        note: _descriptionController.text,
        imageUrl: imageUrl,
        userId: userId,
        address: _addressController.text.isNotEmpty 
            ? _addressController.text 
            : null,
      );

      // Save to Firestore
      await ref.read(firestoreServiceProvider).addPlace(userId, place);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Place added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedImage == null) return;
      if (kIsWeb) {
        final bytes = await pickedImage.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImage = null;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedImage.path);
          _selectedImageBytes = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Favorite Place'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker
                    Text(
                      'Photo',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _isUploading ? null : _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedImage == null
                                ? Colors.grey[400]!
                                : Colors.green,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to add photo',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: kIsWeb
                                        ? (_selectedImageBytes != null
                                            ? Image.memory(
                                                _selectedImageBytes!,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(
                                                      Icons.image_not_supported),
                                                ),
                                              ))
                                        : Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  if (_isUploading)
                                    Container(
                                      color: Colors.black54,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Colors.white.withOpacity(0.9),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit),
                                        iconSize: 18,
                                        onPressed:
                                            _isUploading ? null : _pickImage,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title Field
                    Text(
                      'Title',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      enabled: !_isUploading,
                      decoration: InputDecoration(
                        hintText: 'e.g., Sunset at the Beach',
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Address Field
                    Text(
                      'Address (Optional)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      enabled: !_isUploading,
                      decoration: InputDecoration(
                        hintText: 'Location details',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    Text(
                      'Note',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !_isUploading,
                      decoration: InputDecoration(
                        hintText: 'Add a note about this place',
                        prefixIcon: const Icon(Icons.note_outlined),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Note is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _savePlace,
                        icon: const Icon(Icons.save),
                        label: Text(_isUploading
                            ? 'Uploading...'
                            : 'Save Place'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isUploading 
                            ? null 
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          if (_isUploading)
            const LoadingOverlay(message: 'Uploading your place...'),
        ],
      ),
    );
  }
}
