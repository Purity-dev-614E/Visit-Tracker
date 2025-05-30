import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:visit_tracker/services/activity_service.dart';
import '../models/activity.dart';

class ActivityProvider with ChangeNotifier{
  final ActivityService _service = ActivityService();
  List<Activity> _activities = [];

  List<Activity> get activities => _activities;

  Future<void> loadFromApi() async {
    _activities = await _service.fetchActivities();
    final box = Hive.box<Activity>('activities');
    await box.clear();
    for (final activity in _activities) {
      box.put(activity.id, activity);
    }
    notifyListeners();
  }

  void loadFromHive() {
    final box = Hive.box<Activity>('activities');
    _activities = box.values.toList();
    notifyListeners();
  }

  String getDescription(String id){
    // Print for debugging
    print('Looking for activity with ID: $id');
    print('Available activities: ${_activities.map((a) => '${a.id}: ${a.description}').join(', ')}');
    
    // Try to parse the ID as an integer if possible
    int? numericId;
    try {
      numericId = int.parse(id);
    } catch (e) {
      print('Could not parse activity ID as integer: $id');
    }
    
    // First try to match by numeric ID if we could parse it
    if (numericId != null) {
      final activityByNumericId = _activities.firstWhere(
        (element) => element.id == numericId,
        orElse: () => Activity(id: 0, description: "Unknown")
      );
      
      if (activityByNumericId.id != 0) {
        print('Found activity by numeric ID: ${activityByNumericId.description}');
        return activityByNumericId.description;
      }
    }
    
    // Then try to match by string ID
    final activityByStringId = _activities.firstWhere(
      (element) => element.id.toString() == id,
      orElse: () => Activity(id: 0, description: "Unknown")
    );
    
    print('Found activity by string ID: ${activityByStringId.description}');
    return activityByStringId.description;
  }
}