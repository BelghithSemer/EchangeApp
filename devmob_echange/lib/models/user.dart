class AppUser {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.createdAt,
  });

  // Methods to convert to/from Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'rating': rating,
      'totalReviews': totalReviews,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static AppUser fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      rating: map['rating']?.toDouble() ?? 0.0,
      totalReviews: map['totalReviews'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}