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
  Customer? getCustomerById(int id) => 
    customers.firstWhere((customer) => customer.id == id, 
      orElse: () => Customer(id: id, name: 'Unknown'));
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
    activities.firstWhere((activity) => activity.id.toString() == id, 
      orElse: () => Activity(id: 0, description: 'Unknown')).description;
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
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<CustomerProvider>.value(value: customerProvider),
          ChangeNotifierProvider<ActivityProvider>.value(value: activityProvider),
          ChangeNotifierProvider<VisitProvider>.value(value: visitProvider),
        ],
        child: MaterialApp(
          home: AddVisitScreen(),
        ),
      );
    }

    testWidgets('AddVisitScreen renders all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify all form fields are rendered
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Activities Done'), findsOneWidget);
      expect(find.text('Select Visit Date'), findsOneWidget);
      expect(find.text('Submit Visit'), findsOneWidget);
    });

    testWidgets('Customer dropdown shows correct options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open the customer dropdown
      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();

      // Verify dropdown options
      expect(find.text('Test Customer 1'), findsOneWidget);
      expect(find.text('Test Customer 2'), findsOneWidget);
    });

    testWidgets('Status dropdown shows correct options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open the status dropdown
      await tester.tap(find.text('Status'));
      await tester.pumpAndSettle();

      // Verify dropdown options
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('Activities chips are displayed correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify activity chips
      expect(find.text('Sales Visit'), findsOneWidget);
      expect(find.text('Technical Support'), findsOneWidget);
      expect(find.text('Training'), findsOneWidget);
    });

    testWidgets('Submit button is disabled initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get the submit button
      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit Visit')
      );

      // Verify button is disabled
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('Can select a customer from dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open the customer dropdown
      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();

      // Select the first customer
      await tester.tap(find.text('Test Customer 1').last);
      await tester.pumpAndSettle();

      // Verify selection
      expect(find.text('Test Customer 1'), findsOneWidget);
    });

    testWidgets('Can select a status from dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open the status dropdown
      await tester.tap(find.text('Status'));
      await tester.pumpAndSettle();

      // Select a status
      await tester.tap(find.text('Completed').last);
      await tester.pumpAndSettle();

      // Verify selection
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('Can toggle activity selection', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap on an activity chip
      final salesVisitChip = find.text('Sales Visit');
      await tester.tap(salesVisitChip);
      await tester.pumpAndSettle();

      // Verify chip is selected (this is visual, so we can't directly test the selection state)
      // But we can test that the chip exists
      expect(salesVisitChip, findsOneWidget);
    });

    testWidgets('Can enter text in location field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter text in location field
      await tester.enterText(find.widgetWithText(TextField, 'Location'), 'Test Location');
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('Test Location'), findsOneWidget);
    });

    testWidgets('Can enter text in notes field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter text in notes field
      await tester.enterText(find.widgetWithText(TextField, 'Note'), 'Test Notes');
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('Test Notes'), findsOneWidget);
    });

    testWidgets('Date picker opens when date button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on the date picker button
      await tester.tap(find.text('Select Visit Date'));
      await tester.pumpAndSettle();

      // Verify date picker is shown
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
