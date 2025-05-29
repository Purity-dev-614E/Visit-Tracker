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
    return _activities.firstWhere((element) => element.id.toString() == id,
        orElse: () => Activity(id: 0, description: "Unknown")).description;
  }
}