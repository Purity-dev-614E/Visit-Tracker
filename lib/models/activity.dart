import 'package:hive/hive.dart';
part 'activity.g.dart';

@HiveType(typeId: 1)
class Activity {
  @HiveField(0) int id;
  @HiveField(1) String description;

  Activity({required this.id, required this.description});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int,
      description: json['description'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }
}