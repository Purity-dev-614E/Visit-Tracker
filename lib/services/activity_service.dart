import 'package:visit_tracker/models/activity.dart';
import 'package:visit_tracker/services/api_client.dart';

class ActivityService {
  final ApiClient _api = ApiClient();

  Future<List<Activity>> fetchActivities() async {
    final data = await _api.get('activities');
    return data.map<Activity>((item) => Activity.fromJson(item)).toList();
  }
}