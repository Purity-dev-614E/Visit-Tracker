import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:visit_tracker/services/visit_service.dart';
import '../models/visit.dart';

class VisitProvider with ChangeNotifier{
  final VisitService _service = VisitService();
  List<Visit> _visits = [];

  List<Visit> get visits => _visits;

  Future<void> loadFromApi() async {
    _visits = await _service.fetchVisits();
    final box = Hive.box<Visit>('visits');
    await box.clear();
    for (var visit in _visits) {
      await box.put(visit.id,visit);
    }
    notifyListeners();
  }

  void loadFromHive() {
    final box = Hive.box<Visit>('visits');
    _visits = box.values.toList();
    notifyListeners();
  }

  Future<void> addVisit(Visit visit) async {
    final box = Hive.box<Visit>('visits');
    try {
      final created = await _service.addVisit(visit);
      final syncedVisit = created.copyWith(isSynced: true);
      await box.put(created.id, syncedVisit);
      _visits.add(syncedVisit);
    } catch (_){
      // If API call fails, save visit as unsynced
      final unsyncedVisit = visit.copyWith(isSynced: false);
      await box.put(unsyncedVisit.id, unsyncedVisit);
      _visits.add(unsyncedVisit);
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
    for(var visit in _visits.where((v) => !v.isSynced)) {
      try {
        await _service.addVisit(visit);
        final syncedVisit = visit.copyWith(isSynced: true);
        await box.put(syncedVisit.id, syncedVisit);
      } catch (e) {
        // Handle sync error
        print('Failed to sync visit ${visit.id}: $e');
      }
      loadFromHive();
    }
    notifyListeners();
  }


}