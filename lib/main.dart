import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:visit_tracker/Appconstants/app_theme.dart';
import 'package:visit_tracker/providers/activity_provider.dart';
import 'package:visit_tracker/providers/customer_provider.dart';
import 'package:visit_tracker/providers/visit_provider.dart';
import 'package:visit_tracker/screens/add_visit_screen.dart';
import 'package:visit_tracker/screens/stats_screen.dart';
import 'package:visit_tracker/screens/visit_list_screen.dart';

import 'models/activity.dart';
import 'models/customer.dart';
import 'models/visit.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  //
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(ActivityAdapter());
  Hive.registerAdapter(VisitAdapter());

  await Hive.openBox<Customer>('customers');
  await Hive.openBox<Activity>('activities');
  await Hive.openBox<Visit>('visits');


  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CustomerProvider()),
      ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ChangeNotifierProvider(create: (_) => VisitProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visit Tracker',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
          '/':(_) => const VisitListScreen(),
          '/add-visit': (_) => const AddVisitScreen(),
          '/stats': (_) => const StatsScreen(),
        },
    );
  }
}

