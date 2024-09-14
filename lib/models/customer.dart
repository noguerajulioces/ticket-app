class Customer {
  final int? id;
  final String fullName;
  final String? vehicleType;
  final String? licensePlate;
  final String document;
  final String? company;
  final String? ticketNumber;

  Customer({
    this.id,
    required this.fullName,
    this.vehicleType,
    this.licensePlate,
    required this.document,
    this.company,
    this.ticketNumber,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      vehicleType: map['vehicle_type'] as String,
      licensePlate: map['license_plate'] as String,
      document: map['document'] as String,
      company: map['company'] as String,
      ticketNumber: map['ticket_number'] as String?,
    );
  }
}
