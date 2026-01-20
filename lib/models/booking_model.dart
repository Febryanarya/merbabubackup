class Booking {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone; // ✅ Tambahan
  final String paketId;
  final String paketName;
  final String paketRoute; // ✅ sudah ada
  final int paketPrice; // ✅ tetap int
  final DateTime tanggalBooking;
  final int jumlahOrang;
  final double totalHarga;
  final String paymentMethod; // ✅ Tambahan
  final String status;
  final DateTime createdAt;
  final String? specialRequest; // ✅ Tambahan (opsional)
  final String? emergencyContact; // ✅ Tambahan (opsional)
  final String? idNumber; // ✅ Tambahan (opsional)

  Booking({
    this.id = '',
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone, // ✅ Tambahan
    required this.paketId,
    required this.paketName,
    required this.paketRoute, // ✅ tetap
    required this.paketPrice, // ✅ tetap
    required this.tanggalBooking,
    required this.jumlahOrang,
    required this.totalHarga,
    required this.paymentMethod, // ✅ Tambahan
    required this.status,
    required this.createdAt,
    this.specialRequest, // ✅ Tambahan
    this.emergencyContact, // ✅ Tambahan
    this.idNumber, // ✅ Tambahan
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone, // ✅ Tambahan
      'paketId': paketId,
      'paketName': paketName,
      'paketRoute': paketRoute, // ✅ tetap
      'paketPrice': paketPrice,
      'tanggalBooking': tanggalBooking.toIso8601String(),
      'jumlahOrang': jumlahOrang,
      'totalHarga': totalHarga,
      'paymentMethod': paymentMethod, // ✅ Tambahan
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'specialRequest': specialRequest, // ✅ Tambahan
      'emergencyContact': emergencyContact, // ✅ Tambahan
      'idNumber': idNumber, // ✅ Tambahan
    };
  }

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '', // ✅ Tambahan
      paketId: map['paketId'] ?? '',
      paketName: map['paketName'] ?? '',
      paketRoute: map['paketRoute'] ?? '',
      paketPrice: map['paketPrice'] ?? 0,
      tanggalBooking: DateTime.parse(map['tanggalBooking']),
      jumlahOrang: map['jumlahOrang'] ?? 0,
      totalHarga: (map['totalHarga'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'bank_transfer', // ✅ Tambahan
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      specialRequest: map['specialRequest'], // ✅ Tambahan
      emergencyContact: map['emergencyContact'], // ✅ Tambahan
      idNumber: map['idNumber'], // ✅ Tambahan
    );
  }
}
