/// Class representing a customer, storing information related to their vehicle,
/// identification document, associated company, and ticket number.

class Customer {
  final int? id;
  final String fullName;
  final String? vehicleType;
  final String? licensePlate;
  final String document;
  final String? company;
  final String? ticketNumber;
  final int? attended;
  final DateTime? createdAt;
  final String? formattedCreatedAt;

  Customer({
    this.id,
    required this.fullName,
    this.vehicleType,
    this.licensePlate,
    required this.document,
    this.company,
    this.ticketNumber,
    this.attended,
    this.createdAt,
    this.formattedCreatedAt,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
        id: map['id'] != null
            ? int.tryParse(map['id'].toString())
            : null, // Safely convert to int
        fullName: map['full_name'] as String,
        vehicleType: map['vehicle_type'] as String?,
        licensePlate: map['license_plate'] as String?,
        document: map['document'] as String,
        company: map['company'] as String?,
        ticketNumber: map['ticket_number'] as String?,
        attended: map['attended'] != null
            ? int.tryParse(map['attended'].toString())
            : null,
        createdAt: map['createdApp'] as DateTime?,
        formattedCreatedAt: map['formattedCreatedAt'] as String?);
  }
}
