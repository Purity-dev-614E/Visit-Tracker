import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:visit_tracker/services/visit_service.dart';
import '../models/visit.dart';

class VisitProvider with ChangeNotifier {
  final VisitService _service = VisitService();
  List<Visit> _visits = [];

  final logger = Logger();
  List<Visit> get visits => _visits;

  Future<void> loadFromApi() async {
    _visits = await _service.fetchVisits();
    final box = Hive.box<Visit>('visits');
    await box.clear();
    for (var visit in _visits) {
      await box.put(visit.id, visit);
    }
    notifyListeners();
  }

  void loadFromHive() {
    final box = Hive.box<Visit>('visits');
    _visits = box.values.toList();
    notifyListeners();
  }

  Future<void> addVisit(Visit visit) async {
    logger.i('VisitProvider: Adding visit to Supabase');
    logger.i('Visit data: ${visit.toJson()}');
    
    final box = Hive.box<Visit>('visits');
    try {
      // Send to Supabase and get the created visit with the generated ID
      final created = await _service.addVisit(visit);
      logger.i('Visit created successfully with Supabase ID: ${created.id}');
      
      // Store the visit with the Supabase-generated ID
      final syncedVisit = created.copyWith(isSynced: true);
      await box.put(created.id, syncedVisit);
      _visits.add(syncedVisit);
      logger.i('Visit added to local storage and state with ID: ${created.id}');
    } catch (e) {
      logger.e('Error in VisitProvider.addVisit: $e');
      
      // If API call fails, generate a temporary negative ID for local storage
      // Using negative IDs ensures they won't conflict with Supabase IDs
      final tempId = -DateTime.now().millisecondsSinceEpoch;
      logger.i('Generated temporary negative ID for local storage: $tempId');
      
      // Save visit as unsynced with the temporary ID
      final unsyncedVisit = visit.copyWith(id: tempId, isSynced: false);
      await box.put(tempId, unsyncedVisit);
      _visits.add(unsyncedVisit);
      logger.i('Visit saved locally as unsynced with temp ID: $tempId');
    }
    notifyListeners();
  }

  Future<void> deleteVisit(int id) async {
    await _service.deleteVisit(id);
    final box = Hive.box<Visit>('visits');
    await box.delete(id);
    _visits.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> syncUnsyncVisits() async {
    final box = Hive.box<Visit>('visits');
    for (var visit in _visits.where((v) => !v.isSynced)) {
      try {
        logger.i('Attempting to sync unsynced visit with temp ID: ${visit.id}');
        
        // Create a copy of the visit with id=0 so Supabase will generate a new ID
        final visitForSync = visit.copyWith(id: 0);
        
        // Send to Supabase and get the created visit with the generated ID
        final created = await _service.addVisit(visitForSync);
        logger.i('Visit synced successfully with new Supabase ID: ${created.id}');
        
        // Remove the old temporary ID entry
        await box.delete(visit.id);
        
        // Add the new entry with the Supabase-generated ID
        final syncedVisit = created.copyWith(isSynced: true);
        await box.put(created.id, syncedVisit);
        
        // Update the visits list
        _visits.remove(visit);
        _visits.add(syncedVisit);
        
        logger.i('Local storage updated with synced visit');
      } catch (e) {
        // Handle sync error
        logger.e('Failed to sync visit ${visit.id}: $e');
      }
    }
    notifyListeners();
  }
}
