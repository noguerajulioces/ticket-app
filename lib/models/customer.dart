/// Class representing a customer, storing information related to their vehicle,
/// identification document, associated company, and ticket number.
class Customer {
  /// Unique ID of the customer, typically auto-incremented in the database.
  final int? id;

  /// Full name of the customer.
  final String fullName;

  /// Type of vehicle owned by the customer. Can be null if not provided.
  final String? vehicleType;

  /// License plate of the customer's vehicle. Can be null if not provided.
  final String? licensePlate;

  /// Identification document of the customer (e.g., ID number or passport).
  final String document;

  /// Company associated with the customer, if applicable. Can be null if not provided.
  final String? company;

  /// Ticket number assigned to the customer. Can be null if not yet assigned.
  final String? ticketNumber;

  /// Constructor for the [Customer] class.
  ///
  /// - [id]: Unique identifier for the customer, optional.
  /// - [fullName]: Full name of the customer, required.
  /// - [vehicleType]: Type of the customer's vehicle, optional.
  /// - [licensePlate]: License plate of the vehicle, optional.
  /// - [document]: Customer's identification document, required.
  /// - [company]: Associated company, optional.
  /// - [ticketNumber]: Ticket number assigned to the customer, optional.
  Customer({
    this.id,
    required this.fullName,
    this.vehicleType,
    this.licensePlate,
    required this.document,
    this.company,
    this.ticketNumber,
  });

  /// Factory method that creates a [Customer] instance from a data map.
  ///
  /// The map [map] should contain keys corresponding to the database column names,
  /// and each value will be converted to the appropriate type.
  ///
  /// - [id]: An optional integer representing the customer's ID.
  /// - [full_name]: A string representing the customer's full name.
  /// - [vehicle_type]: An optional string representing the vehicle type.
  /// - [license_plate]: An optional string representing the vehicle's license plate.
  /// - [document]: A string representing the customer's document.
  /// - [company]: An optional string representing the customer's company.
  /// - [ticket_number]: An optional string representing the customer's ticket number.
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      vehicleType: map['vehicle_type'] as String?,
      licensePlate: map['license_plate'] as String?,
      document: map['document'] as String,
      company: map['company'] as String?,
      ticketNumber: map['ticket_number'] as String?,
    );
  }
}
