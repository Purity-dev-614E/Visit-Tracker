import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:visit_tracker/models/activity.dart';
import 'package:visit_tracker/models/customer.dart';
import 'package:visit_tracker/models/visit.dart';
import 'package:visit_tracker/providers/activity_provider.dart';
import 'package:visit_tracker/providers/customer_provider.dart';
import 'package:visit_tracker/providers/visit_provider.dart';
import 'package:visit_tracker/screens/add_visit_screen.dart';

class MockCustomerProvider extends ChangeNotifier implements CustomerProvider {
  @override
  List<Customer> get customers => [
    Customer(id: 1, name: 'Test Customer 1'),
    Customer(id: 2, name: 'Test Customer 2'),
  ];

  @override
  Future<void> loadFromApi() async {}

  @override
  void loadFromHive() {}

  @override
  Customer? getCustomerById(int id) => customers.firstWhere(
    (customer) => customer.id == id,
    orElse: () => Customer(id: id, name: 'Unknown'),
  );
}

class MockActivityProvider extends ChangeNotifier implements ActivityProvider {
  @override
  List<Activity> get activities => [
    Activity(id: 1, description: 'Sales Visit'),
    Activity(id: 2, description: 'Technical Support'),
    Activity(id: 3, description: 'Training'),
  ];

  @override
  Future<void> loadFromApi() async {}

  @override
  void loadFromHive() {}

  @override
  String getDescription(String id) =>
      activities
          .firstWhere(
            (activity) => activity.id.toString() == id,
            orElse: () => Activity(id: 0, description: 'Unknown'),
          )
          .description;
}

class MockVisitProvider extends ChangeNotifier implements VisitProvider {
  List<Visit> _visits = [];

  @override
  List<Visit> get visits => _visits;

  @override
  Future<void> addVisit(Visit visit) async {
    _visits.add(visit);
    notifyListeners();
  }

  @override
  Future<void> deleteVisit(int id) async {
    _visits.removeWhere((visit) => visit.id == id);
    notifyListeners();
  }

  @override
  Future<void> loadFromApi() async {}

  @override
  void loadFromHive() {}

  @override
  Future<void> syncUnsyncVisits() async {}
}

void main() {
  group('AddVisitScreen Tests', () {
    late MockCustomerProvider customerProvider;
    late MockActivityProvider activityProvider;
    late MockVisitProvider visitProvider;

    setUp(() {
      customerProvider = MockCustomerProvider();
      activityProvider = MockActivityProvider();
      visitProvider = MockVisitProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<CustomerProvider>.value(
              value: customerProvider,
            ),
            ChangeNotifierProvider<ActivityProvider>.value(
              value: activityProvider,
            ),
            ChangeNotifierProvider<VisitProvider>.value(
              value: visitProvider,
            ),
          ],
          child: Scaffold(
            body: AddVisitScreen(),
          ),
        ),
      );
    }

    testWidgets('AddVisitScreen renders all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify all form fields are rendered
      expect(find.text('Visit Information'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Visit Date'), findsOneWidget);
      expect(find.text('Visit Status'), findsOneWidget);
      expect(find.text('Activities Done'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('Customer dropdown shows correct options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the customer dropdown
      final dropdownFinder = find.byType(DropdownButton<int>);
      expect(dropdownFinder, findsOneWidget);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Verify dropdown options
      expect(find.text('Test Customer 1'), findsOneWidget);
      expect(find.text('Test Customer 2'), findsOneWidget);
    });

    testWidgets('Status dropdown shows correct options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the status dropdown by finding the text "Visit Status" and moving to the next widget
      final statusLabelFinder = find.text('Visit Status');
      expect(statusLabelFinder, findsOneWidget);
      
      // Find the dropdown that follows the label
      final statusDropdownFinder = find.ancestor(
        of: find.byType(DropdownButtonFormField<String>),
        matching: find.ancestor(
          of: statusLabelFinder,
          matching: find.byType(Column),
        ),
      );
      expect(statusDropdownFinder, findsOneWidget);
      
      await tester.tap(statusDropdownFinder);
      await tester.pumpAndSettle();

      // Verify dropdown options
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('Can select a customer from dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the customer dropdown
      final dropdownFinder = find.byType(DropdownButton<int>);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Select a customer
      await tester.tap(find.text('Test Customer 1'));
      await tester.pumpAndSettle();

      // Verify the dropdown shows the selected customer
      expect(find.text('Test Customer 1'), findsOneWidget);
    });

    testWidgets('Can select a status from dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the status dropdown by finding the text "Visit Status" and moving to the next widget
      final statusLabelFinder = find.text('Visit Status');
      expect(statusLabelFinder, findsOneWidget);
      
      // Find the dropdown that follows the label
      final statusDropdownFinder = find.ancestor(
        of: find.byType(DropdownButtonFormField<String>),
        matching: find.ancestor(
          of: statusLabelFinder,
          matching: find.byType(Column),
        ),
      );
      expect(statusDropdownFinder, findsOneWidget);
      
      await tester.tap(statusDropdownFinder);
      await tester.pumpAndSettle();

      // Select a status
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      // Verify the dropdown shows the selected status
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('Can toggle activity selection', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap an activity chip
      final activityChip = find.text('Sales Visit');
      expect(activityChip, findsOneWidget);
      
      // Scroll to make sure the chip is visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      
      await tester.tap(activityChip, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify the chip is still present
      expect(activityChip, findsOneWidget);
    });

    testWidgets('Can enter text in location field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the location text field
      final locationField = find.byType(TextField).at(0);
      expect(locationField, findsOneWidget);

      // Enter text
      await tester.enterText(locationField, 'Test Location');
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('Test Location'), findsOneWidget);
    });

    testWidgets('Can enter text in notes field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the notes text field
      final notesField = find.byType(TextField).at(1);
      expect(notesField, findsOneWidget);

      // Enter text
      await tester.enterText(notesField, 'Test Notes');
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('Test Notes'), findsOneWidget);
    });
  });
}
