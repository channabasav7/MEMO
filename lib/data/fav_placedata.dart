import 'dart:io';

class FavPlace {
  final String id;
  final String title;
  final String note;
  final File image;

  FavPlace({
    required this.id,
    required this.title,
    required this.note,
    required this.image,
  });
}
