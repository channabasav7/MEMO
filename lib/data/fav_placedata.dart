import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class FavPlace {
  final String id;
  final String title;
  final String note;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final String? docId;
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
    this.imageBytes,
    this.imageUrl,
    this.docId,
    this.userId,
    this.latitude,
    this.longitude,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory FavPlace.fromMap(Map<String, dynamic> map) {
    return FavPlace(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      note: map['note'] ?? '',
      imageBytes: map['imageBase64'] != null
          ? base64Decode(map['imageBase64'] as String)
          : null,
      imageUrl: map['imageUrl'],
      docId: map['docId'],
      userId: map['userId'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'],
      createdAt: map['createdAt'] == null
          ? null
          : map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()),
      updatedAt: map['updatedAt'] == null
          ? null
          : map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'imageBase64': imageBytes != null ? base64Encode(imageBytes!) : null,
      'imageUrl': imageUrl,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  FavPlace copyWith({
    String? id,
    String? title,
    String? note,
    Uint8List? imageBytes,
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
      imageBytes: imageBytes ?? this.imageBytes,
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
