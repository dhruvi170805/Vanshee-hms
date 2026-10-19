class HmsRoom {
  final int id;
  final String roomNumber;
  final String wardName;
  final String roomType;
  final int totalBeds;
  final int occupiedBeds;
  final int floorNumber;
  final double dailyCharge;
  final String status;

  HmsRoom({
    required this.id,
    required this.roomNumber,
    required this.wardName,
    this.roomType = 'General',
    this.totalBeds = 1,
    this.occupiedBeds = 0,
    this.floorNumber = 1,
    this.dailyCharge = 0,
    this.status = 'Available',
  });

  int get availableBeds => totalBeds - occupiedBeds;

  factory HmsRoom.fromJson(Map<String, dynamic> json) => HmsRoom(
        id: json['id'] ?? 0,
        roomNumber: json['room_number'] ?? '',
        wardName: json['ward_name'] ?? '',
        roomType: json['room_type'] ?? 'General',
        totalBeds: json['total_beds'] ?? 1,
        occupiedBeds: json['occupied_beds'] ?? 0,
        floorNumber: json['floor_number'] ?? 1,
        dailyCharge: (json['daily_charge'] ?? 0).toDouble(),
        status: json['status'] ?? 'Available',
      );

  Map<String, dynamic> toJson() => {
        'room_number': roomNumber,
        'ward_name': wardName,
        'room_type': roomType,
        'total_beds': totalBeds,
        'occupied_beds': occupiedBeds,
        'floor_number': floorNumber,
        'daily_charge': dailyCharge,
        'status': status,
      };
}
