// lib/models/paket_pendakian.dart
class PaketPendakian {
  final String id;
  final String name;
  final String route;
  final String duration;
  final int quota;
  final String description;
  final String image;
  final double price; // ✅ PASTIKAN double

  PaketPendakian({
    required this.id,
    required this.name,
    required this.route,
    required this.duration,
    required this.quota,
    required this.description,
    required this.image,
    required this.price,
  });

  factory PaketPendakian.fromMap(Map<String, dynamic> map) {
    return PaketPendakian(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      route: map['route'] ?? '',
      duration: map['duration'] ?? '',
      quota: map['quota'] ?? 0,
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0, // ✅ Convert to double
    );
  }
}