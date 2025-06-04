import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:visit_tracker/models/visit.dart';
import 'package:visit_tracker/providers/visit_provider.dart';
import 'package:visit_tracker/services/visit_service.dart';

import 'visit_provider_test.mocks.dart';

@GenerateMocks([VisitService])
void main() {
  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(VisitAdapter());
    }
    await Hive.openBox<Visit>('visits');
  });

  tearDown(() async {
    await Hive.close();
  });

  test('VisitProvider Adds unsynced visits when API fails', () async {
    // Create a mock service that will throw an exception
    final mockService = MockVisitService();
    when(mockService.addVisit(any)).thenThrow(Exception('API Error'));
    
    final provider = VisitProvider(service: mockService);

    final visit = Visit(
        id: 123,
        customerId: 1,
        visitDate: DateTime.now(),
        status: 'Pending',
        location: 'Test Location',
        notes: 'Some Notes',
        activityDone: ['activity1', 'activity2'],
        isSynced: false
    );

    await provider.addVisit(visit);

    expect(provider.visits.length, greaterThan(0));
    expect(provider.visits.first.isSynced, isFalse);
    // The ID should be a temporary ID (high number)
    expect(provider.visits.first.id, greaterThanOrEqualTo(1000000000));
  });

  test('VisitProvider Adds synced visits when API succeeds', () async {
    // Create a mock service that will return a successful response
    final mockService = MockVisitService();
    final createdVisit = Visit(
        id: 456, // Supabase generated ID
        customerId: 1,
        visitDate: DateTime.now(),
        status: 'Pending',
        location: 'Test Location',
        notes: 'Some Notes',
        activityDone: ['activity1', 'activity2'],
        isSynced: true
    );
    when(mockService.addVisit(any)).thenAnswer((_) async => createdVisit);
    
    final provider = VisitProvider(service: mockService);

    final visit = Visit(
        id: 0, // New visit
        customerId: 1,
        visitDate: DateTime.now(),
        status: 'Pending',
        location: 'Test Location',
        notes: 'Some Notes',
        activityDone: ['activity1', 'activity2'],
        isSynced: false
    );

    await provider.addVisit(visit);

    expect(provider.visits.length, greaterThan(0));
    expect(provider.visits.first.isSynced, isFalse); // Preserves original isSynced value
    expect(provider.visits.first.id, equals(456)); // Uses Supabase ID
  });
}