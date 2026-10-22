import 'package:flutter/material.dart';

import 'facility.dart';

/// Data model untuk lapangan padel.
class Court {
  const Court({
    required this.id,
    required this.name,
    required this.address,
    required this.pricePerHour,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.category,
    required this.facilities,
    required this.galleryColors,
    required this.description,
    this.assetImages = const [],
  });

  final String id;
  final String name;
  final String address;
  final double pricePerHour;
  final double rating;
  final int reviewCount;
  final double distanceKm;

  /// 'Indoor', 'Outdoor', atau 'Premium'.
  final String category;

  final List<Facility> facilities;

  /// Warna-warna untuk placeholder foto carousel (tanpa asset jaringan).
  final List<List<Color>> galleryColors;

  /// Path asset foto asli lapangan (opsional, prioritas atas placeholder).
  final List<String> assetImages;

  final String description;

  Court copyWith({double? pricePerHour}) => Court(
        id: id,
        name: name,
        address: address,
        pricePerHour: pricePerHour ?? this.pricePerHour,
        rating: rating,
        reviewCount: reviewCount,
        distanceKm: distanceKm,
        category: category,
        facilities: facilities,
        galleryColors: galleryColors,
        description: description,
        assetImages: assetImages,
      );
}
