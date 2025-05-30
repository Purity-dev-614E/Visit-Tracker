import 'dart:convert';
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
    // Handle potential null values and type conversions
    final id = json['id'] is String ? int.parse(json['id']) : json['id'] as int;
    final customerId = json['customer_id'] is String ? int.parse(json['customer_id']) : json['customer_id'] as int;
    
    // Handle activities_done which might be a string, list, or null
    List<String> activities = [];
    if (json['activities_done'] != null) {
      if (json['activities_done'] is List) {
        activities = (json['activities_done'] as List).map((item) => item.toString()).toList();
      } else if (json['activities_done'] is String) {
        // If it's a string, try to parse it as JSON
        try {
          final parsed = jsonDecode(json['activities_done'] as String);
          if (parsed is List) {
            activities = parsed.map((item) => item.toString()).toList();
          }
        } catch (_) {
          // If parsing fails, treat it as a single item
          activities = [json['activities_done'] as String];
        }
      }
    }
    
    return Visit(
      id: id,
      customerId: customerId,
      visitDate: DateTime.parse(json['visit_date'] as String),
      status: json['status'] as String,
      location: json['location'] as String,
      notes: json['notes'] ?? '',  // Handle potential null
      activityDone: activities,
      isSynced: true
    );
  }

  Map<String, dynamic> toJson() {
    // Convert activities to JSON-compatible format
    final List<dynamic> activitiesJson = activityDone.map((activity) => activity.toString()).toList();
    
    // Create the base map without the ID field
    final Map<String, dynamic> json = {
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activitiesJson,
    };
    
    // Only include ID for local storage, not for API requests to Supabase
    // This is because Supabase is set to auto-generate IDs
    if (id != 0) {
      json['id'] = id;
    }
    
    return json;
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