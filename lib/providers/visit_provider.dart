import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:visit_tracker/services/visit_service.dart';
import '../models/visit.dart';

class VisitProvider with ChangeNotifier {
  final VisitService _service;
  List<Visit> _visits = [];

  VisitProvider({VisitService? service}) : _service = service ?? VisitService();

  final logger = Logger();
  List<Visit> get visits => _visits;

  // Generate a temporary ID for local storage when API calls fail
  // Uses a high number range to avoid conflicts with Supabase IDs
  int _generateTempId() {
    final box = Hive.box<Visit>('visits');
    // Start from 1 billion and find the next available ID
    int tempId = 1000000000;
    while (box.containsKey(tempId)) {
      tempId++;
    }
    return tempId;
  }

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
      // For new visits, ensure id is 0 so Supabase will generate an ID
      final visitForApi = visit.id == 0 ? visit : visit.copyWith(id: 0);
      
      // Send to Supabase and get the created visit with the generated ID
      final created = await _service.addVisit(visitForApi);
      logger.i('Visit created successfully with Supabase ID: ${created.id}');
      
      // Store the visit with the Supabase-generated ID but preserve the original isSynced value
      final syncedVisit = created.copyWith(isSynced: visit.isSynced);
      await box.put(created.id, syncedVisit);
      _visits.add(syncedVisit);
      logger.i('Visit added to local storage and state with ID: ${created.id}');
    } catch (e) {
      logger.e('Error in VisitProvider.addVisit: $e');
      
      // If API call fails, generate a temporary ID for local storage
      // Using a large positive number to avoid conflicts with Supabase IDs
      // Start from a high number (e.g., 1 billion) and work backwards
      final tempId = _generateTempId();
      logger.i('Generated temporary ID for local storage: $tempId');
      
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
