import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:visit_tracker/models/visit.dart';
import 'package:visit_tracker/providers/visit_provider.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    Hive.registerAdapter(VisitAdapter());
    await Hive.openBox<Visit>('visits');
  });

  tearDown(() async {
    await Hive.close();
  });

  test('VisitProvider Adds unsynced visits', () async{
    final provider = VisitProvider();

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

  });
}