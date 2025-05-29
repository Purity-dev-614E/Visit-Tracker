import 'package:visit_tracker/models/visit.dart';
import 'package:visit_tracker/services/api_client.dart';

class VisitService {
  final ApiClient _api = ApiClient();

  Future<List<Visit>> fetchVisits() async {
    final data = await _api.get('visits');
    return data.map<Visit>((item) => Visit.fromJson(item)).toList();
  }

  Future<Visit> addVisit(Visit visit) async {
    final created = await _api.post('visits', visit.toJson());
    return Visit.fromJson(created);
  }

  Future<void> updateVisit(int id, Map<String, dynamic> updates) async {
    await _api.patch('visits?id=eq.$id', updates);
  }

  Future<void> deleteVisit(int id) async {
    await _api.delete('visits?id=eq.$id');
  }
}