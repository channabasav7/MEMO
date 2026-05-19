import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavPlace {
  final String id;
  final String title;
  final String note;
  final File? image; // Local image file (for new uploads)
  final String? imageUrl; // Firebase Storage URL
  final String? docId; // Firestore document ID
  final String? userId;
  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FavPlace({
    required this.id,
    required this.title,
    required this.note,
    this.image,
    this.imageUrl,
    this.docId,
    this.userId,
    this.latitude,
    this.longitude,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from Firestore document
  factory FavPlace.fromMap(Map<String, dynamic> map) {
    return FavPlace(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      note: map['note'] ?? '',
      imageUrl: map['imageUrl'],
      docId: map['docId'],
      userId: map['userId'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'imageUrl': imageUrl,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Copy with method for easy updates
  FavPlace copyWith({
    String? id,
    String? title,
    String? note,
    File? image,
    String? imageUrl,
    String? docId,
    String? userId,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavPlace(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      docId: docId ?? this.docId,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
