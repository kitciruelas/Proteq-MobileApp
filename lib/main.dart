import 'package:flutter/material.dart';
import 'login_screens/splash_screen.dart';
import 'screens/dashboard.dart';
import 'screens/report_incident.dart';
import 'screens/welfare_check.dart';
import 'screens/safety_protocols.dart';
import 'screens/evacuation_centers.dart';
import 'responders_screen/r_dashboard.dart';

void main() {
  runApp(const ProteqApp());
}

class ProteqApp extends StatelessWidget {
  const ProteqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PROTEQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[50],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/mode_selection': (context) => const ModeSelectionScreen(),
        '/user_dashboard': (context) => DashboardScreen(),
        '/responder_dashboard': (context) => const ResponderDashboardScreen(),
        '/report': (context) => const ReportIncidentScreen(key: ValueKey('route_report_incident')),
        '/welfare': (context) => WelfareCheckScreen(key: const ValueKey('route_welfare_check')),
        '/protocols': (context) => const SafetyProtocolsScreen(),
        '/evacuation': (context) => const EvacuationCentersScreen(),
      },
    );
  }
}

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROTEQ'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Your Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 40),
            // User Mode Button
            Container(
              width: double.infinity,
              height: 120,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/user_dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.red, width: 2),
                  ),
                  elevation: 4,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.person, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'User Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Report incidents and check safety',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            // Responder Mode Button
            SizedBox(
              width: double.infinity,
              height: 120,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/responder_dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.security, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Responder Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage incidents and respond',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
