import 'package:flutter_test/flutter_test.dart';
import 'package:visit_tracker/models/visit.dart';

void main(){
  test('Visit toJson and fromJson work correctly', (){
    final original = Visit(
        id: 1,
        customerId: 2,
        visitDate: DateTime.parse('2023-10-01T12:00:00Z'),
        status: 'Completed',
        location: 'Nairobi',
        notes: 'Test visit',
        activityDone: ['activity1', 'activity2'],
        isSynced: true
    );

    final json = original.toJson();
    final recreated = Visit.fromJson({
      ...json,
      'id': 1, // From Supabase
    });

    expect(recreated.customerId, equals(original.customerId));
    expect(recreated.activityDone, equals(original.activityDone));
    expect(recreated.status, equals('Completed'));
  });
}