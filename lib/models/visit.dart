import 'package:hive/hive.dart';
part 'visit.g.dart';

@HiveType(typeId: 2)
class Visit extends HiveObject {
  @HiveField(0) final int id;
  @HiveField(1) final int customerId;
  @HiveField(2) final DateTime visitDate;
  @HiveField(3) final String status;
  @HiveField(4) final String location;
  @HiveField(5) final String notes;
@HiveField(6) final List<String> activityDone;
@HiveField(7) final bool isSynced;

  Visit({
    required this.id,
    required this.customerId,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.activityDone,
    this.isSynced = true,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      visitDate: DateTime.parse(json['visit_date'] as String),
      status: json['status'] as String,
      location: json['location'] as String,
      notes: json['notes'] as String,
      activityDone: List<String>.from(json['activity_done']),
      isSynced: true
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activity_done': activityDone,
    };
  }

  Visit copyWith({
    int? id,
    int? customerId,
    DateTime? visitDate,
    String? status,
    String? location,
    String? notes,
    List<String>? activityDone,
    bool? isSynced,
  }) {
    return Visit(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      activityDone: activityDone ?? this.activityDone,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}