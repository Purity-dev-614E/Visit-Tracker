import 'package:logger/logger.dart';
import 'package:visit_tracker/models/visit.dart';
import 'package:visit_tracker/services/api_client.dart';

class VisitService {
  final ApiClient _api = ApiClient();
  final logger = Logger();

  Future<List<Visit>> fetchVisits() async {
    final data = await _api.get('visits');
    return data.map<Visit>((item) => Visit.fromJson(item)).toList();
  }

  Future<Visit> addVisit(Visit visit) async {
    try {
      logger.i('Attempting to add visit to Supabase');
      logger.i('Visit data: ${visit.toJson()}');
      
      // Send the visit data to Supabase (without the ID)
      final created = await _api.post('visits', visit.toJson());
      logger.i('Visit added successfully to Supabase');
      logger.i('Response from Supabase: $created');
      
      // If created is a List, take the first item
      if (created is List && created.isNotEmpty) {
        return Visit.fromJson(created[0]);
      }
      
      // Otherwise, assume it's a Map
      return Visit.fromJson(created);
    } catch (e) {
      logger.e('Error in addVisit: $e');
      rethrow;
    }
  }

  Future<void> updateVisit(int id, Map<String, dynamic> updates) async {
    await _api.patch('visits?id=eq.$id', updates);
  }

  Future<void> deleteVisit(int id) async {
    await _api.delete('visits?id=eq.$id');
  }
}